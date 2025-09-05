import 'package:arlens/domain/usecases/calculate_area.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arlens/domain/entities/point_entity.dart';

class AreaCalculatorState {
  final String? imagePath;
  final bool showGrid;
  final double? pixelsPerMeter;
  final double? computedArea;
  final List<PointEntity>? boundaryPoints;

  AreaCalculatorState({
    this.imagePath,
    this.showGrid = true,
    this.pixelsPerMeter,
    this.computedArea,
    this.boundaryPoints,
  });

  AreaCalculatorState copyWith({
    String? imagePath,
    bool? showGrid,
    double? pixelsPerMeter,
    double? computedArea,
    List<PointEntity>? boundaryPoints,
  }) {
    return AreaCalculatorState(
      imagePath: imagePath ?? this.imagePath,
      showGrid: showGrid ?? this.showGrid,
      pixelsPerMeter: pixelsPerMeter ?? this.pixelsPerMeter,
      computedArea: computedArea ?? this.computedArea,
      boundaryPoints: boundaryPoints ?? this.boundaryPoints,
    );
  }
}

class AreaCalculatorBloc extends Cubit<AreaCalculatorState> {
  final CalculateAreaUseCase calculateAreaUseCase;

  AreaCalculatorBloc({required this.calculateAreaUseCase})
      : super(AreaCalculatorState());

  /// Store the captured image path and reset previous area.
  void setCapturedImage(String path) {
    emit(state.copyWith(imagePath: path, computedArea: null));
  }

  /// Show or hide the grid overlay.
  void toggleGrid() {
    emit(state.copyWith(showGrid: !state.showGrid));
  }

  /// Define how many pixels correspond to one meter.
  void setPixelsPerMeter(double pixelsPerMeter) {
    emit(state.copyWith(pixelsPerMeter: pixelsPerMeter));
  }

  /// Compute area in square meters given a pixel count.
  /// area_m² = pixelCount / (pixelsPerMeter)²
  void computeAreaFromPixels(double pixelCount) {
    final ppm = state.pixelsPerMeter;
    if (ppm != null && ppm > 0) {
      final areaMeters = pixelCount / (ppm * ppm);
      emit(state.copyWith(computedArea: areaMeters));
    }
  }

  /// Compute area from boundary points using Shoelace formula.
  void computeAreaFromPoints(List<PointEntity> points) {
    final areaMeters = calculateAreaUseCase.execute(points);
    emit(state.copyWith(computedArea: areaMeters, boundaryPoints: points));
  }

  /// Clear all data to start over.
  void reset() {
    emit(AreaCalculatorState());
  }
}