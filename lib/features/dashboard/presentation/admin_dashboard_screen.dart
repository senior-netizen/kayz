import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../parcels/domain/parcel_models.dart';
import '../../../parcels/presentation/parcels_providers.dart';
import '../../../tracking/presentation/customer_tracking_screen.dart';
import '../../../../shared/widgets/glass_card.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  String? routeFilter;
  ParcelStatus? statusFilter;

  @override
  Widget build(BuildContext context) {
    final routes = ref.watch(routesProvider);
    final parcels = ref.watch(parcelsControllerProvider);
    final filtered = parcels.where((p) {
      final routePass = routeFilter == null || p.routeId == routeFilter;
      final statusPass = statusFilter == null || p.status == statusFilter;
      return routePass && statusPass;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _metric('Active Routes', '${routes.length}'),
              _metric('Delivered', '${parcels.where((p) => p.status == ParcelStatus.delivered).length}'),
              _metric('Delayed', '${parcels.where((p) => p.status != ParcelStatus.delivered && p.timeline.isNotEmpty && DateTime.now().difference(p.timeline.last.timestamp).inHours > 3).length}'),
              _metric('Total Parcels', '${parcels.length}'),
            ],
          ),
          const SizedBox(height: 12),
          _filters(routes),
          const SizedBox(height: 12),
          _createParcelPanel(routes),
          const SizedBox(height: 12),
          ...filtered.map((parcel) => _parcelTile(parcel, routes)).toList(),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerTrackingScreen())),
            child: const Text('Open customer tracking demo'),
          )
        ],
      ),
    );
  }

  Widget _metric(String label, String value) => SizedBox(
        width: 170,
        child: GlassCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label), const SizedBox(height: 8), Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))]),
        ),
      );

  Widget _filters(List routes) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String?>(
            value: routeFilter,
            items: [const DropdownMenuItem(value: null, child: Text('All routes')), ...routes.map((r) => DropdownMenuItem(value: r.id, child: Text(r.name)))],
            onChanged: (v) => setState(() => routeFilter = v),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButtonFormField<ParcelStatus?>(
            value: statusFilter,
            items: [const DropdownMenuItem(value: null, child: Text('All statuses')), ...ParcelStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name)))],
            onChanged: (v) => setState(() => statusFilter = v),
          ),
        )
      ],
    );
  }

  Widget _createParcelPanel(List routes) {
    final sender = TextEditingController();
    final receiver = TextEditingController();
    final phone = TextEditingController();
    final destination = TextEditingController();
    final type = TextEditingController();
    String routeId = routes.first.id;

    return GlassCard(
      child: StatefulBuilder(builder: (context, localSetState) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Create Parcel (<10s)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(controller: sender, decoration: const InputDecoration(labelText: 'Sender name')),
          TextField(controller: receiver, decoration: const InputDecoration(labelText: 'Receiver name')),
          TextField(controller: phone, decoration: const InputDecoration(labelText: 'Receiver phone')),
          TextField(controller: destination, decoration: const InputDecoration(labelText: 'Destination')),
          TextField(controller: type, decoration: const InputDecoration(labelText: 'Parcel type')),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: routeId,
            items: routes.map<DropdownMenuItem<String>>((r) => DropdownMenuItem(value: r.id, child: Text(r.name))).toList(),
            onChanged: (v) => localSetState(() => routeId = v!),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              final pickup = ref.read(pickupPointsProvider).first.name;
              final parcel = await ref.read(parcelsControllerProvider.notifier).createParcel(
                    sender: sender.text,
                    receiver: receiver.text,
                    phone: phone.text,
                    destination: destination.text,
                    parcelType: type.text,
                    routeId: routeId,
                    pickupLocation: pickup,
                    agentId: 'admin',
                  );
              if (!context.mounted) return;
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Parcel ${parcel.id} created'),
                  content: QrImageView(data: parcel.qrPayload, size: 160),
                ),
              );
            },
            child: const Text('Create + Generate QR'),
          ),
        ]);
      }),
    );
  }

  Widget _parcelTile(Parcel parcel, List routes) {
    final route = routes.firstWhere((r) => r.id == parcel.routeId);
    final last = parcel.timeline.isEmpty ? null : parcel.timeline.last.timestamp;
    return Card(
      child: ListTile(
        title: Text('${parcel.id} • ${parcel.status.name}'),
        subtitle: Text('${route.name}\nLast update: ${last == null ? '-' : DateFormat('HH:mm, dd MMM').format(last)}\nPickup: ${parcel.pickupLocation}'),
        isThreeLine: true,
      ),
    );
  }
}
