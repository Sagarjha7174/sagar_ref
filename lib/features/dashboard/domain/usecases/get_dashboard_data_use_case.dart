import '../../domain/entities/dashboard_data.dart';
import '../../../complaints/domain/entities/complaint.dart';
import '../../../../core/extensions/date_extensions.dart';

class GetDashboardDataUseCase {
  DashboardData computeFromComplaints(List<Complaint> allComplaints, DashboardTimeFilter filter) {
    final now = DateTime.now();

    // Filter complaints based on time filter
    final complaints = allComplaints.where((c) {
      if (filter == DashboardTimeFilter.allTime) return true;
      
      final date = c.completedAt ?? c.rejectedAt ?? c.createdAt;
      
      switch (filter) {
        case DashboardTimeFilter.today:
          return date.isSameDay(now);
        case DashboardTimeFilter.thisMonth:
          return date.isSameMonth(now);
        case DashboardTimeFilter.thisYear:
          return date.year == now.year;
        default:
          return true;
      }
    }).toList();

    // Earnings calculations
    final completedComplaints = complaints
        .where((c) => c.status == ComplaintStatus.completed)
        .toList();

    double todayEarnings = 0;
    double weeklyEarnings = 0;
    double monthlyEarnings = 0;
    double totalEarnings = 0;
    double totalCollected = 0;
    double totalPending = 0;
    final pendingCollections = <Complaint>[];

    for (final c in completedComplaints) {
      final amount = c.amountEarned ?? 0;
      final collected = c.amountCollected ?? 0;
      final pending = c.amountPending ?? 0;

      totalEarnings += amount;
      totalCollected += collected;
      totalPending += pending;

      if (pending > 0) {
        pendingCollections.add(c);
      }

      final completedDate = c.completedAt ?? c.createdAt;
      if (completedDate.isSameDay(now)) {
        todayEarnings += amount;
      }
      if (completedDate.isSameWeek(now)) {
        weeklyEarnings += amount;
      }
      if (completedDate.isSameMonth(now)) {
        monthlyEarnings += amount;
      }
    }

    // Status counts
    final pendingCount = complaints
        .where((c) => c.status == ComplaintStatus.pending)
        .length;
    final completedCount = completedComplaints.length;
    final rejectedCount = complaints
        .where((c) => c.status == ComplaintStatus.rejected)
        .length;

    // Monthly trend (last 6 months)
    final monthlyTrend = _computeMonthlyTrend(allComplaints.where((c) => c.status == ComplaintStatus.completed).toList(), now);

    // Appliance distribution (completed only)
    final applianceDistribution = <String, int>{};
    for (final c in completedComplaints) {
      for (final type in c.applianceTypes) {
        final key = type.displayName;
        applianceDistribution[key] = (applianceDistribution[key] ?? 0) + 1;
      }
    }

    return DashboardData(
      todayEarnings: todayEarnings,
      weeklyEarnings: weeklyEarnings,
      monthlyEarnings: monthlyEarnings,
      totalEarnings: totalEarnings,
      totalCollected: totalCollected,
      totalPending: totalPending,
      pendingCollections: pendingCollections,
      pendingCount: pendingCount,
      completedCount: completedCount,
      rejectedCount: rejectedCount,
      monthlyTrend: monthlyTrend,
      applianceDistribution: applianceDistribution,
    );
  }

  List<MonthlyEarning> _computeMonthlyTrend(
    List<Complaint> completed,
    DateTime now,
  ) {
    final trend = <MonthlyEarning>[];

    for (int i = 5; i >= 0; i--) {
      final targetDate = DateTime(now.year, now.month - i, 1);
      final month = targetDate.month;
      final year = targetDate.year;

      double earnings = 0;
      for (final c in completed) {
        final completedDate = c.completedAt ?? c.createdAt;
        if (completedDate.month == month && completedDate.year == year) {
          earnings += c.amountEarned ?? 0;
        }
      }

      trend.add(MonthlyEarning(month: month, year: year, amount: earnings));
    }

    return trend;
  }
}
