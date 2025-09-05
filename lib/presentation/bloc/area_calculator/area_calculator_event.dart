import 'package:equatable/equatable.dart';

abstract class AreaCalculatorEvent extends Equatable {
  const AreaCalculatorEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered when a new image is captured via camera
class ImageCaptured extends AreaCalculatorEvent {
  final String imagePath;

  const ImageCaptured(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

/// Toggles the visibility of the grid overlay
class GridToggled extends AreaCalculatorEvent {
  const GridToggled();
}

/// Sets the calibration scale (pixels per meter)
class ScaleCalibrated extends AreaCalculatorEvent {
  final double pixelsPerMeter;

  const ScaleCalibrated(this.pixelsPerMeter);

  @override
  List<Object?> get props => [pixelsPerMeter];
}

/// Computes area based on pixel count (manual or auto-detected)
class ComputeAreaRequested extends AreaCalculatorEvent {
  final double pixelCount;

  const ComputeAreaRequested(this.pixelCount);

  @override
  List<Object?> get props => [pixelCount];
}

/// Resets the calculator to initial state
class CalculatorReset extends AreaCalculatorEvent {
  const CalculatorReset();
}