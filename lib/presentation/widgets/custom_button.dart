import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? label;
  final Widget? child;
  final bool filled;
  final EdgeInsetsGeometry padding;
  final double elevation;
  final bool enabled;

  const CustomButton({
    super.key,
    required this.onPressed,
    this.label,
    this.child,
    this.filled = true,
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
    this.elevation = 2,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final Widget content = child ??
        (label != null
            ? Text(label!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))
            : const SizedBox.shrink());

    if (filled) {
      return ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: padding,
          elevation: elevation,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        child: content,
      );
    } else {
      return TextButton(
        onPressed: enabled ? onPressed : null,
        style: TextButton.styleFrom(
          foregroundColor: color,
          padding: padding,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        child: content,
      );
    }
  }
}