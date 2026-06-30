import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/string_constants.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/theme/font_scale_provider.dart';
import '../../../recordings/presentation/providers/recordings_provider.dart';

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
        children: [
          // Recording Folder
          ListTile(
            leading: const Icon(Icons.folder),
            title: const Text(Strings.recordingFolder),
            subtitle: Text(
              folderAsync.value?.isNotEmpty == true
                  ? folderAsync.value!
                  : Strings.notConfigured,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _pickFolder(context, ref),
          ),
          const Divider(),

          // Discarded Recordings
          ListTile(
            leading: const Icon(Icons.delete_sweep_outlined),
            title: const Text('Discarded Recordings'),
            subtitle: const Text('View and restore discarded recordings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/discarded'),
          ),
          const Divider(),

          // Font Size Management
          _FontSizeTile(fontScale: fontScale, ref: ref),
          const Divider(),

          // CSV Export
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text(Strings.exportCsv),
            subtitle: const Text(Strings.exportCsvSubtitle),
            onTap: () => _exportCsv(context, ref),
          ),
          const Divider(),

          // Database Backup
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text(Strings.backupDatabase),
            subtitle: const Text(Strings.backupSubtitle),
            onTap: () => _backupDatabase(context, ref),
          ),
          const Divider(),

          // Database Restore
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text(Strings.restoreDatabase),
            subtitle: const Text(Strings.restoreSubtitle),
            onTap: () => _restoreDatabase(context, ref),
          ),
          const Divider(),

          // Auto Backup Folder
          ListTile(
            leading: const Icon(Icons.backup_table),
            title: const Text('Auto Daily Backup Location'),
            subtitle: Text(
              autoBackupFolderAsync.value?.isNotEmpty == true
                  ? autoBackupFolderAsync.value!
                  : Strings.notConfigured,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _pickAutoBackupFolder(context, ref),
          ),
          const Divider(),

          // Google Drive Integration
          ref.watch(cloudAuthStatusProvider).when(
            data: (isSignedIn) => ListTile(
              leading: const Icon(Icons.cloud_upload, color: Colors.blue),
              title: const Text('Google Drive Auto-Upload'),
              subtitle: Text(isSignedIn ? 'Signed in (Uploads automatically)' : 'Tap to sign in with Google'),
              trailing: isSignedIn 
                  ? IconButton(
                      icon: const Icon(Icons.logout, color: Colors.red),
                      onPressed: () async {
                        await ref.read(settingsRepositoryProvider).signOutFromCloud();
                        ref.invalidate(cloudAuthStatusProvider);
                      },
                    )
                  : const Icon(Icons.chevron_right),
              onTap: isSignedIn ? null : () async {
                final success = await ref.read(settingsRepositoryProvider).signInToCloud();
                ref.invalidate(cloudAuthStatusProvider);
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Successfully signed in to Google Drive!'), backgroundColor: Colors.green),
                  );
                } else if (!success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Google Sign-In failed or canceled.'), backgroundColor: Colors.red),
                  );
                }
              },
            ),
            loading: () => const ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Checking Cloud Status...'),
            ),
            error: (_, __) => const ListTile(
              leading: Icon(Icons.error, color: Colors.red),
              title: Text('Google Drive Auto-Upload'),
              subtitle: Text('Error loading status'),
            ),
          ),
          const Divider(),

          // App Info
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text(Strings.appName),
            subtitle: Text(Strings.appInfo),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFolder(BuildContext context, WidgetRef ref) async {
    final path = await FilePicker.getDirectoryPath();
    if (path != null) {
      final repo = ref.read(settingsRepositoryProvider);
      await repo.setRecordingFolderPath(path);

      // Clear scan cache since folder changed
      final recordingsRepo = ref.read(recordingsRepositoryProvider);
      await recordingsRepo.clearScanCache();

      // Trigger full rescan
      ref.read(recordingsProvider.notifier).scan();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(Strings.folderUpdated),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _exportCsv(BuildContext context, WidgetRef ref) async {
    final useCase = ref.read(exportComplaintsUseCaseProvider);
    final result = await useCase.call();

    if (context.mounted) {
      result.when(
        success: (filePath) async {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${Strings.exportSuccess} $filePath'),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'Share',
                textColor: Colors.white,
                onPressed: () {
                  Share.shareXFiles([XFile(filePath)]);
                },
              ),
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
  }

  Future<void> _backupDatabase(BuildContext context, WidgetRef ref) async {
    final autoBackupFolderAsync = ref.read(autoBackupFolderSettingProvider);
    final dir = autoBackupFolderAsync.value;

    if (dir == null || dir.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please configure "Auto Daily Backup Location" first.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 24),
            Text('Backing up locally and to cloud...'),
          ],
        ),
      ),
    );

    final useCase = ref.read(backupDatabaseUseCaseProvider);
    final result = await useCase.call(dir);

    // Dismiss loading dialog properly from the root navigator
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    if (context.mounted) {
      result.when(
        success: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${Strings.backupSuccess}\n$message'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
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
  }

  Future<void> _restoreDatabase(BuildContext context, WidgetRef ref) async {
    // Show warning dialog first
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore Database'),
        content: const Text(Strings.restoreWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(Strings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(Strings.confirm),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await FilePicker.pickFiles(
      type: FileType.any,
    );

    if (result == null || result.files.isEmpty) return;

    final filePath = result.files.single.path;
    if (filePath == null) return;

    final useCase = ref.read(restoreDatabaseUseCaseProvider);
    final restoreResult = await useCase.call(filePath);

    if (context.mounted) {
      restoreResult.when(
        success: (_) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: const Text('Restore Successful'),
              content: const Text('The database has been restored successfully. The app will now close to apply changes. Please reopen the app manually.'),
              actions: [
                TextButton(
                  onPressed: () {
                    exit(0);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        },
        failure: (f) {
          showDialog(
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
  }

  Future<void> _pickAutoBackupFolder(BuildContext context, WidgetRef ref) async {
    final path = await FilePicker.getDirectoryPath();
    if (path != null) {
      final repo = ref.read(settingsRepositoryProvider);
      await repo.setAutoBackupFolderPath(path);

      // Trigger automatic backup check immediately in case 24 hours have already passed, or to perform the initial backup
      await repo.checkAndPerformAutoBackup();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Auto backup location updated'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
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
          padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 16.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.1),
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
