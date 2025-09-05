import 'package:equatable/equatable.dart';

class Appointment extends Equatable {
  final String id;
  final String customerId;
  final String technicianId;
  final DateTime scheduledAt;
  final String status;
  final String notes;

  const Appointment({
    required this.id,
    required this.customerId,
    required this.technicianId,
    required this.scheduledAt,
    required this.status,
    required this.notes,
  });

  @override
  List<Object?> get props => [
    id, customerId, technicianId, scheduledAt, status, notes
  ];
}