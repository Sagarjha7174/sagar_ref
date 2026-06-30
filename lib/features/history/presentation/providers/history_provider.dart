import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../complaints/domain/entities/complaint.dart';
import '../../domain/entities/history_filter.dart';
import '../../../../core/di/providers.dart';

class HistoryState {
  const HistoryState({
    this.complaints = const [],
    this.filter = const HistoryFilter(),
    this.isLoading = false,
    this.hasReachedMax = false,
    this.offset = 0,
    this.error,
    this.totalEarnings = 0.0,
  });

  final List<Complaint> complaints;
  final HistoryFilter filter;
  final bool isLoading;
  final bool hasReachedMax;
  final int offset;
  final String? error;
  final double totalEarnings;

  HistoryState copyWith({
    List<Complaint>? complaints,
    HistoryFilter? filter,
    bool? isLoading,
    bool? hasReachedMax,
    int? offset,
    String? error,
    bool clearError = false,
    double? totalEarnings,
  }) {
    return HistoryState(
      complaints: complaints ?? this.complaints,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      offset: offset ?? this.offset,
      error: clearError ? null : (error ?? this.error),
      totalEarnings: totalEarnings ?? this.totalEarnings,
    );
  }
}

class HistoryNotifier extends Notifier<HistoryState> {
  static const int _pageSize = 25;

  @override
  HistoryState build() {
    Future.microtask(() => loadHistory(initialLoad: true));
    return const HistoryState(isLoading: true);
  }

  Future<void> loadHistory({bool loadMore = false, bool initialLoad = false}) async {
    if (state.isLoading && !initialLoad) return;
    if (loadMore && state.hasReachedMax) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final useCase = ref.read(getHistoryUseCaseProvider);
      
      // Load 25 at a time
      final currentOffset = loadMore ? state.offset : 0;
      final result = await useCase.call(state.filter, limit: _pageSize, offset: currentOffset);
      final newComplaints = result.complaints;
      
      state = state.copyWith(
        complaints: loadMore ? [...state.complaints, ...newComplaints] : newComplaints,
        isLoading: false,
        hasReachedMax: newComplaints.length < _pageSize,
        offset: currentOffset + _pageSize,
        totalEarnings: result.totalEarnings,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> setSearchQuery(String query) async {
    state = state.copyWith(
      filter: state.filter.copyWith(searchQuery: query),
    );
    await loadHistory();
  }

  Future<void> setMonthFilter(DateTime month) async {
    state = state.copyWith(
      filter: state.filter.copyWith(
        filterMonth: month,
        clearRange: true,
      ),
    );
    await loadHistory();
  }

  Future<void> setDateRange(DateTime start, DateTime end) async {
    state = state.copyWith(
      filter: state.filter.copyWith(
        filterStartDate: start,
        filterEndDate: end,
        clearMonth: true,
      ),
    );
    await loadHistory();
  }

  Future<void> clearFilters() async {
    state = state.copyWith(
      filter: HistoryFilter(searchQuery: state.filter.searchQuery),
    );
    await loadHistory();
  }
}

final historyNotifierProvider = NotifierProvider<HistoryNotifier, HistoryState>(HistoryNotifier.new);
