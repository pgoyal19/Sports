import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FeedbackCard extends StatelessWidget {
  final String title;
  final String message;
  final FeedbackType type;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;
  final String? actionText;

  const FeedbackCard({
    super.key,
    required this.title,
    required this.message,
    required this.type,
    this.onDismiss,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getBorderColor(),
          width: 1,
        ),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getIcon(),
                  color: _getIconColor(),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: _getTextColor(),
                    ),
                  ),
                ),
                if (onDismiss != null)
                  IconButton(
                    onPressed: onDismiss,
                    icon: const Icon(Icons.close),
                    color: _getTextColor(),
                    iconSize: 20,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _getTextColor().withOpacity(0.8),
              ),
            ),
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onAction,
                  child: Text(
                    actionText!,
                    style: TextStyle(
                      color: _getIconColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (type) {
      case FeedbackType.success:
        return AppTheme.success.withOpacity(0.1);
      case FeedbackType.warning:
        return AppTheme.warning.withOpacity(0.1);
      case FeedbackType.error:
        return AppTheme.error.withOpacity(0.1);
      case FeedbackType.info:
        return AppTheme.info.withOpacity(0.1);
    }
  }

  Color _getBorderColor() {
    switch (type) {
      case FeedbackType.success:
        return AppTheme.success.withOpacity(0.3);
      case FeedbackType.warning:
        return AppTheme.warning.withOpacity(0.3);
      case FeedbackType.error:
        return AppTheme.error.withOpacity(0.3);
      case FeedbackType.info:
        return AppTheme.info.withOpacity(0.3);
    }
  }

  Color _getIconColor() {
    switch (type) {
      case FeedbackType.success:
        return AppTheme.success;
      case FeedbackType.warning:
        return AppTheme.warning;
      case FeedbackType.error:
        return AppTheme.error;
      case FeedbackType.info:
        return AppTheme.info;
    }
  }

  Color _getTextColor() {
    switch (type) {
      case FeedbackType.success:
        return AppTheme.success;
      case FeedbackType.warning:
        return AppTheme.warning;
      case FeedbackType.error:
        return AppTheme.error;
      case FeedbackType.info:
        return AppTheme.info;
    }
  }

  IconData _getIcon() {
    switch (type) {
      case FeedbackType.success:
        return Icons.check_circle;
      case FeedbackType.warning:
        return Icons.warning;
      case FeedbackType.error:
        return Icons.error;
      case FeedbackType.info:
        return Icons.info;
    }
  }
}

enum FeedbackType {
  success,
  warning,
  error,
  info,
}
