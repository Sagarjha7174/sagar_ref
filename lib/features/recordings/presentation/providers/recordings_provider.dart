import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/recording_item.dart';
import '../../../../core/di/providers.dart';

class RecordingsState {
  const RecordingsState({
    this.recordings = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.isFolderNotConfigured = false,
  });

  final List<RecordingItem> recordings;
  final bool isLoading;
  /// True when an incremental/background scan is in progress
  /// (cached data is already shown, so no full-screen spinner).
  final bool isRefreshing;
  final String? error;
  final bool isFolderNotConfigured;

  RecordingsState copyWith({
    List<RecordingItem>? recordings,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    bool? isFolderNotConfigured,
    bool clearError = false,
  }) {
    return RecordingsState(
      recordings: recordings ?? this.recordings,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: clearError ? null : (error ?? this.error),
      isFolderNotConfigured: isFolderNotConfigured ?? this.isFolderNotConfigured,
    );
  }
}

class RecordingsNotifier extends Notifier<RecordingsState> {
  @override
  RecordingsState build() {
    // Kick off two-phase loading
    Future.microtask(() => _loadWithCache());
    return const RecordingsState(isLoading: true);
  }

  /// Phase 1: Load cached results instantly, then Phase 2: incremental scan.
  Future<void> _loadWithCache() async {
    final repo = ref.read(recordingsRepositoryProvider);
    final settingsDao = ref.read(settingsDaoProvider);

    // If cache has not been cleared for this update, clear it now to force a full scan of recordings
    final cacheCleared = await settingsDao.getValue('recordings_cache_cleaned_v3');
    if (cacheCleared != 'true') {
      await repo.clearScanCache();
      await settingsDao.setValue('recordings_cache_cleaned_v3', 'true');
    }

    // --- Phase 1: Show cached data immediately ---
    final cachedResult = await repo.getCachedRecordings();
    cachedResult.when(
      success: (cached) {
        if (cached.isNotEmpty) {
          // Show cached data right away, mark as refreshing (background scan coming)
          state = RecordingsState(
            recordings: cached,
            isLoading: false,
            isRefreshing: true,
          );
        }
        // If cache is empty, keep showing the loading spinner
      },
      failure: (_) {
        // Cache miss, keep loading
      },
    );

    // --- Phase 2: Incremental scan for new recordings ---
    final scanResult = await repo.scanNewRecordings();
    final isNotConfigured = await _isFolderNotConfigured();
    scanResult.when(
      success: (recordings) {

        state = RecordingsState(
          recordings: recordings,
          isFolderNotConfigured: isNotConfigured && recordings.isEmpty,
        );
      },
      failure: (failure) {
        if (state.recordings.isNotEmpty) {
          // We have cached data — show it with a subtle error, not full error screen
          state = state.copyWith(
            isLoading: false,
            isRefreshing: false,
            error: failure.message,
          );
        } else {
          // No cached data — show full error
          state = RecordingsState(error: failure.message);
        }
      },
    );
  }

  /// Full rescan — ignores cache. Used by the Refresh button.
  Future<void> scan() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final useCase = ref.read(scanRecordingsUseCaseProvider);
    final result = await useCase.call();
    final isNotConfigured = await _isFolderNotConfigured();

    result.when(
      success: (recordings) {

        state = RecordingsState(
          recordings: recordings,
          isFolderNotConfigured: isNotConfigured && recordings.isEmpty,
        );
      },
      failure: (failure) {
        state = RecordingsState(error: failure.message);
      },
    );
  }

  Future<bool> _isFolderNotConfigured() async {
    final folder =
        await ref.read(settingsRepositoryProvider).getRecordingFolderPath();
    return folder == null || folder.isEmpty;
  }

  Future<void> discardRecording(RecordingItem recording) async {
    final useCase = ref.read(discardRecordingUseCaseProvider);
    final result = await useCase.call(recording);

    result.when(
      success: (_) {
        final updated = state.recordings.where((r) => r.filePath != recording.filePath).toList();
        state = state.copyWith(recordings: updated);
      },
      failure: (failure) {
        // Error is shown via snackbar in the UI
      },
    );
  }

  void removeRecording(String filePath) {
    final updated = state.recordings.where((r) => r.filePath != filePath).toList();
    state = state.copyWith(recordings: updated);
  }
}

final recordingsProvider = NotifierProvider<RecordingsNotifier, RecordingsState>(RecordingsNotifier.new);
