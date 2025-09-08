import 'package:equatable/equatable.dart';
import '../../../domain/entities/appointment.dart';

abstract class AppointmentsState extends Equatable {
  const AppointmentsState();

  @override
  List<Object?> get props => [];
}

class AppointmentsInitial extends AppointmentsState {}

class AppointmentsLoading extends AppointmentsState {}

class AppointmentsLoaded extends AppointmentsState {
  final List<Appointment> appointments;

  const AppointmentsLoaded(this.appointments);

  @override
  List<Object?> get props => [appointments];
}

class AppointmentCreated extends AppointmentsState {
  final Appointment appointment;

  const AppointmentCreated(this.appointment);

  @override
  List<Object?> get props => [appointment];
}

class AppointmentUpdated extends AppointmentsState {
  final Appointment appointment;

  const AppointmentUpdated(this.appointment);

  @override
  List<Object?> get props => [appointment];
}

class AppointmentDeleted extends AppointmentsState {
  final String id;

  const AppointmentDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

class AppointmentsError extends AppointmentsState {
  final String message;

  const AppointmentsError(this.message);

  @override
  List<Object?> get props => [message];
}
