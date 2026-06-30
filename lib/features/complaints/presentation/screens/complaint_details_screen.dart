import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/string_constants.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/widgets/audio_player_bottom_sheet.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/complaint.dart';
import '../providers/pending_complaints_provider.dart';
import '../providers/complaint_details_provider.dart';
import '../../../history/presentation/providers/history_provider.dart';

class ComplaintDetailsScreen extends ConsumerWidget {
  const ComplaintDetailsScreen({super.key, required this.complaintId});

  final int complaintId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(complaintDetailsNotifierProvider(complaintId));

    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.complaintDetails),
      ),
      body: detailsAsync.when(
        loading: () => const LoadingWidget(),
        error: (error, _) => ErrorStateWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(complaintDetailsNotifierProvider(complaintId)),
        ),
        data: (complaint) {
          if (complaint == null) {
            return const ErrorStateWidget(message: 'Complaint not found');
          }
          return _ComplaintDetailsBody(
            complaint: complaint,
            onReopen: () => _reopenComplaint(context, ref, complaint),
          );
        },
      ),
    );
  }

  Future<void> _reopenComplaint(
    BuildContext context,
    WidgetRef ref,
    Complaint complaint,
  ) async {
    final useCase = ref.read(reopenComplaintUseCaseProvider);
    final result = await useCase.call(complaint.id);

    if (context.mounted) {
      result.when(
        success: (_) {
          ref.invalidate(pendingComplaintsNotifierProvider);
          ref.invalidate(dashboardProvider);
          ref.invalidate(historyNotifierProvider);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(Strings.complaintReopened),
              backgroundColor: Colors.green,
            ),
          );
        },
        failure: (f) {
          if (f.message.contains('pending')) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text(Strings.cannotReopen),
                content: const Text(Strings.cannotReopenBody),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(Strings.ok),
                  ),
                ],
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(f.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );
    }
  }
}

class _ComplaintDetailsBody extends StatelessWidget {
  const _ComplaintDetailsBody({
    required this.complaint,
    required this.onReopen,
  });

  final Complaint complaint;
  final VoidCallback onReopen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Section 1: Customer Info
        _SectionCard(
          title: Strings.customerInfo,
          children: [
            _DetailRow(label: Strings.customerName, value: complaint.customerName),
            _DetailRowWithAction(
              label: Strings.phoneNumber,
              value: complaint.phoneNumber,
              action: IconButton(
                icon: const Icon(Icons.call, color: Colors.green),
                onPressed: () => _callNumber(context, complaint.phoneNumber),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Section 2: Complaint Info
        _SectionCard(
          title: Strings.complaintInfo,
          children: [
            _DetailRow(
              label: Strings.applianceType,
              value: complaint.applianceTypes.map((e) => e.displayName).join(', '),
            ),
            Row(
              children: [
                Text(
                  '${Strings.status}:  ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                StatusBadge(status: complaint.status.displayName),
              ],
            ),
            _DetailRow(
              label: Strings.createdDate,
              value: complaint.createdAt.toDisplayDateTime(),
            ),
          ],
        ),
        const SizedBox(height: 12),



        // Section 4: Notes
        _SectionCard(
          title: Strings.notes,
          children: [
            Text(
              complaint.notes ?? '-',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),

        // Section 5: Completion Info
        if (complaint.status == ComplaintStatus.completed) ...[
          const SizedBox(height: 12),
          _SectionCard(
            title: Strings.completionInfo,
            children: [
              _DetailRow(
                label: Strings.amountEarned,
                value: '₹${complaint.amountEarned?.toStringAsFixed(0) ?? '0'}',
              ),
              _DetailRow(
                label: Strings.completedDate,
                value: complaint.completedAt?.toDisplayDateTime() ?? '-',
              ),
              _DetailRow(
                label: Strings.completionNotes,
                value: complaint.completionNotes ?? '-',
              ),
              if (complaint.imagePath != null && complaint.imagePath!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Captured Work Photo:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(complaint.imagePath!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        color: Colors.grey.shade100,
                        child: Row(
                          children: [
                            Icon(Icons.broken_image, color: Colors.grey.shade400),
                            const SizedBox(width: 8),
                            const Text(
                              'Failed to load image',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ],

        // Section 6: Rejection Info
        if (complaint.status == ComplaintStatus.rejected) ...[
          const SizedBox(height: 12),
          _SectionCard(
            title: Strings.rejectionInfo,
            children: [
              _DetailRow(
                label: Strings.rejectedDate,
                value: complaint.rejectedAt?.toDisplayDateTime() ?? '-',
              ),
            ],
          ),
        ],

        const SizedBox(height: 24),

        // Action Buttons
        _buildActions(context),
        const SizedBox(height: 16),
      ],
    );
  }



  Widget _buildActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (complaint.status == ComplaintStatus.completed ||
            complaint.status == ComplaintStatus.rejected)
          OutlinedButton.icon(
            onPressed: onReopen,
            icon: const Icon(Icons.replay),
            label: const Text(Strings.reopen),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        const SizedBox(height: 8),
        FilledButton.tonalIcon(
          onPressed: () => _callNumber(context, complaint.phoneNumber),
          icon: const Icon(Icons.call),
          label: const Text(Strings.callCustomer),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
        ),
      ],
    );
  }

  Future<void> _callNumber(BuildContext context, String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRowWithAction extends StatelessWidget {
  const _DetailRowWithAction({
    required this.label,
    required this.value,
    required this.action,
  });

  final String label;
  final String value;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          action,
        ],
      ),
    );
  }
}
