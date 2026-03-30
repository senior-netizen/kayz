import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../parcels/domain/parcel_models.dart';
import '../../parcels/presentation/parcels_providers.dart';

class AgentScreen extends ConsumerWidget {
  final String agentId;

  const AgentScreen({super.key, required this.agentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routes = ref.watch(routesProvider).where((r) => r.assignedAgentId == agentId).toList();
    final routeId = routes.isEmpty ? '' : routes.first.id;
    final parcels = ref.watch(parcelsControllerProvider).where((p) => p.routeId == routeId).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Agent Mode • $agentId')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Assigned route: ${routes.isEmpty ? 'None' : routes.first.name}'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _ScannerPage(agentId: agentId))),
            child: const Text('Scan QR to progress status'),
          ),
          const SizedBox(height: 12),
          ...parcels.map((p) => Card(
                child: ListTile(
                  title: Text('${p.id} • ${p.status.name}'),
                  subtitle: Text('${p.receiverName} (${p.receiverPhone})'),
                  trailing: p.status == ParcelStatus.readyForPickup
                      ? TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _ProofOfDeliveryScreen(parcel: p))),
                          child: const Text('Deliver'),
                        )
                      : null,
                ),
              )),
        ],
      ),
    );
  }
}

class _ScannerPage extends ConsumerWidget {
  final String agentId;
  const _ScannerPage({required this.agentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool processed = false;
    return Scaffold(
      appBar: AppBar(title: const Text('QR Scanner')),
      body: MobileScanner(
        onDetect: (capture) async {
          if (processed || capture.barcodes.isEmpty) return;
          processed = true;
          final code = capture.barcodes.first.rawValue;
          if (code == null) return;
          final parcel = await ref.read(parcelsControllerProvider.notifier).scanAndProgress(qrPayload: code, agentId: agentId);
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(parcel == null ? 'Unknown QR' : 'Updated ${parcel.id} to ${parcel.status.name}')));
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _ProofOfDeliveryScreen extends ConsumerStatefulWidget {
  final Parcel parcel;
  const _ProofOfDeliveryScreen({required this.parcel});

  @override
  ConsumerState<_ProofOfDeliveryScreen> createState() => _ProofOfDeliveryScreenState();
}

class _ProofOfDeliveryScreenState extends ConsumerState<_ProofOfDeliveryScreen> {
  final _receiver = TextEditingController();
  final List<Offset> _signaturePoints = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Proof of Delivery • ${widget.parcel.id}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _receiver, decoration: const InputDecoration(labelText: 'Receiver name')),
            const SizedBox(height: 12),
            Expanded(
              child: GestureDetector(
                onPanUpdate: (details) {
                  final box = context.findRenderObject() as RenderBox?;
                  final local = box?.globalToLocal(details.globalPosition);
                  if (local != null) {
                    setState(() => _signaturePoints.add(local));
                  }
                },
                child: Container(
                  color: Colors.white12,
                  child: CustomPaint(painter: _SignaturePainter(_signaturePoints), child: const SizedBox.expand()),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await ref.read(parcelsControllerProvider.notifier).attachProof(
                      parcelId: widget.parcel.id,
                      proof: ProofOfDelivery(receiverName: _receiver.text, signaturePoints: _signaturePoints),
                    );
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: const Text('Confirm delivery'),
            )
          ],
        ),
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<Offset> points;
  _SignaturePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white..strokeWidth = 2;
    for (var i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}
