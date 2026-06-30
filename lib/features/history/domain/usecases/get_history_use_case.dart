import '../../../complaints/domain/entities/complaint.dart';
import '../entities/history_filter.dart';
import '../repositories/history_repository.dart';

class HistoryResult {
  final List<Complaint> complaints;
  final double totalEarnings;

  HistoryResult({
    required this.complaints,
    required this.totalEarnings,
  });
}

class GetHistoryUseCase {
  GetHistoryUseCase({required this._repository});

  final HistoryRepository _repository;

  Future<HistoryResult> call(HistoryFilter filter, {int limit = 50, int offset = 0}) async {
    var complaints = await _repository.getCompletedAndRejected();

    // Apply search query
    if (filter.searchQuery.isNotEmpty) {
      final query = filter.searchQuery.toLowerCase();
      complaints = complaints.where((c) {
        return c.customerName.toLowerCase().contains(query) ||
            c.phoneNumber.contains(query);
      }).toList();
    }

    // Apply month filter
    if (filter.filterMonth != null) {
      complaints = complaints.where((c) {
        final date = _getEffectiveDate(c);
        return date.month == filter.filterMonth!.month &&
            date.year == filter.filterMonth!.year;
      }).toList();
    }

    // Apply date range filter
    if (filter.filterStartDate != null && filter.filterEndDate != null) {
      final start = DateTime(
        filter.filterStartDate!.year,
        filter.filterStartDate!.month,
        filter.filterStartDate!.day,
      );
      final end = DateTime(
        filter.filterEndDate!.year,
        filter.filterEndDate!.month,
        filter.filterEndDate!.day,
        23, 59, 59,
      );
      complaints = complaints.where((c) {
        final date = _getEffectiveDate(c);
        return date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            date.isBefore(end.add(const Duration(seconds: 1)));
      }).toList();
    }

    double totalEarnings = 0;
    for (final c in complaints) {
      if (c.status == ComplaintStatus.completed && c.amountEarned != null) {
        totalEarnings += c.amountEarned!;
      }
    }

    List<Complaint> paginated = [];
    if (offset < complaints.length) {
      paginated = complaints.sublist(offset, (offset + limit).clamp(0, complaints.length));
    }

    return HistoryResult(
      complaints: paginated,
      totalEarnings: totalEarnings,
    );
  }

  DateTime _getEffectiveDate(Complaint c) {
    if (c.status == ComplaintStatus.completed && c.completedAt != null) {
      return c.completedAt!;
    } else if (c.status == ComplaintStatus.rejected && c.rejectedAt != null) {
      return c.rejectedAt!;
    }
    return c.createdAt;
  }
}
