import 'package:flutter/foundation.dart';

@immutable
class CourierRoute {
  final String id;
  final String name;
  final DateTime departureTime;
  final int capacityLimit;
  final String assignedAgentId;

  const CourierRoute({
    required this.id,
    required this.name,
    required this.departureTime,
    required this.capacityLimit,
    required this.assignedAgentId,
  });
}
