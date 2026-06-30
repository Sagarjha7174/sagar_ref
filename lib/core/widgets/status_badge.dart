import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
    this.small = false,
  });

  final String status;
  final bool small;

  Color get _backgroundColor {
    return switch (status.toLowerCase()) {
      'pending' => AppTheme.pendingColor,
      'completed' => AppTheme.completedColor,
      'rejected' => AppTheme.rejectedColor,
      _ => Colors.grey,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 12,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _backgroundColor.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _backgroundColor,
          fontSize: small ? 11 : 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
