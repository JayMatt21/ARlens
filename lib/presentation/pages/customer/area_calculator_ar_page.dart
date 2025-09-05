import 'package:ar_flutter_plugin_updated/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin_updated/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_updated/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_updated/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_updated/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_updated/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_updated/models/ar_node.dart';
import 'package:ar_flutter_plugin_updated/widgets/ar_view.dart';
import 'package:ar_flutter_plugin_updated/datatypes/config_planedetection.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm;


class AreaCalculatorARPage extends StatefulWidget {
  const AreaCalculatorARPage({super.key});

  @override
  State<AreaCalculatorARPage> createState() => _AreaCalculatorARPageState();
}

class _AreaCalculatorARPageState extends State<AreaCalculatorARPage> {
  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;
  late ARAnchorManager arAnchorManager;
  late ARLocationManager arLocationManager;

  List<vm.Vector3> points = [];
  double calculatedArea = 0.0;

  @override
  void dispose() {
    arSessionManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AR Area Calculator")),
      body: Stack(
        children: [
          ARView(
            onARViewCreated: onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.horizontal,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Card(
              color: Colors.white70,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Points tapped: ${points.length}"),
                    const SizedBox(height: 4),
                    Text("Estimated area: ${calculatedArea.toStringAsFixed(2)} m²"),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          points.clear();
                          calculatedArea = 0.0;
                        });
                      },
                      child: const Text("Reset"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void onARViewCreated(
    ARSessionManager sessionManager,
    ARObjectManager objectManager,
    ARAnchorManager anchorManager,
    ARLocationManager locationManager,
  ) {
    arSessionManager = sessionManager;
    arObjectManager = objectManager;
    arAnchorManager = anchorManager;
    arLocationManager = locationManager;

    arSessionManager.onInitialize(
      showFeaturePoints: true,
      showPlanes: true,
      showWorldOrigin: true,
      customPlaneTexturePath: "assets/triangle.png",
    );

    arObjectManager.onInitialize();

    arSessionManager.onPlaneOrPointTap = (hits) async {
      final hit = hits.first;
      final position = hit.worldTransform.getTranslation();
      points.add(position);

      final node = ARNode(
        type: NodeType.localGLTF2,
        uri: "assets/sphere.glb", 
        position: position,
        scale: vm.Vector3(0.05, 0.05, 0.05),
      );

      await arObjectManager.addNode(node);

      if (points.length >= 3) {
        calculatedArea = calculateArea(points);
      }

      setState(() {});
    };
  }

  double calculateArea(List<vm.Vector3> pts) {
    if (pts.length < 3) return 0.0;

    double sum = 0.0;
    for (int i = 0; i < pts.length; i++) {
      final p1 = pts[i];
      final p2 = pts[(i + 1) % pts.length];
      sum += (p1.x * p2.z) - (p2.x * p1.z);
    }
    return sum.abs() / 2.0;
  }
}
