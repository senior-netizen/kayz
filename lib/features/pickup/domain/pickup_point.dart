import 'package:flutter/foundation.dart';

@immutable
class PickupPoint {
  final String name;
  final double lat;
  final double lng;
  final String assignedAgentId;

  const PickupPoint({
    required this.name,
    required this.lat,
    required this.lng,
    required this.assignedAgentId,
  });
}
