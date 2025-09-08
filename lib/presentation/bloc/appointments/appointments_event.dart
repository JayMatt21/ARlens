import 'package:equatable/equatable.dart';
import '../../../domain/entities/appointment.dart';

abstract class AppointmentsEvent extends Equatable {
  const AppointmentsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAppointmentsEvent extends AppointmentsEvent {}

class CreateAppointmentEvent extends AppointmentsEvent {
  final Appointment appointment;

  const CreateAppointmentEvent(this.appointment);

  @override
  List<Object?> get props => [appointment];
}

class UpdateAppointmentEvent extends AppointmentsEvent {
  final Appointment appointment;

  const UpdateAppointmentEvent(this.appointment);

  @override
  List<Object?> get props => [appointment];
}

class DeleteAppointmentEvent extends AppointmentsEvent {
  final String id;

  const DeleteAppointmentEvent(this.id);

  @override
  List<Object?> get props => [id];
}
