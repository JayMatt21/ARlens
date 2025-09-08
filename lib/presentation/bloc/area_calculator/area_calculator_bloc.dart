import 'package:flutter_bloc/flutter_bloc.dart';
import 'area_calculator_event.dart';
import 'area_calculator_state.dart';
import 'package:arlens/domain/usecases/calculate_area.dart';


class AreaCalculatorBloc extends Bloc<AreaCalculatorEvent, AreaCalculatorState> {
  final CalculateAreaUseCase calculateAreaUseCase;

  AreaCalculatorBloc({required this.calculateAreaUseCase})
      : super(AreaCalculatorState.initial()) {
    on<ImageCaptured>(_onImageCaptured);
    on<GridToggled>(_onGridToggled);
    on<ScaleCalibrated>(_onScaleCalibrated);
    on<ComputeAreaRequested>(_onComputeAreaRequested);
    on<CalculatorReset>(_onCalculatorReset);
  }

  void _onImageCaptured(
    ImageCaptured event,
    Emitter<AreaCalculatorState> emit,
  ) {
    emit(state.copyWith(
      imagePath: event.imagePath,
      status: AreaCalculatorStatus.imageCaptured,
    ));
  }

  void _onGridToggled(
    GridToggled event,
    Emitter<AreaCalculatorState> emit,
  ) {
    emit(state.copyWith(showGrid: !state.showGrid));
  }

  void _onScaleCalibrated(
    ScaleCalibrated event,
    Emitter<AreaCalculatorState> emit,
  ) {
    emit(state.copyWith(
      pixelsPerMeter: event.pixelsPerMeter,
      status: AreaCalculatorStatus.scaleCalibrated,
    ));
  }

  void _onComputeAreaRequested(
    ComputeAreaRequested event,
    Emitter<AreaCalculatorState> emit,
  ) {
    // Use the injected usecase that expects List<PointEntity>.
    try {
      final double area = calculateAreaUseCase.execute(event.points);
      emit(state.copyWith(
        computedArea: area,
        status: AreaCalculatorStatus.areaComputed,
      ));
    } catch (e) {
      // If you want an error status, add it to AreaCalculatorStatus and emit here.
      // For now we silently ignore and keep previous state.
    }
  }

  void _onCalculatorReset(
    CalculatorReset event,
    Emitter<AreaCalculatorState> emit,
  ) {
    emit(AreaCalculatorState.initial());
  }
}
