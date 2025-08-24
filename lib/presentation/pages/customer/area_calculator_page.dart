import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/area_calculator/area_calculator_bloc.dart';

class AreaCalculatorPage extends StatelessWidget {
  const AreaCalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AreaCalculatorBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Area Calculator"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.photo_camera, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              const Text(
                "Use your camera to measure room area",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
             
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Camera feature coming soon")),
                  );
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text("Open Camera"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
