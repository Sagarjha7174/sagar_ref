import 'package:flutter/material.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../complaints/domain/entities/complaint.dart';

class HistoryCard extends StatelessWidget {
  const HistoryCard({
    super.key,
    required this.complaint,
    required this.onTap,
    required this.onReopen,
    this.onDelete,
  });

  final Complaint complaint;
  final VoidCallback onTap;
  final VoidCallback onReopen;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            complaint.customerName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        StatusBadge(
                          status: complaint.status.displayName,
                          small: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${complaint.phoneNumber}  •  ${complaint.applianceTypes.map((e) => e.displayName).join(', ')}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          _getDisplayDate(complaint),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                        ),
                        if (complaint.status == ComplaintStatus.completed &&
                            complaint.amountEarned != null) ...[
                          const Spacer(),
                          Text(
                            '₹${complaint.amountEarned!.toStringAsFixed(0)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (complaint.status == ComplaintStatus.completed &&
                        complaint.amountPending != null &&
                        complaint.amountPending! > 0) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Colors.red.shade200,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.warning_amber_rounded, size: 12, color: Colors.red.shade800),
                            const SizedBox(width: 4),
                            Text(
                              'Amount pending to collect: ₹${complaint.amountPending!.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: Colors.red.shade800,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.replay, size: 20),
                    tooltip: 'Reopen',
                    onPressed: onReopen,
                  ),
                  if (complaint.status == ComplaintStatus.rejected && onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      tooltip: 'Delete',
                      onPressed: onDelete,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDisplayDate(Complaint complaint) {
    if (complaint.status == ComplaintStatus.completed && complaint.completedAt != null) {
      return complaint.completedAt!.toDisplayDate();
    } else if (complaint.status == ComplaintStatus.rejected && complaint.rejectedAt != null) {
      return complaint.rejectedAt!.toDisplayDate();
    }
    return complaint.createdAt.toDisplayDate();
  }
}
