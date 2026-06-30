class HistoryFilter {
  const HistoryFilter({
    this.searchQuery = '',
    this.filterMonth,
    this.filterStartDate,
    this.filterEndDate,
  });

  final String searchQuery;
  final DateTime? filterMonth;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;

  bool get hasActiveFilter =>
      searchQuery.isNotEmpty ||
      filterMonth != null ||
      filterStartDate != null;

  HistoryFilter copyWith({
    String? searchQuery,
    DateTime? filterMonth,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
    bool clearMonth = false,
    bool clearRange = false,
  }) {
    return HistoryFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      filterMonth: clearMonth ? null : (filterMonth ?? this.filterMonth),
      filterStartDate: clearRange ? null : (filterStartDate ?? this.filterStartDate),
      filterEndDate: clearRange ? null : (filterEndDate ?? this.filterEndDate),
    );
  }

  static const empty = HistoryFilter();
}
