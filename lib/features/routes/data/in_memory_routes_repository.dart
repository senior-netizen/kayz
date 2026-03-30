import '../domain/route_models.dart';
import '../domain/routes_repository.dart';

class InMemoryRoutesRepository implements RoutesRepository {
  final List<CourierRoute> _routes;

  InMemoryRoutesRepository(this._routes);

  @override
  Future<List<CourierRoute>> all() async => _routes;

  @override
  Future<CourierRoute?> byId(String id) async {
    try {
      return _routes.firstWhere((route) => route.id == id);
    } catch (_) {
      return null;
    }
  }
}
