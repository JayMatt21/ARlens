import 'package:flutter/material.dart';
import 'package:arlens/presentation/widgets/custom_button.dart';
import 'package:arlens/presentation/widgets/custom_card.dart';

/// A simple, reusable error UI with optional retry action.
/// Use [title] for a short heading and [message] for details.
/// Provide [onRetry] to show a retry button.
class AppErrorWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onRetry;
  final String retryLabel;
  final IconData icon;

  const AppErrorWidget({
    super.key,
    this.title,
    this.message,
    this.onRetry,
    this.retryLabel = 'Retry',
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = theme.colorScheme.error;
    return Center(
      child: CustomCard(
        padding: const EdgeInsets.all(20),
        elevation: 4,
        borderRadius: 12,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: iconColor),
            const SizedBox(height: 12),
            if (title != null)
              Text(
                title!,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: 160,
                child: CustomButton(
                  onPressed: onRetry,
                  label: retryLabel,
                  filled: true,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}