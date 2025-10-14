  import 'dart:io';
  import 'package:flutter/material.dart';
  import 'package:image_picker/image_picker.dart';


  void main() {
    runApp(const MyApp());
  }

  // Main App with named routes
  class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        title: 'Photo Area Calculator',
        theme: ThemeData(primarySwatch: Colors.blue),
        // Register routes here
        routes: {
          '/': (context) => const AreaCalculatorPhotoPage(),
          '/products': (context) => const ProductsPage(),
        },
        initialRoute: '/',
      );
    }
  }

  class AreaCalculatorPhotoPage extends StatefulWidget {
    const AreaCalculatorPhotoPage({super.key});

    @override
    State<AreaCalculatorPhotoPage> createState() => _AreaCalculatorPhotoPageState();
  }

  class _AreaCalculatorPhotoPageState extends State<AreaCalculatorPhotoPage> {
    File? _image;
    final picker = ImagePicker();

    List<Offset> points = [];
    double calculatedArea = 0.0;

    double referenceLengthMeters = 1.0;
    double referenceLengthPixels = 100.0; // default for scaling

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: const Text("Photo Area Calculator")),
        body: Column(
          children: [
            Expanded(
              child: _image == null
                  ? Center(
                      child: ElevatedButton(
                        onPressed: _pickImage,
                        child: const Text("Take/Select Photo"),
                      ),
                    )
                  : GestureDetector(
                      onTapDown: (details) {
                        setState(() {
                          points.add(details.localPosition);
                          if (points.length >= 3) {
                            calculatedArea = calculateArea(points);
                          }
                        });
                      },
                      child: Stack(
                        children: [
                          Image.file(_image!, fit: BoxFit.contain, width: double.infinity),
                          ...points.map(
                            (p) => Positioned(
                              left: p.dx - 5,
                              top: p.dy - 5,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
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
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      _showACRecommendation(calculatedArea);
                    },
                    child: const Text("Suggest AC"),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Future<void> _pickImage() async {
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          points.clear();
          calculatedArea = 0.0;
        });
      }
    }

    // Shoelace formula for area calculation
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
        builder: (dialogCtx) => AlertDialog(
          title: const Text("AC Recommendation"),
          content: Text("Area: ${area.toStringAsFixed(2)} m²\n$suggestion"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogCtx);
              },
              child: const Text("OK"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogCtx);
                // Use rootNavigator and main context!
                Future.delayed(const Duration(milliseconds: 100), () {
                  Navigator.of(context, rootNavigator: true).pushNamed('/products');
                });
              },
              child: const Text("View Products"),
            ),
          ],
        ),
      );
    } 

  }
  // Sample ProductsPage Widget
  class ProductsPage extends StatelessWidget {
    const ProductsPage({super.key});

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: const Text("Products")),
        body: const Center(
          child: Text(
            "List of AC products will be shown here.",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }
  }
