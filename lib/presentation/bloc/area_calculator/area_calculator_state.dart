import 'package:equatable/equatable.dart';

enum AreaCalculatorStatus {
  initial,
  imageCaptured,
  scaleCalibrated,
  areaComputed,
}

class AreaCalculatorState extends Equatable {
  final String? imagePath;
  final bool showGrid;
  final double? pixelsPerMeter;
  final double? computedArea;
  final AreaCalculatorStatus status;

  const AreaCalculatorState({
    this.imagePath,
    this.showGrid = true,
    this.pixelsPerMeter,
    this.computedArea,
    this.status = AreaCalculatorStatus.initial,
  });

  factory AreaCalculatorState.initial() => const AreaCalculatorState();

  AreaCalculatorState copyWith({
    String? imagePath,
    bool? showGrid,
    double? pixelsPerMeter,
    double? computedArea,
    AreaCalculatorStatus? status,
  }) {
    return AreaCalculatorState(
      imagePath: imagePath ?? this.imagePath,
      showGrid: showGrid ?? this.showGrid,
      pixelsPerMeter: pixelsPerMeter ?? this.pixelsPerMeter,
      computedArea: computedArea ?? this.computedArea,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        imagePath,
        showGrid,
        pixelsPerMeter,
        computedArea,
        status,
      ];
}