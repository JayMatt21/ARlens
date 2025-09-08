import 'package:flutter_bloc/flutter_bloc.dart';
import 'services_event.dart';
import 'services_state.dart';
import '../../../domain/usecases/get_services.dart';

class ServicesBloc extends Bloc<ServicesEvent, ServicesState> {
  final GetServices getServices;
  ServicesBloc({required this.getServices}) : super(ServicesInitial()) {
    on<LoadServicesEvent>(_onLoadServices);
  }

  Future<void> _onLoadServices(
    LoadServicesEvent event,
    Emitter<ServicesState> emit,
  ) async {
    emit(ServicesLoading());
    try {
      final services = await getServices();
      emit(ServicesLoaded(services));
    } catch (e) {
      emit(ServicesError(e.toString()));
    }
  }
}
