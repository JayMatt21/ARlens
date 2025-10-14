// ...new file...
import 'package:flutter/material.dart';

/// A flexible, theme-aware card used across the app to provide a consistent
/// futuristic/clean UI foundation. Use [title]/[subtitle] for simple headers,
/// or pass a full [child] for custom content. Tap handling and trailing widgets
/// are supported.
class CustomCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Widget? child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double elevation;
  final double borderRadius;
  final Color? color;

  const CustomCard({
    Key? key,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
    this.elevation = 6,
    this.borderRadius = 12,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.cardColor;
    final titleStyle = theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700);
    final subtitleStyle = theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color);

    return Padding(
      padding: margin,
      child: Material(
        color: cardColor,
        elevation: elevation,
        borderRadius: BorderRadius.circular(borderRadius),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: Container(
            padding: padding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null || subtitle != null || leading != null || trailing != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (leading != null) ...[
                        leading!,
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (title != null)
                              Text(title!, style: titleStyle),
                            if (subtitle != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(subtitle!, style: subtitleStyle),
                              ),
                          ],
                        ),
                      ),
                      if (trailing != null) ...[
                        const SizedBox(width: 12),
                        trailing!,
                      ],
                    ],
                  ),
                if (child != null) ...[
                  if (title != null || subtitle != null || leading != null || trailing != null)
                    const SizedBox(height: 12),
                  child!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}