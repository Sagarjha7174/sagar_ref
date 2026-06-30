import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/complaint.dart';
import '../../../../core/di/providers.dart';

final complaintDetailsNotifierProvider =
    StreamProvider.family<Complaint?, int>((ref, id) {
  final repo = ref.watch(complaintsRepositoryProvider);
  return repo.watchComplaintById(id);
});
