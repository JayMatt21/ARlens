import 'package:arlens/presentation/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:arlens/presentation/pages/customer/products_page.dart';


class AreaCalculatorPage extends StatefulWidget {
  const AreaCalculatorPage({super.key});

  @override
  State<AreaCalculatorPage> createState() => _AreaCalculatorPageState();
}

class _AreaCalculatorPageState extends State<AreaCalculatorPage> {
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  String _unit = 'm'; // m or ft

  @override
  void dispose() {
    _lengthController.dispose();
    _widthController.dispose();
    super.dispose();
  }

  double? _parseInput(String text) {
    final v = double.tryParse(text.replaceAll(',', '.'));
    return v;
  }

  double _toSquareMeters(double area, String unit) {
    if (unit == 'ft') {
      return area * 0.092903; // sq ft to sq m
    }
    return area;
  }

  void _calculateAndRecommend() {
    final l = _parseInput(_lengthController.text);
    final w = _parseInput(_widthController.text);

    if (l == null || w == null || l <= 0 || w <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid positive numbers for length and width')),
      );
      return;
    }

    final rawArea = l * w;
    final areaSqM = _toSquareMeters(rawArea, _unit);

    String suggestion;
    if (areaSqM <= 12) {
      suggestion = "0.75–1 HP AC (Small Room)";
    } else if (areaSqM <= 25) {
      suggestion = "1–1.5 HP AC (Medium Room)";
    } else {
      suggestion = "2 HP+ AC (Large Room)";
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('AC Recommendation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Computed area: ${areaSqM.toStringAsFixed(2)} m²'),
            const SizedBox(height: 8),
            Text(suggestion, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          CustomButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProductsPage()),
              );
            },
            child: const Text('View Products'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Area Calculator'),
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _lengthController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Length',
                              hintText: 'e.g. 4.5',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _widthController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Width',
                              hintText: 'e.g. 3.0',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Units:'),
                        const SizedBox(width: 12),
                        ToggleButtons(
                          isSelected: [_unit == 'm', _unit == 'ft'],
                          onPressed: (index) {
                            setState(() {
                              _unit = index == 0 ? 'm' : 'ft';
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          children: const [
                            Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('meters (m)')),
                            Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('feet (ft)')),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      onPressed: _calculateAndRecommend,
                      child: const Text('Calculate & Recommend'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: Opacity(
                  opacity: 0.9,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.ac_unit, size: 80, color: theme.colorScheme.primary),
                      const SizedBox(height: 12),
                      Text(
                        'Get recommended ACs\nand view available products',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}