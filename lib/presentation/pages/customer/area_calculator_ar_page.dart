import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/widgets/ar_view.dart';


class AreaCalculatorARPage extends StatefulWidget {
  const AreaCalculatorARPage({super.key});
  @override
  State<AreaCalculatorARPage> createState() => _AreaCalculatorARPageState();
}

class _AreaCalculatorARPageState extends State<AreaCalculatorARPage> {
  List<Vector3> points = [];
  double calculatedArea = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AR Room Area Calculator')),
      body: Column(
        children: [
          Expanded(
            child: ARView(
              onARViewCreated: _onARViewCreated,
              // planeDetectionConfig: PlaneDetectionConfig.horizontal, // add if you want, supported by some builds
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

  void _onARViewCreated(
    ARSessionManager arSessionManager,
    ARObjectManager arObjectManager,
    ARAnchorManager arAnchorManager,
    ARLocationManager arLocationManager,
  ) {
    arSessionManager.onPlaneOrPointTap = (List<dynamic> hits) {
      if (hits.isNotEmpty) {
        // Determine how to read position from hits (use print(hits.first) if needed)
        var pos, x, y, z;
        try {
          // Most versions support this:
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
  }

  double _calculateArea(List<Vector3> pts) {
    if (pts.length < 3) return 0.0;
    double area = 0.0;
    for (int i = 0; i < pts.length; i++) {
      final p1 = pts[i];
      final p2 = pts[(i + 1) % pts.length];
      area += (p1.x * p2.z) - (p2.x * p1.z);
    }
    return area.abs() / 2.0; // Area calculation for XZ plane.
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
}
