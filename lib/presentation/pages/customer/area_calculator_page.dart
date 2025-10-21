import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'products_page.dart';

class CustomerAreaCalculatorPage extends StatefulWidget {
  const CustomerAreaCalculatorPage({super.key});
  @override
  State<CustomerAreaCalculatorPage> createState() => _CustomerAreaCalculatorPageState();
}

class _CustomerAreaCalculatorPageState extends State<CustomerAreaCalculatorPage> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  List<Offset> points = [];
  double calculatedArea = 0.0;
  double referenceLengthMeters = 1.0;
  double referenceLengthPixels = 100.0;
  bool _isCameraInitialized = false;
  bool _isCalibrating = false;
  List<Offset> calibrationPoints = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Request camera permission
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera.request();
    }

    // Get available cameras
    cameras = await availableCameras();
    if (cameras!.isNotEmpty) {
      _cameraController = CameraController(
        cameras![0], // Use back camera
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Video Room Area Calculator"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Instructions banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.blue.shade50,
            child: Text(
              _isCalibrating
                ? "CALIBRATION: Tap two points that are 1 meter apart"
                : "TAP on the floor corners to measure room area",
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          // Camera preview with overlay
          Expanded(
            child: _isCameraInitialized
                ? GestureDetector(
                    onTapDown: (details) {
                      if (_isCalibrating) {
                        _handleCalibrationTap(details);
                      } else {
                        _handleMeasurementTap(details);
                      }
                    },
                    child: Stack(
                      children: [
                        // Live camera feed
                        SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: CameraPreview(_cameraController!),
                        ),
                        // Measurement points overlay
                        if (!_isCalibrating)
                          ...points.asMap().entries.map(
                            (entry) => Positioned(
                              left: entry.value.dx - 8,
                              top: entry.value.dy - 8,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: Center(
                                  child: Text(
                                    '${entry.key + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        // Calibration points overlay
                        if (_isCalibrating)
                          ...calibrationPoints.asMap().entries.map(
                            (entry) => Positioned(
                              left: entry.value.dx - 8,
                              top: entry.value.dy - 8,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.yellow,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.black, width: 2),
                                ),
                                child: Center(
                                  child: Text(
                                    'C${entry.key + 1}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        // Draw lines between points
                        if (points.length > 1 && !_isCalibrating)
                          CustomPaint(
                            size: Size.infinite,
                            painter: LinesPainter(points),
                          ),
                        // Draw calibration line
                        if (calibrationPoints.length == 2)
                          CustomPaint(
                            size: Size.infinite,
                            painter: CalibrationLinePainter(calibrationPoints),
                          ),
                      ],
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          // Control panel
          Container(
            padding: const EdgeInsets.all(12.0),
            color: Colors.grey.shade100,
            child: Column(
              children: [
                if (!_isCalibrating) ...[
                  Text("Points tapped: ${points.length}"),
                  Text("Estimated area: ${calculatedArea.toStringAsFixed(2)} m²"),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _startCalibration,
                        child: const Text("Calibrate"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      ),
                      ElevatedButton(
                        onPressed: points.isNotEmpty ? _resetPoints : null,
                        child: const Text("Reset"),
                      ),
                      ElevatedButton(
                        onPressed: points.length >= 3 ? () => _showACRecommendation(calculatedArea) : null,
                        child: const Text("Suggest AC"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      ),
                    ],
                  ),
                ] else ...[
                  Text("Calibration points: ${calibrationPoints.length}/2"),
                  Text("Reference: ${referenceLengthMeters}m = ${referenceLengthPixels.toStringAsFixed(1)} pixels"),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _finishCalibration,
                        child: const Text("Done"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      ),
                      ElevatedButton(
                        onPressed: _cancelCalibration,
                        child: const Text("Cancel"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleMeasurementTap(TapDownDetails details) {
    setState(() {
      points.add(details.localPosition);
      if (points.length >= 3) {
        calculatedArea = calculateArea(points);
      }
    });
  }

  void _handleCalibrationTap(TapDownDetails details) {
    setState(() {
      if (calibrationPoints.length < 2) {
        calibrationPoints.add(details.localPosition);
        if (calibrationPoints.length == 2) {
          // Calculate pixel distance between calibration points
          double dx = calibrationPoints[1].dx - calibrationPoints[0].dx;
          double dy = calibrationPoints[1].dy - calibrationPoints[0].dy;
          referenceLengthPixels = sqrt(dx * dx + dy * dy);
        }
      }
    });
  }

  void _startCalibration() {
    setState(() {
      _isCalibrating = true;
      calibrationPoints.clear();
    });
  }

  void _finishCalibration() {
    if (calibrationPoints.length == 2) {
      setState(() {
        _isCalibrating = false;
        if (points.length >= 3) {
          calculatedArea = calculateArea(points);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Calibration complete!")),
      );
    }
  }

  void _cancelCalibration() {
    setState(() {
      _isCalibrating = false;
      calibrationPoints.clear();
    });
  }

  void _resetPoints() {
    setState(() {
      points.clear();
      calculatedArea = 0.0;
    });
  }

  double calculateArea(List<Offset> pts) {
    if (pts.length < 3) return 0.0;
    double sum = 0.0;
    for (int i = 0; i < pts.length; i++) {
      final p1 = pts[i];
      final p2 = pts[(i + 1) % pts.length];
      sum += (p1.dx * p2.dy) - (p2.dx * p1.dy);
    }
    double scale = referenceLengthMeters / referenceLengthPixels;
    double areaInMeters2 = (sum.abs() / 2.0) * (scale * scale);
    return areaInMeters2;
  }

  void _showACRecommendation(double area) {
    String suggestion;
    if (area <= 12) {
      suggestion = "0.75–1 HP AC (Small Room)";
    } else if (area <= 25) {
      suggestion = "1–1.5 HP AC (Medium Room)";
    } else {
      suggestion = "2 HP+ AC (Large Room)";
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("AC Recommendation"),
        content: Text("Area: ${area.toStringAsFixed(2)} m²\n$suggestion"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductsPage()));
            },
            child: const Text("View Products"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}

// Custom painter for drawing lines between points
class LinesPainter extends CustomPainter {
  final List<Offset> points;

  LinesPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    // Close the polygon if we have 3+ points
    if (points.length >= 3) {
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Custom painter for calibration line
class CalibrationLinePainter extends CustomPainter {
  final List<Offset> points;

  CalibrationLinePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length != 2) return;

    final paint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(points[0], points[1], paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
