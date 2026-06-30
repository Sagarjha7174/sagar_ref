import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/complaint.dart';
import '../../../../core/di/providers.dart';

final pendingComplaintsNotifierProvider =
    StreamProvider<List<Complaint>>((ref) {
  final repo = ref.watch(complaintsRepositoryProvider);
  return repo.watchPendingComplaints();
});
