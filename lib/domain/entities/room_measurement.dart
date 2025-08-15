import 'package:equatable/equatable.dart';

class RoomMeasurement extends Equatable {
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

  const RoomMeasurement({
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

  @override
  List<Object?> get props => [
        id,
        customerId,
        roomName,
        lengthMeters,
        widthMeters,
        heightMeters,
        areaSqm,
        volumeCum,
        roomType,
        notes,
        createdAt,
      ];
}
