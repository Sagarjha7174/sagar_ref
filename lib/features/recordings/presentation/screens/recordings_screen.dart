import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/string_constants.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/widgets/audio_player_bottom_sheet.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/recording_item.dart';
import '../providers/recordings_provider.dart';
import '../widgets/recording_card.dart';

class RecordingsScreen extends ConsumerWidget {
  const RecordingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recordingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.recordings),
        bottom: state.isRefreshing
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: state.isLoading || state.isRefreshing
                ? null
                : () => ref.read(recordingsProvider.notifier).scan(),
            tooltip: Strings.rescan,
          ),
        ],
      ),
      body: _buildBody(context, ref, state),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, RecordingsState state) {
    if (state.isLoading) {
      return const LoadingWidget(message: Strings.scanning);
    }

    if (state.error != null) {
      // Check if it's a permission error
      if (state.error!.contains('Permission') || state.error!.contains('permission')) {
        return _PermissionDeniedWidget(
          onGrant: () async {
            final permService = ref.read(permissionServiceProvider);
            await permService.requestAllPermissions();
            ref.read(recordingsProvider.notifier).scan();
          },
        );
      }
      return ErrorStateWidget(
        message: state.error!,
        onRetry: () => ref.read(recordingsProvider.notifier).scan(),
      );
    }

    if (state.isFolderNotConfigured) {
      return EmptyStateWidget(
        icon: Icons.folder_off,
        title: Strings.noFolderConfigured,
        subtitle: Strings.noFolderConfiguredSubtitle,
        actionLabel: Strings.goToSettings,
        onAction: () => context.go('/settings'),
      );
    }

    if (state.recordings.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.mic_off,
        title: Strings.noRecordingsFound,
        subtitle: Strings.noRecordingsSubtitle,
        actionLabel: Strings.rescan,
        onAction: () => ref.read(recordingsProvider.notifier).scan(),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(recordingsProvider.notifier).scan(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: state.recordings.length,
        itemBuilder: (context, index) {
          final recording = state.recordings[index];
          return RecordingCard(
            recording: recording,
            onPlay: () => _playRecording(context, recording),
            onCall: () => _callNumber(context, recording.phoneNumber),
            onCreateComplaint: () => _createComplaint(context, recording),
            onDiscard: () => _discardRecording(context, ref, recording),
          );
        },
      ),
    );
  }

  void _playRecording(BuildContext context, RecordingItem recording) {
    AudioPlayerBottomSheet.show(
      context,
      filePath: recording.filePath,
      title: recording.contactName,
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

  void _createComplaint(BuildContext context, RecordingItem recording) {
    context.push('/complaints/create', extra: recording);
  }

  void _discardRecording(
    BuildContext context,
    WidgetRef ref,
    RecordingItem recording,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(Strings.discardConfirmTitle),
        content: const Text(Strings.discardConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(Strings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(recordingsProvider.notifier).discardRecording(recording);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(Strings.recordingDiscarded),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(Strings.discard),
          ),
        ],
      ),
    );
  }
}

class _PermissionDeniedWidget extends StatelessWidget {
  const _PermissionDeniedWidget({required this.onGrant});

  final VoidCallback onGrant;

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.security,
      title: Strings.permissionsDenied,
      subtitle: Strings.permissionsExplanation,
      actionLabel: Strings.grantPermissions,
      onAction: onGrant,
    );
  }
}
