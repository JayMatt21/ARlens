import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:image_picker/image_picker.dart';
import 'package:arlens/presentation/bloc/area_calculator/area_calculator_bloc.dart';
import 'package:arlens/domain/usecases/calculate_area.dart';
import 'package:arlens/presentation/pages/customer/area_calculator_ar_page.dart';

class AreaCalculatorPage extends StatelessWidget {
  const AreaCalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    // final ImagePicker picker = ImagePicker();

    return BlocProvider(
      create: (_) => AreaCalculatorBloc(
         calculateAreaUseCase: CalculateAreaUseCase(),
      ),
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
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AreaCalculatorPhotoPage()),
                  );
                },
                child: const Text("Open AR Area Calculator"),
              )
            ],
          ),
        ),
      ),
    );
  }
}