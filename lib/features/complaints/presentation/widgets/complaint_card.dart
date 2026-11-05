import 'package:flutter/material.dart';
import '../../../../core/constants/string_constants.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/complaint.dart';

class ComplaintCard extends StatelessWidget {
  const ComplaintCard({
    super.key,
    required this.complaint,
    required this.onCall,
    required this.onComplete,
    required this.onReject,
    this.onTap,
  });

  final Complaint complaint;
  final VoidCallback onCall;
  final VoidCallback onComplete;
  final VoidCallback onReject;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      complaint.customerName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    alignment: WrapAlignment.end,
                    children: complaint.applianceTypes
                        .map((type) => _ApplianceChip(type: type))
                        .toList(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                complaint.phoneNumber,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                complaint.createdAt.toDisplayDateTime(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onCall,
                    icon: const Icon(Icons.call, size: 18),
                    label: const Text(Strings.call),
                    style: TextButton.styleFrom(foregroundColor: Colors.green),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: onComplete,
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text(Strings.complete),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text(Strings.reject),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApplianceChip extends StatelessWidget {
  const _ApplianceChip({required this.type});

  final ApplianceType type;

  Color get _color => AppTheme.applianceColor(type.displayName);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Text(
        type.displayName,
        style: TextStyle(
          color: _color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
