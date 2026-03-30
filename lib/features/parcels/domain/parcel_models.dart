import 'package:flutter/foundation.dart';

enum ParcelStatus {
  pending,
  collected,
  inTransit,
  arrived,
  readyForPickup,
  delivered,
}

@immutable
class ParcelLifecycleEvent {
  final ParcelStatus status;
  final DateTime timestamp;
  final String agentId;
  final bool synced;

  const ParcelLifecycleEvent({
    required this.status,
    required this.timestamp,
    required this.agentId,
    this.synced = false,
  });

  ParcelLifecycleEvent markSynced() => ParcelLifecycleEvent(
        status: status,
        timestamp: timestamp,
        agentId: agentId,
        synced: true,
      );
}

@immutable
class ProofOfDelivery {
  final String receiverName;
  final List<Offset> signaturePoints;
  final String? photoPath;

  const ProofOfDelivery({
    required this.receiverName,
    required this.signaturePoints,
    this.photoPath,
  });
}

@immutable
class Parcel {
  final String id;
  final String senderName;
  final String receiverName;
  final String receiverPhone;
  final String destination;
  final String parcelType;
  final String qrPayload;
  final String routeId;
  final String pickupLocation;
  final ParcelStatus status;
  final List<ParcelLifecycleEvent> timeline;
  final ProofOfDelivery? proof;

  const Parcel({
    required this.id,
    required this.senderName,
    required this.receiverName,
    required this.receiverPhone,
    required this.destination,
    required this.parcelType,
    required this.qrPayload,
    required this.routeId,
    required this.pickupLocation,
    this.status = ParcelStatus.pending,
    this.timeline = const [],
    this.proof,
  });

  Parcel copyWith({
    String? routeId,
    String? pickupLocation,
    ParcelStatus? status,
    List<ParcelLifecycleEvent>? timeline,
    ProofOfDelivery? proof,
  }) {
    return Parcel(
      id: id,
      senderName: senderName,
      receiverName: receiverName,
      receiverPhone: receiverPhone,
      destination: destination,
      parcelType: parcelType,
      qrPayload: qrPayload,
      routeId: routeId ?? this.routeId,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      status: status ?? this.status,
      timeline: timeline ?? this.timeline,
      proof: proof ?? this.proof,
    );
  }
}
