import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/string_constants.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/complaint.dart';
import '../../domain/usecases/complete_complaint_use_case.dart';
import '../providers/pending_complaints_provider.dart';
import '../../../history/presentation/providers/history_provider.dart';
import '../widgets/complaint_card.dart';
import '../widgets/complete_complaint_dialog.dart';
import '../widgets/reject_complaint_dialog.dart';

class ComplaintsScreen extends ConsumerWidget {
  const ComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final complaintsAsync = ref.watch(pendingComplaintsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.pendingComplaints),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add Complaint Manually',
            onPressed: () => context.push('/complaints/create-manual'),
          ),
        ],
      ),
      body: complaintsAsync.when(
        loading: () => const LoadingWidget(),
        error: (error, _) => ErrorStateWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(pendingComplaintsNotifierProvider),
        ),
        data: (complaints) {
          if (complaints.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.assignment_outlined,
              title: Strings.noPendingComplaints,
              subtitle: 'Create a complaint from Recordings or tap + above',
              actionLabel: 'Add Complaint',
              onAction: () => context.push('/complaints/create-manual'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final complaint = complaints[index];
              return ComplaintCard(
                complaint: complaint,
                onCall: () => _callNumber(context, complaint.phoneNumber),
                onComplete: () => _showCompleteDialog(context, ref, complaint),
                onReject: () => _showRejectDialog(context, ref, complaint),
                onTap: () => context.push('/complaints/${complaint.id}'),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _callNumber(BuildContext context, String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch dialer'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCompleteDialog(
    BuildContext context,
    WidgetRef ref,
    Complaint complaint,
  ) {
    showDialog(
      context: context,
      builder: (_) => CompleteComplaintDialog(
        onComplete: (earnedAmount, collectedAmount, pendingAmount, notes, imagePath) async {
          final useCase = ref.read(completeComplaintUseCaseProvider);
          final result = await useCase.call(CompleteComplaintParams(
            id: complaint.id,
            amountEarned: earnedAmount,
            amountCollected: collectedAmount,
            amountPending: pendingAmount,
            completionNotes: notes,
            imagePath: imagePath,
          ));
          if (context.mounted) {
            result.when(
              success: (_) {
                ref.invalidate(pendingComplaintsNotifierProvider);
                ref.invalidate(dashboardProvider);
                ref.invalidate(historyNotifierProvider);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${Strings.complaintCompleted} ₹${earnedAmount.toStringAsFixed(0)} recorded.'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              failure: (f) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(f.message),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  void _showRejectDialog(
    BuildContext context,
    WidgetRef ref,
    Complaint complaint,
  ) {
    showDialog(
      context: context,
      builder: (_) => RejectComplaintDialog(
        customerName: complaint.customerName,
        onReject: () async {
          final useCase = ref.read(rejectComplaintUseCaseProvider);
          final result = await useCase.call(complaint.id);
          if (context.mounted) {
            result.when(
              success: (_) {
                ref.invalidate(pendingComplaintsNotifierProvider);
                ref.invalidate(dashboardProvider);
                ref.invalidate(historyNotifierProvider);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(Strings.complaintRejected),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              failure: (f) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(f.message),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
