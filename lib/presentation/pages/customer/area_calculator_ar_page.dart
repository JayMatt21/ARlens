import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart';

class AreaCalculatorARPage extends StatefulWidget {
  const AreaCalculatorARPage({super.key});
  @override
  State<AreaCalculatorARPage> createState() => _AreaCalculatorARPageState();
}

class _AreaCalculatorARPageState extends State<AreaCalculatorARPage> {
  List<Vector3> points = [];
  double calculatedArea = 0.0;
  String status = "Move your phone slowly to detect floor plane.";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AR Room Area Calculator")),
      body: Column(
        children: [
          Expanded(
            child: ARView(
              onARViewCreated: _onARViewCreated,
              planeDetectionConfig: PlaneDetectionConfig.horizontal,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Text(status),
                Text("Points: ${points.length}"),
                Text("Estimated Area: ${calculatedArea.toStringAsFixed(2)} m²"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _resetPoints,
                      child: const Text("Reset"),
                    ),
                    const SizedBox(width: 10),
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

  void _onARViewCreated(ARViewController controller) {
    controller.onPlaneTap = (List<ARPlaneTapResult> hits) {
      if (hits.isNotEmpty) {
        final pos = hits.first.worldTransform.getTranslation();
        setState(() {
          points.add(Vector3(pos.x, pos.y, pos.z));
          status = "Tap corners. At least 3 points are needed.";
          if (points.length >= 3) {
            calculatedArea = _calculateArea(points);
            status = "Area calculated. Add more points or press 'Suggest AC'.";
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
    return area.abs() / 2.0;
  }

  void _resetPoints() {
    setState(() {
      points.clear();
      calculatedArea = 0.0;
      status = "Move your phone slowly to detect plane.";
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
          "Detected room area: ${calculatedArea.toStringAsFixed(2)} m²\n\nSuggested unit: $suggestion"
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
