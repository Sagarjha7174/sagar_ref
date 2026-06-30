import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../recordings/domain/entities/recording_item.dart';
import '../../../recordings/presentation/providers/recordings_provider.dart';

class DiscardedRecordingsState {
  const DiscardedRecordingsState({
    this.recordings = const [],
    this.isLoading = false,
    this.error,
  });

  final List<RecordingItem> recordings;
  final bool isLoading;
  final String? error;

  DiscardedRecordingsState copyWith({
    List<RecordingItem>? recordings,
    bool? isLoading,
    String? error,
  }) {
    return DiscardedRecordingsState(
      recordings: recordings ?? this.recordings,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class DiscardedRecordingsNotifier extends Notifier<DiscardedRecordingsState> {
  @override
  DiscardedRecordingsState build() {
    Future.microtask(() => loadDiscarded());
    return const DiscardedRecordingsState(isLoading: true);
  }

  Future<void> loadDiscarded() async {
    state = state.copyWith(isLoading: true, error: null);
    final repo = ref.read(recordingsRepositoryProvider);
    final result = await repo.getDiscardedRecordings();
    result.when(
      success: (list) {
        state = state.copyWith(recordings: list, isLoading: false);
      },
      failure: (f) {
        state = state.copyWith(error: f.message, isLoading: false);
      },
    );
  }

  Future<bool> restoreRecording(String filePath) async {
    final repo = ref.read(recordingsRepositoryProvider);
    final result = await repo.restoreRecording(filePath);
    return result.when(
      success: (_) {
        // Trigger rescan of active recordings
        ref.read(recordingsProvider.notifier).scan();
        // Reload discarded list
        loadDiscarded();
        return true;
      },
      failure: (f) {
        state = state.copyWith(error: f.message);
        return false;
      },
    );
  }
}

final discardedRecordingsProvider = NotifierProvider<
    DiscardedRecordingsNotifier, DiscardedRecordingsState>(
  DiscardedRecordingsNotifier.new,
);
