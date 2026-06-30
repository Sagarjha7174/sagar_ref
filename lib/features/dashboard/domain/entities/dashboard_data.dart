import 'package:equatable/equatable.dart';
import '../../../complaints/domain/entities/complaint.dart';

class DashboardData extends Equatable {
  const DashboardData({
    required this.todayEarnings,
    required this.weeklyEarnings,
    required this.monthlyEarnings,
    required this.totalEarnings,
    required this.totalCollected,
    required this.totalPending,
    required this.pendingCollections,
    required this.pendingCount,
    required this.completedCount,
    required this.rejectedCount,
    required this.monthlyTrend,
    required this.applianceDistribution,
  });

  final double todayEarnings;
  final double weeklyEarnings;
  final double monthlyEarnings;
  final double totalEarnings;
  final double totalCollected;
  final double totalPending;
  final List<Complaint> pendingCollections;
  final int pendingCount;
  final int completedCount;
  final int rejectedCount;
  final List<MonthlyEarning> monthlyTrend;
  final Map<String, int> applianceDistribution;

  static const empty = DashboardData(
    todayEarnings: 0,
    weeklyEarnings: 0,
    monthlyEarnings: 0,
    totalEarnings: 0,
    totalCollected: 0,
    totalPending: 0,
    pendingCollections: [],
    pendingCount: 0,
    completedCount: 0,
    rejectedCount: 0,
    monthlyTrend: [],
    applianceDistribution: {},
  );

  @override
  List<Object?> get props => [
        todayEarnings,
        weeklyEarnings,
        monthlyEarnings,
        totalEarnings,
        totalCollected,
        totalPending,
        pendingCollections,
        pendingCount,
        completedCount,
        rejectedCount,
        monthlyTrend,
        applianceDistribution,
      ];
}

class MonthlyEarning extends Equatable {
  const MonthlyEarning({
    required this.month,
    required this.year,
    required this.amount,
  });

  final int month;
  final int year;
  final double amount;

  String get label {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  @override
  List<Object?> get props => [month, year, amount];
}

enum DashboardTimeFilter {
  today('Today'),
  thisMonth('This Month'),
  thisYear('This Year'),
  allTime('All Time');

  const DashboardTimeFilter(this.label);
  final String label;
}
