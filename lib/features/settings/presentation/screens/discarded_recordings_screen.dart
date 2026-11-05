import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/string_constants.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/widgets/audio_player_bottom_sheet.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../recordings/domain/entities/recording_item.dart';
import '../providers/discarded_recordings_provider.dart';

class DiscardedRecordingsScreen extends ConsumerWidget {
  const DiscardedRecordingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(discardedRecordingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discarded Recordings'),
      ),
      body: _buildBody(context, ref, state, theme),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    DiscardedRecordingsState state,
    ThemeData theme,
  ) {
    if (state.isLoading) {
      return const LoadingWidget();
    }

    if (state.error != null) {
      return ErrorStateWidget(
        message: state.error!,
        onRetry: () => ref.read(discardedRecordingsProvider.notifier).loadDiscarded(),
      );
    }

    if (state.recordings.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.delete_sweep_outlined,
        title: 'No discarded recordings',
        subtitle: 'Recordings you discard will appear here.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: state.recordings.length,
      itemBuilder: (context, index) {
        final recording = state.recordings[index];
        final fileExists = File(recording.filePath).existsSync();

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recording.contactName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            recording.phoneNumber,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            recording.recordedAt.toDisplayDateTime(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (fileExists)
                      IconButton.filledTonal(
                        onPressed: () => AudioPlayerBottomSheet.show(
                          context,
                          filePath: recording.filePath,
                          title: recording.contactName,
                        ),
                        icon: const Icon(Icons.play_arrow),
                        tooltip: 'Play recording',
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'File Missing',
                          style: TextStyle(
                            color: theme.colorScheme.onErrorContainer,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Restore Button
                    TextButton.icon(
                      onPressed: () => _confirmRestore(context, ref, recording),
                      icon: const Icon(Icons.restore, size: 18),
                      label: const Text('Restore'),
                    ),
                    const SizedBox(width: 8),
                    // Create Complaint Button
                    FilledButton.icon(
                      onPressed: () => _confirmCreateComplaint(context, ref, recording),
                      icon: const Icon(Icons.add_comment_outlined, size: 18),
                      label: const Text('Create Complaint'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmRestore(
    BuildContext context,
    WidgetRef ref,
    RecordingItem recording,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore Recording?'),
        content: const Text(
          'This recording will be moved back to your active recordings list. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(Strings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref
          .read(discardedRecordingsProvider.notifier)
          .restoreRecording(recording.filePath);

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recording restored.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _confirmCreateComplaint(
    BuildContext context,
    WidgetRef ref,
    RecordingItem recording,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Complaint?'),
        content: const Text(
          'This will restore the recording and open the complaint creation screen. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(Strings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Restore recording so it is no longer marked as discarded
      final success = await ref
          .read(discardedRecordingsProvider.notifier)
          .restoreRecording(recording.filePath);

      if (success && context.mounted) {
        // Close screen and push the create complaint route
        context.pop();
        context.push('/complaints/create', extra: recording);
      }
    }
  }
}
