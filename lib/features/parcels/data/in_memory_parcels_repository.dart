import '../domain/parcel_models.dart';
import '../domain/parcels_repository.dart';

class InMemoryParcelsRepository implements ParcelsRepository {
  final Map<String, Parcel> _store = {};

  @override
  Future<List<Parcel>> all() async => _store.values.toList();

  @override
  Future<Parcel?> byId(String id) async => _store[id];

  @override
  Future<List<Parcel>> byPhone(String phone) async =>
      _store.values.where((p) => p.receiverPhone == phone).toList();

  @override
  Future<void> save(Parcel parcel) async {
    _store[parcel.id] = parcel;
  }

  @override
  Future<void> saveAll(List<Parcel> parcels) async {
    for (final p in parcels) {
      _store[p.id] = p;
    }
  }
}
