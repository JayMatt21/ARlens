import 'package:arlens/domain/entities/appointment.dart' as entity;

class Appointment {
  final String id;
  final String customerId;
  final String technicianId;
  final DateTime scheduledAt;
  final String status;
  final String notes;

  Appointment({
    required this.id,
    required this.customerId,
    required this.technicianId,
    required this.scheduledAt,
    required this.status,
    required this.notes,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
        id: json['id'],
        customerId: json['customer_id'],
        technicianId: json['technician_id'],
        scheduledAt: DateTime.parse(json['scheduled_at']),
        status: json['status'],
        notes: json['notes'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer_id': customerId,
        'technician_id': technicianId,
        'scheduled_at': scheduledAt.toIso8601String(),
        'status': status,
        'notes': notes,
      };

  // ↔ Convert to Entity
  entity.Appointment toEntity() => entity.Appointment(
        id: id,
        customerId: customerId,
        technicianId: technicianId,
        scheduledAt: scheduledAt,
        status: status,
        notes: notes,
      );

  // ↔ Create Model from Entity
  factory Appointment.fromEntity(entity.Appointment e) => Appointment(
        id: e.id,
        customerId: e.customerId,
        technicianId: e.technicianId,
        scheduledAt: e.scheduledAt,
        status: e.status,
        notes: e.notes,
      );
}
