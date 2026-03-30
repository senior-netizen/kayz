import 'parcel_models.dart';

abstract class ParcelsRepository {
  Future<List<Parcel>> all();
  Future<Parcel?> byId(String id);
  Future<List<Parcel>> byPhone(String phone);
  Future<void> save(Parcel parcel);
  Future<void> saveAll(List<Parcel> parcels);
}
