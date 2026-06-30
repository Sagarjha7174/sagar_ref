import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/dashboard_data.dart';
import '../../../../core/di/providers.dart';

// Re-export the dashboardProvider from the central providers file
// It's already defined there as a StreamProvider<DashboardData>
