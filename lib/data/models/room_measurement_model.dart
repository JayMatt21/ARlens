import 'package:equatable/equatable.dart';
import '../../domain/entities/room_measurement.dart';

class RoomMeasurementModel extends Equatable {
  final String id;
  final String customerId;
  final String roomName;
  final double lengthMeters;
  final double widthMeters;
  final double heightMeters;
  final double areaSqm;
  final double volumeCum;
  final String roomType;
  final String? notes;
  final DateTime createdAt;

  const RoomMeasurementModel({
    required this.id,
    required this.customerId,
    required this.roomName,
    required this.lengthMeters,
    required this.widthMeters,
    required this.heightMeters,
    required this.areaSqm,
    required this.volumeCum,
    required this.roomType,
    this.notes,
    required this.createdAt,
  });

  factory RoomMeasurementModel.fromJson(Map<String, dynamic> json) {
    return RoomMeasurementModel(
      id: json['id'] as String,
      customerId: json['customer_id'] as String,
      roomName: json['room_name'] as String,
      lengthMeters: (json['length_meters'] as num).toDouble(),
      widthMeters: (json['width_meters'] as num).toDouble(),
      heightMeters: (json['height_meters'] as num).toDouble(),
      areaSqm: (json['area_sqm'] as num).toDouble(),
      volumeCum: (json['volume_cum'] as num).toDouble(),
      roomType: json['room_type'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'room_name': roomName,
      'length_meters': lengthMeters,
      'width_meters': widthMeters,
      'height_meters': heightMeters,
      'room_type': roomType,
      'notes': notes,
    };
  }

  RoomMeasurement toEntity() {
    return RoomMeasurement(
      id: id,
      customerId: customerId,
      roomName: roomName,
      lengthMeters: lengthMeters,
      widthMeters: widthMeters,
      heightMeters: heightMeters,
      areaSqm: areaSqm,
      volumeCum: volumeCum,
      roomType: roomType,
      notes: notes,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id, customerId, roomName, lengthMeters, widthMeters, 
    heightMeters, areaSqm, volumeCum, roomType, notes, createdAt
  ];
}