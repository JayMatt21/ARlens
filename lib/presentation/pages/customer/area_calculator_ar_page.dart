import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:huawei_ar/huawei_ar.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:camera/camera.dart';

class AreaCalculatorARPage extends StatefulWidget {
  const AreaCalculatorARPage({super.key});
  @override
  State<AreaCalculatorARPage> createState() => _AreaCalculatorARPageState();
}

class _AreaCalculatorARPageState extends State<AreaCalculatorARPage> {
  bool? _isHuawei;
  bool? _isIOS;
  List<Vector3> points = [];
  double calculatedArea = 0.0;
  ARSceneController? _arSceneController;
  String _arMode = 'unknown';
  CameraController? _cameraController;

  @override
  void initState() {
    super.initState();
    requestCameraPermission();
    detectPlatform();
  }

  Future<void> requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) await Permission.camera.request();
  }

  Future<void> detectPlatform() async {
    if (Platform.isIOS) {
      setState(() {
        _isIOS = true;
        _isHuawei = false;
        _arMode = 'arkit';
      });
      return;
    }

    var info = await DeviceInfoPlugin().androidInfo;
    bool huawei = info.brand.toLowerCase().contains("huawei");
    String model = info.model.toLowerCase();
    String manufacturer = info.manufacturer.toLowerCase();

    // You can expand arcoreBrands for more precision with official lists
    List<String> arcoreBrands = [
      "google", "samsung", "oneplus", "xiaomi", "motorola", "oppo", "realme", "asus", "sony"
    ];
    bool arcoreLikelySupported = arcoreBrands.any((brand) =>
      manufacturer.contains(brand) || model.contains(brand));

    setState(() {
      _isHuawei = huawei;
      _isIOS = false;
      if (!huawei && arcoreLikelySupported) {
        _arMode = 'arcore';
      } else if (huawei) {
        _arMode = 'huawei';
      } else {
        _arMode = 'marker';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_arMode == 'unknown') {
      return Scaffold(
        appBar: AppBar(title: const Text('AR Room Area Calculator')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('AR Room Area Calculator')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Mode: $_arMode"),
                const SizedBox(width: 12),
                if (_isHuawei == true) const Text("Huawei device"),
                if (_isIOS == true) const Text("iOS device"),
              ],
            ),
          ),
          Expanded(
            child: Builder(
              builder: (ctx) {
                if (_arMode == 'arcore' || _arMode == 'arkit') return _buildARCoreOrARKitView();
                if (_arMode == 'huawei') return _buildHuaweiARView();
                return _buildMarkerFallbackView();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Text("Points selected: ${points.length}"),
                Text("Estimated Area: ${calculatedArea.toStringAsFixed(2)} m²"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: points.isNotEmpty ? _resetPoints : null,
                      child: const Text("Reset"),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: points.length >= 3 ? () => _showACRecommendation(context) : null,
                      child: const Text("Suggest AC"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ARCore/ARKit (ar_flutter_plugin handles both platforms)
  Widget _buildARCoreOrARKitView() {
    return ARView(
      onARViewCreated: _onARViewCreated,
    );
  }

  void _onARViewCreated(
    ARSessionManager arSessionManager,
    ARObjectManager arObjectManager,
    ARAnchorManager arAnchorManager,
    ARLocationManager arLocationManager,
  ) {
    try {
      arSessionManager.onPlaneOrPointTap = (List<dynamic> hits) {
        if (hits.isNotEmpty) {
          var pos, x, y, z;
          try {
            pos = hits.first.worldTransform.getTranslation();
            x = pos.x;
            y = pos.y;
            z = pos.z;
          } catch (e) {
            pos = hits.first.position ?? hits.first;
            x = pos.x ?? 0.0;
            y = pos.y ?? 0.0;
            z = pos.z ?? 0.0;
          }
          setState(() {
            points.add(Vector3(x, y, z));
            if (points.length >= 3) {
              calculatedArea = _calculateArea(points);
            }
          });
        }
      };
    } catch (e) {
      print('AR session failed: $e');
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("AR Error"),
          content: Text('Initialization failed: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  // Huawei AR methods (huawei_ar package required)
  Widget _buildHuaweiARView() {
    return AREngineScene(
      ARSceneType.WORLD,
      ARSceneWorldConfig(
        objPath: "assets/your_model.obj",
        texturePath: "assets/your_texture.png",
        planeFindingMode: PlaneFindingMode.ENABLE,
      ),
      onArSceneCreated: _onHuaweiARViewCreated,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
    );
  }

  void _onHuaweiARViewCreated(ARSceneController arSceneController) {
    _arSceneController = arSceneController;
    // Extra Huawei-specific AR logic here if needed
  }

  // Marker/camera fallback for unsupported/old Android/iOS/Huawei devices
  Widget _buildMarkerFallbackView() {
    return FutureBuilder<List<CameraDescription>>(
      future: availableCameras(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
        _cameraController ??= CameraController(snapshot.data![0], ResolutionPreset.high);
        return FutureBuilder<void>(
          future: _cameraController!.initialize(),
          builder: (context, camSnap) {
            if (!camSnap.hasData) return Center(child: CircularProgressIndicator());
            return Stack(
              children: [
                CameraPreview(_cameraController!),
                Positioned(
                  bottom: 24,
                  left: 24,
                  right: 24,
                  child: ElevatedButton(
                    child: const Text("Capture and Measure (Camera Fallback)"),
                    onPressed: _markerFallbackMeasure,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Camera marker fallback - for OpenCV/ArUco integration (future-proof)
  Future<void> _markerFallbackMeasure() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    final image = await _cameraController!.takePicture();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Area Measurement'),
        content: Text('Image captured at: ${image.path}\nIntegrate marker (OpenCV/ArUco) detection logic here.'),
      ),
    );
  }


  double _calculateArea(List<Vector3> pts) {
    if (pts.length < 3) return 0.0;
    double area = 0.0;
    for (int i = 0; i < pts.length; i++) {
      final p1 = pts[i];
      final p2 = pts[(i + 1) % pts.length];
      area += (p1.x * p2.z) - (p2.x * p1.z);
    }
    return area.abs() / 2.0;
  }

  void _resetPoints() {
    setState(() {
      points.clear();
      calculatedArea = 0.0;
    });
  }

  void _showACRecommendation(BuildContext context) {
    String suggestion;
    if (calculatedArea <= 12) {
      suggestion = "0.75–1 HP AC (Small Room)";
    } else if (calculatedArea <= 25) {
      suggestion = "1–1.5 HP AC (Medium Room)";
    } else {
      suggestion = "2 HP+ AC (Large Room)";
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("AC Recommendation"),
        content: Text(
          "Detected area: ${calculatedArea.toStringAsFixed(2)} m²\nSuggested unit: $suggestion"
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _arSceneController?.dispose();
    _cameraController?.dispose();
    super.dispose();
  }
}
