import 'package:flutter_bloc/flutter_bloc.dart';
import 'appointments_event.dart';
import 'appointments_state.dart';
import '../../../domain/usecases/create_appointment.dart';


class AppointmentsBloc extends Bloc<AppointmentsEvent, AppointmentsState> {
  final CreateAppointment createAppointment;

  AppointmentsBloc({required this.createAppointment})
      : super(AppointmentsInitial()) {
    on<CreateAppointmentEvent>(_onCreateAppointment);
    // TODO: implement Load, Update, Delete events later
  }

  Future<void> _onCreateAppointment(
    CreateAppointmentEvent event,
    Emitter<AppointmentsState> emit,
  ) async {
    emit(AppointmentsLoading());

    try {
      await createAppointment(event.appointment);

      emit(AppointmentCreated(event.appointment));
    } catch (e) {
      emit(AppointmentsError(e.toString()));
    }
  }
}
