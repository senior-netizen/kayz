import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/network/mock_sync_service.dart';
import '../../../core/utils/notifications_service.dart';
import '../../pickup/domain/pickup_point.dart';
import '../../routes/data/in_memory_routes_repository.dart';
import '../../routes/domain/route_models.dart';
import '../data/in_memory_parcels_repository.dart';
import '../domain/parcel_models.dart';

final notificationsServiceProvider = Provider((_) => NotificationsService());
final syncServiceProvider = Provider((_) => MockSyncService());
final uuidProvider = Provider((_) => const Uuid());

final routesProvider = Provider<List<CourierRoute>>((_) {
  final now = DateTime.now();
  return [
    CourierRoute(id: 'r1', name: 'Harare → Zvishavane', departureTime: now.add(const Duration(hours: 1)), capacityLimit: 120, assignedAgentId: 'agent-a'),
    CourierRoute(id: 'r2', name: 'Harare → Masvingo', departureTime: now.add(const Duration(hours: 2)), capacityLimit: 100, assignedAgentId: 'agent-b'),
    CourierRoute(id: 'r3', name: 'Harare → Mberengwa', departureTime: now.add(const Duration(hours: 3)), capacityLimit: 90, assignedAgentId: 'agent-c'),
  ];
});

final pickupPointsProvider = Provider<List<PickupPoint>>((_) => const [
      PickupPoint(name: 'Kwame Mall', lat: -17.8292, lng: 31.0522, assignedAgentId: 'agent-a'),
      PickupPoint(name: 'Zvishavane CABS', lat: -20.3267, lng: 30.0665, assignedAgentId: 'agent-b'),
      PickupPoint(name: 'Masvingo CBD', lat: -20.0746, lng: 30.8326, assignedAgentId: 'agent-c'),
    ]);

final parcelsRepositoryProvider = Provider((_) => InMemoryParcelsRepository());
final routesRepositoryProvider = Provider((ref) => InMemoryRoutesRepository(ref.watch(routesProvider)));

final parcelsControllerProvider = NotifierProvider<ParcelsController, List<Parcel>>(ParcelsController.new);

class ParcelsController extends Notifier<List<Parcel>> {
  @override
  List<Parcel> build() => [];

  Future<Parcel> createParcel({
    required String sender,
    required String receiver,
    required String phone,
    required String destination,
    required String parcelType,
    required String routeId,
    required String pickupLocation,
    required String agentId,
  }) async {
    final uuid = ref.read(uuidProvider);
    final id = 'P-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}-${uuid.v4().substring(0, 4).toUpperCase()}';
    final firstEvent = ParcelLifecycleEvent(
      status: ParcelStatus.pending,
      timestamp: DateTime.now(),
      agentId: agentId,
      synced: false,
    );
    final parcel = Parcel(
      id: id,
      senderName: sender,
      receiverName: receiver,
      receiverPhone: phone,
      destination: destination,
      parcelType: parcelType,
      qrPayload: id,
      routeId: routeId,
      pickupLocation: pickupLocation,
      timeline: [firstEvent],
    );
    state = [...state, parcel];
    await ref.read(parcelsRepositoryProvider).save(parcel);
    ref.read(syncServiceProvider).enqueue(() async {
      final synced = parcel.copyWith(timeline: parcel.timeline.map((e) => e.markSynced()).toList());
      await ref.read(parcelsRepositoryProvider).save(synced);
    });
    await ref.read(notificationsServiceProvider).notify('Parcel created', 'Parcel $id created and assigned.');
    return parcel;
  }

  Future<Parcel?> scanAndProgress({required String qrPayload, required String agentId}) async {
    final idx = state.indexWhere((p) => p.qrPayload == qrPayload || p.id == qrPayload);
    if (idx < 0) return null;

    final current = state[idx];
    final next = _nextStatus(current.status);
    if (next == current.status) return current;

    final updatedTimeline = [...current.timeline, ParcelLifecycleEvent(status: next, timestamp: DateTime.now(), agentId: agentId, synced: false)];
    final updated = current.copyWith(status: next, timeline: updatedTimeline);
    final copy = [...state]..[idx] = updated;
    state = copy;
    await ref.read(parcelsRepositoryProvider).save(updated);

    ref.read(syncServiceProvider).enqueue(() async {
      final synced = updated.copyWith(timeline: updatedTimeline.map((e) => e.markSynced()).toList());
      await ref.read(parcelsRepositoryProvider).save(synced);
    });

    await ref.read(notificationsServiceProvider).notify('Parcel ${updated.id}', 'Status updated to ${next.name}.');
    return updated;
  }

  Future<void> attachProof({required String parcelId, required ProofOfDelivery proof}) async {
    final idx = state.indexWhere((p) => p.id == parcelId);
    if (idx < 0) return;
    final updated = state[idx].copyWith(proof: proof, status: ParcelStatus.delivered, timeline: [
      ...state[idx].timeline,
      ParcelLifecycleEvent(status: ParcelStatus.delivered, timestamp: DateTime.now(), agentId: 'agent-proof')
    ]);
    final copy = [...state]..[idx] = updated;
    state = copy;
    await ref.read(parcelsRepositoryProvider).save(updated);
    await ref.read(notificationsServiceProvider).notify('Delivered', 'Parcel ${updated.id} delivered with signature.');
  }

  ParcelStatus _nextStatus(ParcelStatus status) {
    switch (status) {
      case ParcelStatus.pending:
        return ParcelStatus.collected;
      case ParcelStatus.collected:
        return ParcelStatus.inTransit;
      case ParcelStatus.inTransit:
        return ParcelStatus.arrived;
      case ParcelStatus.arrived:
        return ParcelStatus.readyForPickup;
      case ParcelStatus.readyForPickup:
        return ParcelStatus.delivered;
      case ParcelStatus.delivered:
        return ParcelStatus.delivered;
    }
  }
}
