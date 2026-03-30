import 'route_models.dart';

abstract class RoutesRepository {
  Future<List<CourierRoute>> all();
  Future<CourierRoute?> byId(String id);
}
