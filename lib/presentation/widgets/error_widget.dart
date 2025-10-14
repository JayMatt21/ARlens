import 'package:flutter/material.dart';

/// A small, theme-aware loading widget. Use [message] to show a caption
/// under the spinner. By default the content is centered.
class LoadingWidget extends StatelessWidget {
  final String? message;
  final double size;
  final double strokeWidth;
  final bool centered;

  const LoadingWidget({
    Key? key,
    this.message,
    this.size = 36.0,
    this.strokeWidth = 3.0,
    this.centered = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: size,
          width: size,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(primary),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 12),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ],
    );

    return centered
        ? Center(child: content)
        : Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: content);
  }
}