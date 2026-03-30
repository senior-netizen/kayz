import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../parcels/domain/parcel_models.dart';
import '../../parcels/presentation/parcels_providers.dart';

class CustomerTrackingScreen extends ConsumerStatefulWidget {
  const CustomerTrackingScreen({super.key});

  @override
  ConsumerState<CustomerTrackingScreen> createState() => _CustomerTrackingScreenState();
}

class _CustomerTrackingScreenState extends ConsumerState<CustomerTrackingScreen> {
  final controller = TextEditingController();
  Parcel? result;

  @override
  Widget build(BuildContext context) {
    final parcels = ref.watch(parcelsControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Track Parcel')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: controller, decoration: const InputDecoration(labelText: 'Parcel ID or phone number')),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              final query = controller.text.trim();
              final found = parcels.where((p) => p.id == query || p.receiverPhone == query).toList();
              setState(() => result = found.isEmpty ? null : found.first);
            },
            child: const Text('Track'),
          ),
          const SizedBox(height: 20),
          if (result != null) ...[
            Text('Parcel: ${result!.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Current status: ${result!.status.name}'),
            Text('Route: ${result!.routeId}'),
            Text('Pickup: ${result!.pickupLocation}'),
            const SizedBox(height: 12),
            ...ParcelStatus.values.map((status) {
              final reached = result!.timeline.any((e) => e.status == status);
              final event = result!.timeline.where((e) => e.status == status).cast<ParcelLifecycleEvent?>().firstOrNull;
              return ListTile(
                leading: Icon(reached ? Icons.check_circle : Icons.radio_button_unchecked),
                title: Text(status.name),
                subtitle: Text(event == null ? 'Pending' : DateFormat('HH:mm, dd MMM').format(event.timestamp)),
              );
            }),
          ] else
            const Text('No parcel selected.'),
        ],
      ),
    );
  }
}
