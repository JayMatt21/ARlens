import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

const platform = MethodChannel('corner_detection_channel');

class AutoCornerRoomCalculatorPage extends StatefulWidget {
  const AutoCornerRoomCalculatorPage({super.key});
  @override
  State<AutoCornerRoomCalculatorPage> createState() => _AutoCornerRoomCalculatorPageState();
}

class _AutoCornerRoomCalculatorPageState extends State<AutoCornerRoomCalculatorPage> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  List<Offset> points = [];
  double calculatedArea = 0.0;
  bool _isCameraInitialized = false;
  bool _processingFrame = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    var status = await Permission.camera.request();
    if (!status.isGranted) return;

    cameras = await availableCameras();
    if (cameras!.isNotEmpty) {
      _cameraController = CameraController(
        cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _cameraController!.initialize();
      setState(() { _isCameraInitialized = true; });

      // Start frame stream for automatic analysis
      _cameraController!.startImageStream((CameraImage image) {
        if (!_processingFrame) {
          _processingFrame = true;
          _processCameraFrame(image); // Frame analysis
        }
      });
    }
  }

  Future<void> _processCameraFrame(CameraImage image) async {
    // Convert CameraImage -> Uint8List for native passing, implementation depends on Camera format
    final bytes = extractBytesFromCameraImage(image);

    final corners = await detectCornersWithOpenCV(bytes);
    setState(() {
      points = corners;
      if (points.length >= 3) {
        calculatedArea = calculateArea(points);
      }
    });

    // Only process every X milliseconds (to avoid overload)
    await Future.delayed(const Duration(milliseconds: 400));
    _processingFrame = false;
  }

  // Platform channel: native detector
  Future<List<Offset>> detectCornersWithOpenCV(Uint8List bytes) async {
    final List corners = await platform.invokeMethod('detectCorners', {'imageBytes': bytes});
    return corners.map((pt) => Offset(pt[0].toDouble(), pt[1].toDouble())).toList();
  }

  double calculateArea(List<Offset> pts) {
    if (pts.length < 3) return 0.0;
    double sum = 0.0;
    for (int i = 0; i < pts.length; i++) {
      final p1 = pts[i];
      final p2 = pts[(i + 1) % pts.length];
      sum += (p1.dx * p2.dy) - (p2.dx * p1.dy);
    }
    // You must calibrate scale similar sa previous code!
    double scale = 1.0; // Set depending on calibration/actual meters vs pixels
    return (sum.abs() / 2.0) * (scale * scale);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Auto Area Calculator")),
      body: Column(
        children: [
          if (!_isCameraInitialized)
            const Center(child: CircularProgressIndicator())
          else
            Expanded(
              child: Stack(
                children: [
                  CameraPreview(_cameraController!),
                  // Overlay detected corners
                  ...points.map((offset) => Positioned(
                    left: offset.dx - 8,
                    top: offset.dy - 8,
                    child: Container(
                      width: 16, height: 16,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle
                      ),
                    ),
                  )),
                  // Lines between points
                  if (points.length >= 2)
                    CustomPaint(
                      size: Size.infinite,
                      painter: LinesPainter(points),
                    ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text("Area: ${calculatedArea.toStringAsFixed(2)} m²"),
          ),
        ],
      ),
    );
  }
}


Uint8List extractBytesFromCameraImage(CameraImage image) {
  return Uint8List(0); 
}

class LinesPainter extends CustomPainter {
  final List<Offset> points;
  LinesPainter(this.points);
  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    if (points.length >= 3) path.close();
    canvas.drawPath(path, paint);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
