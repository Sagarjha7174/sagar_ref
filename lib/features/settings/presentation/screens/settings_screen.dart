import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/string_constants.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/theme/font_scale_provider.dart';
import '../../../recordings/presentation/providers/recordings_provider.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folderAsync = ref.watch(recordingFolderSettingProvider);
    final autoBackupFolderAsync = ref.watch(autoBackupFolderSettingProvider);
    final fontScale = ref.watch(fontScaleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          const _SectionHeader('Recordings'),
          _SettingsGroup(children: [
            _SettingsTile(
              icon: Icons.folder_outlined,
              title: Strings.recordingFolder,
              subtitle: folderAsync.value?.isNotEmpty == true
                  ? folderAsync.value!
                  : Strings.notConfigured,
              onTap: () => _pickFolder(context, ref),
            ),
            _SettingsTile(
              icon: Icons.delete_sweep_outlined,
              title: 'Discarded Recordings',
              subtitle: 'View and restore discarded recordings',
              onTap: () => context.push('/settings/discarded'),
            ),
          ]),

          const _SectionHeader('Backup & Restore'),
          const _BackupStatusCard(),
          const SizedBox(height: 8),
          _SettingsGroup(children: [
            _GoogleDriveTile(),
            _SettingsTile(
              icon: Icons.backup_table_outlined,
              title: 'Local Backup Folder',
              subtitle: autoBackupFolderAsync.value?.isNotEmpty == true
                  ? autoBackupFolderAsync.value!
                  : '${Strings.notConfigured} — tap to choose',
              onTap: () => _pickAutoBackupFolder(context, ref),
            ),
            _SettingsTile(
              icon: Icons.backup_outlined,
              title: 'Back Up Now',
              subtitle: 'Save to folder and Google Drive',
              trailing: const Icon(Icons.play_arrow_rounded),
              onTap: () => _backupDatabase(context, ref),
            ),
            _SettingsTile(
              icon: Icons.cloud_download_outlined,
              title: 'Restore from Google Drive',
              subtitle: 'Replace current data with the Drive backup',
              onTap: () => _restoreFromDrive(context, ref),
            ),
            _SettingsTile(
              icon: Icons.restore,
              title: 'Restore from File',
              subtitle: Strings.restoreSubtitle,
              onTap: () => _restoreDatabase(context, ref),
            ),
          ]),

          const _SectionHeader('Data'),
          _SettingsGroup(children: [
            _SettingsTile(
              icon: Icons.file_download_outlined,
              title: Strings.exportCsv,
              subtitle: Strings.exportCsvSubtitle,
              onTap: () => _exportCsv(context, ref),
            ),
          ]),

          const _SectionHeader('Appearance'),
          _SettingsGroup(children: [
            _FontSizeTile(fontScale: fontScale, ref: ref),
          ]),

          const _SectionHeader('About'),
          _SettingsGroup(children: [
            ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset('assets/images/logo.png', width: 44, height: 44),
              ),
              title: const Text(Strings.appName),
              subtitle: const Text(Strings.appInfo),
              shape: const RoundedRectangleBorder(),
            ),
          ]),
        ],
      ),
    );
  }

  // ===== ACTIONS =====

  void _snack(BuildContext context, String message, {Color? color, int seconds = 3}) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: seconds),
      ));
  }

  /// Shows a blocking progress dialog while [task] runs.
  Future<T> _withProgress<T>(
    BuildContext context,
    String message,
    Future<T> Function() task,
  ) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 24),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      ),
    );
    try {
      return await task();
    } finally {
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
    }
  }

  Future<void> _pickFolder(BuildContext context, WidgetRef ref) async {
    final path = await FilePicker.getDirectoryPath();
    if (path == null) return;

    final repo = ref.read(settingsRepositoryProvider);
    await repo.setRecordingFolderPath(path);

    // Clear scan cache since folder changed, then full rescan
    final recordingsRepo = ref.read(recordingsRepositoryProvider);
    await recordingsRepo.clearScanCache();
    ref.read(recordingsProvider.notifier).scan();

    if (context.mounted) _snack(context, Strings.folderUpdated, color: Colors.green);
  }

  Future<void> _exportCsv(BuildContext context, WidgetRef ref) async {
    final useCase = ref.read(exportComplaintsUseCaseProvider);
    final result = await useCase.call();
    if (!context.mounted) return;

    result.when(
      success: (filePath) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${Strings.exportSuccess} $filePath'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Share',
              textColor: Colors.white,
              onPressed: () => SharePlus.instance.share(
                ShareParams(files: [XFile(filePath)]),
              ),
            ),
          ),
        );
      },
      failure: (f) => _snack(context, f.message, color: Colors.red),
    );
  }

  Future<void> _backupDatabase(BuildContext context, WidgetRef ref) async {
    final dir = await ref.read(settingsRepositoryProvider).getAutoBackupFolderPath();
    if (!context.mounted) return;

    final result = await _withProgress(
      context,
      'Backing up…',
      () => ref.read(backupDatabaseUseCaseProvider).call(dir),
    );
    ref.invalidate(backupStatusProvider);
    if (!context.mounted) return;

    result.when(
      success: (message) => _snack(context, message, color: Colors.green.shade700, seconds: 5),
      failure: (f) => _snack(context, f.message, color: Colors.red, seconds: 5),
    );
  }

  Future<bool> _confirmRestore(BuildContext context, String details) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 36),
        title: const Text('Restore Database?'),
        content: Text('$details\n\n${Strings.restoreWarning}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(Strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  void _showRestoreResult(BuildContext context, Result<void> result) {
    if (!context.mounted) return;
    result.when(
      success: (_) {
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => PopScope(
            canPop: false,
            child: AlertDialog(
              icon: const Icon(Icons.check_circle, color: Colors.green, size: 36),
              title: const Text('Restore Successful'),
              content: const Text(
                'The database has been restored. The app will now close to '
                'apply the changes. Please reopen it.',
              ),
              actions: [
                FilledButton(
                  onPressed: () => exit(0),
                  child: const Text('Close App'),
                ),
              ],
            ),
          ),
        );
      },
      failure: (f) {
        showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text(Strings.error),
            content: Text(f.message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text(Strings.ok),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _restoreDatabase(BuildContext context, WidgetRef ref) async {
    final files = await FilePicker.pickFiles(type: FileType.any);
    final filePath = files.isEmpty ? null : files.single.path;
    if (filePath == null || !context.mounted) return;

    final ok = await _confirmRestore(
      context,
      'Restore from:\n${filePath.split('/').last}',
    );
    if (!ok || !context.mounted) return;

    final result = await _withProgress(
      context,
      'Restoring…',
      () => ref.read(restoreDatabaseUseCaseProvider).call(filePath),
    );
    if (context.mounted) _showRestoreResult(context, result);
  }

  Future<void> _restoreFromDrive(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(settingsRepositoryProvider);

    final infoResult = await _withProgress(
      context,
      'Checking Google Drive…',
      () => repo.getCloudBackupInfo(),
    );
    ref.invalidate(cloudAuthStatusProvider);
    if (!context.mounted) return;

    CloudBackupInfo? info;
    String? error;
    infoResult.when(success: (i) => info = i, failure: (f) => error = f.message);
    if (error != null) {
      _snack(context, error!, color: Colors.red, seconds: 5);
      return;
    }
    if (info == null) {
      _snack(context, 'No backup found on Google Drive yet.', color: Colors.orange);
      return;
    }

    final when = info!.modifiedTime?.toDisplayDateTime() ?? 'unknown time';
    final size = info!.sizeBytes == null
        ? ''
        : ' (${(info!.sizeBytes! / 1024).toStringAsFixed(0)} KB)';
    final ok = await _confirmRestore(context, 'Google Drive backup from $when$size.');
    if (!ok || !context.mounted) return;

    final result = await _withProgress(
      context,
      'Downloading and restoring…',
      () => repo.restoreFromCloud(),
    );
    if (context.mounted) _showRestoreResult(context, result);
  }

  Future<void> _pickAutoBackupFolder(BuildContext context, WidgetRef ref) async {
    final path = await FilePicker.getDirectoryPath();
    if (path == null) return;

    final repo = ref.read(settingsRepositoryProvider);
    await repo.setAutoBackupFolderPath(path);
    if (context.mounted) {
      _snack(context, 'Backup folder updated', color: Colors.green);
    }

    // Initial backup into the new folder if one is due.
    await repo.checkAndPerformAutoBackup();
    ref.invalidate(backupStatusProvider);
  }
}

// ===== WIDGETS =====

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(indent: 56),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
      shape: const RoundedRectangleBorder(),
    );
  }
}

class _GoogleDriveTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(cloudAuthStatusProvider).when(
          data: (isSignedIn) => _SettingsTile(
            icon: Icons.cloud_outlined,
            iconColor: Colors.blue,
            title: 'Google Drive',
            subtitle: isSignedIn
                ? 'Signed in — backs up automatically every day'
                : 'Tap to sign in and enable online backup',
            trailing: isSignedIn
                ? TextButton(
                    onPressed: () async {
                      await ref.read(settingsRepositoryProvider).signOutFromCloud();
                      ref.invalidate(cloudAuthStatusProvider);
                      ref.invalidate(backupStatusProvider);
                    },
                    child: const Text('Sign out'),
                  )
                : null,
            onTap: isSignedIn
                ? null
                : () async {
                    final repo = ref.read(settingsRepositoryProvider);
                    final success = await repo.signInToCloud();
                    ref.invalidate(cloudAuthStatusProvider);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(success
                          ? 'Signed in to Google Drive. Uploading first backup…'
                          : 'Google Sign-In failed or was cancelled.'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ));
                    if (success) {
                      await repo.checkAndPerformAutoBackup();
                      ref.invalidate(backupStatusProvider);
                    }
                  },
          ),
          loading: () => const ListTile(
            leading: SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            title: Text('Checking Google Drive…'),
          ),
          error: (_, _) => const _SettingsTile(
            icon: Icons.error_outline,
            iconColor: Colors.red,
            title: 'Google Drive',
            subtitle: 'Could not load sign-in status',
          ),
        );
  }
}

class _BackupStatusCard extends ConsumerWidget {
  const _BackupStatusCard();

  String _ago(DateTime? t) {
    if (t == null) return 'Never';
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'Just now';
    if (d.inHours < 1) return '${d.inMinutes} min ago';
    if (d.inDays < 1) return '${d.inHours} h ago';
    if (d.inDays < 7) return '${d.inDays} d ago';
    return t.toDisplayDateTime();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final status = ref.watch(backupStatusProvider).value;
    if (status == null) return const SizedBox.shrink();

    final now = DateTime.now();
    bool stale(DateTime? t) =>
        t == null || now.difference(t) > const Duration(hours: 48);

    final cloudOk = status.signedIn &&
        !status.cloudUploadPending &&
        !stale(status.lastCloudUpload);
    final localOk = status.localFolderSet && !stale(status.lastLocalBackup);
    final healthy = (status.signedIn || status.localFolderSet) &&
        (!status.signedIn || cloudOk) &&
        (!status.localFolderSet || localOk);

    final (Color color, IconData icon, String headline) = !status.signedIn &&
            !status.localFolderSet
        ? (Colors.orange, Icons.shield_outlined, 'Backups are off')
        : healthy
            ? (Colors.green, Icons.verified_user_outlined, 'Your data is backed up')
            : (Colors.orange, Icons.sync_problem, 'Backup needs attention');

    return Card(
      margin: EdgeInsets.zero,
      color: color.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(headline, style: theme.textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _StatusLine(
              icon: Icons.cloud_done_outlined,
              label: 'Google Drive',
              value: !status.signedIn
                  ? 'Not signed in'
                  : _ago(status.lastCloudUpload),
              ok: cloudOk,
            ),
            const SizedBox(height: 6),
            _StatusLine(
              icon: Icons.sd_storage_outlined,
              label: 'Local folder',
              value: !status.localFolderSet
                  ? 'Not set'
                  : _ago(status.lastLocalBackup),
              ok: localOk,
            ),
            if (status.cloudUploadPending) ...[
              const SizedBox(height: 10),
              Text(
                '${status.lastCloudError}\nIt will retry automatically.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({
    required this.icon,
    required this.label,
    required this.value,
    required this.ok,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(label, style: theme.textTheme.bodyMedium),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: ok ? Colors.green.shade700 : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 6),
        Icon(
          ok ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: ok ? Colors.green : theme.colorScheme.outline,
        ),
      ],
    );
  }
}

class _FontSizeTile extends StatelessWidget {
  final double fontScale;
  final WidgetRef ref;

  const _FontSizeTile({
    required this.fontScale,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const Icon(Icons.format_size),
          title: const Text('Font Size'),
          subtitle: Text('${(fontScale * 100).toStringAsFixed(0)}%'),
          trailing: fontScale != 1.0
              ? TextButton(
                  onPressed: () => ref.read(fontScaleProvider.notifier).reset(),
                  child: const Text('Reset'),
                )
              : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              const Icon(Icons.text_fields, size: 16),
              Expanded(
                child: Slider(
                  value: fontScale,
                  min: minFontScale,
                  max: maxFontScale,
                  divisions: 7,
                  label: '${(fontScale * 100).toStringAsFixed(0)}%',
                  onChanged: (value) {
                    ref.read(fontScaleProvider.notifier).setScale(value);
                  },
                ),
              ),
              const Icon(Icons.text_fields, size: 28),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.settings_suggest,
                  size: 24 * fontScale,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Preview Text Size',
                    style: TextStyle(
                      fontSize: 14 * fontScale,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
