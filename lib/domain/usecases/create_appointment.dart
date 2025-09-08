import '../repositories/app_repository.dart';
import '../entities/appointment.dart';

class CreateAppointment {
  final AppRepository repository;
  CreateAppointment(this.repository);

  Future<void> call(Appointment appointment) {
    return repository.createAppointment(appointment);
  }
}
