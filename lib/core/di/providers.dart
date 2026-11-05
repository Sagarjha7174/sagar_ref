import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/database/app_database.dart' hide Complaint;
import '../../../../core/database/daos/complaints_dao.dart';
import '../../../../core/database/daos/recordings_dao.dart';
import '../../../../core/database/daos/settings_dao.dart';
import '../../../../core/permissions/permission_service.dart';
import '../../features/recordings/data/datasources/recording_scanner_service.dart';
import '../../features/recordings/data/datasources/recording_scan_cache_service.dart';
import '../../features/recordings/data/datasources/call_log_matcher.dart';
import '../../features/recordings/data/datasources/contact_lookup_service.dart';
import '../../features/recordings/data/repositories/recordings_repository_impl.dart';
import '../../features/settings/data/datasources/google_drive_service.dart';
import '../../features/recordings/domain/repositories/recordings_repository.dart';
import '../../features/recordings/domain/usecases/scan_recordings_use_case.dart';
import '../../features/recordings/domain/usecases/discard_recording_use_case.dart';
import '../../features/complaints/data/repositories/complaints_repository_impl.dart';
import '../../features/complaints/domain/repositories/complaints_repository.dart';
import '../../features/complaints/domain/usecases/create_complaint_use_case.dart';
import '../../features/complaints/domain/usecases/complete_complaint_use_case.dart';
import '../../features/complaints/domain/usecases/reject_complaint_use_case.dart';
import '../../features/complaints/domain/usecases/reopen_complaint_use_case.dart';
import '../../features/complaints/domain/usecases/delete_complaint_use_case.dart';
import '../../features/complaints/domain/usecases/mark_recording_processed_use_case.dart';
import '../../features/complaints/domain/usecases/record_collection_use_case.dart';
import '../../features/complaints/domain/entities/complaint.dart';
import '../../features/dashboard/domain/usecases/get_dashboard_data_use_case.dart';
import '../../features/dashboard/domain/entities/dashboard_data.dart';
import '../../features/history/data/repositories/history_repository_impl.dart';
import '../../features/history/domain/usecases/get_history_use_case.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/domain/usecases/export_complaints_use_case.dart';
import '../../features/settings/domain/usecases/backup_database_use_case.dart';
import '../../features/settings/domain/usecases/restore_database_use_case.dart';

// ===== CORE PROVIDERS =====

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return getIt<AppDatabase>();
});

final complaintsDaoProvider = Provider<ComplaintsDao>((ref) {
  return getIt<ComplaintsDao>();
});

final recordingsDaoProvider = Provider<RecordingsDao>((ref) {
  return getIt<RecordingsDao>();
});

final settingsDaoProvider = Provider<SettingsDao>((ref) {
  return getIt<SettingsDao>();
});

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return getIt<PermissionService>();
});

// ===== RECORDING PROVIDERS =====

final recordingScannerServiceProvider = Provider<RecordingScannerService>((ref) {
  return getIt<RecordingScannerService>();
});

final callLogMatcherProvider = Provider<CallLogMatcher>((ref) {
  return getIt<CallLogMatcher>();
});

final contactLookupServiceProvider = Provider<ContactLookupService>((ref) {
  return getIt<ContactLookupService>();
});

final recordingScanCacheServiceProvider = Provider<RecordingScanCacheService>((ref) {
  return getIt<RecordingScanCacheService>();
});

final recordingsRepositoryProvider = Provider<RecordingsRepository>((ref) {
  return RecordingsRepositoryImpl(
    scannerService: ref.watch(recordingScannerServiceProvider),
    cacheService: ref.watch(recordingScanCacheServiceProvider),
    callLogMatcher: ref.watch(callLogMatcherProvider),
    contactLookupService: ref.watch(contactLookupServiceProvider),
    recordingsDao: ref.watch(recordingsDaoProvider),
    settingsDao: ref.watch(settingsDaoProvider),
    permissionService: ref.watch(permissionServiceProvider),
  );
});

final scanRecordingsUseCaseProvider = Provider<ScanRecordingsUseCase>((ref) {
  return ScanRecordingsUseCase(
    repository: ref.watch(recordingsRepositoryProvider),
  );
});

final discardRecordingUseCaseProvider = Provider<DiscardRecordingUseCase>((ref) {
  return DiscardRecordingUseCase(
    repository: ref.watch(recordingsRepositoryProvider),
  );
});

// ===== COMPLAINT PROVIDERS =====

final complaintsRepositoryProvider = Provider<ComplaintsRepository>((ref) {
  return ComplaintsRepositoryImpl(
    complaintsDao: ref.watch(complaintsDaoProvider),
  );
});

final createComplaintUseCaseProvider = Provider<CreateComplaintUseCase>((ref) {
  return CreateComplaintUseCase(
    repository: ref.watch(complaintsRepositoryProvider),
  );
});

final completeComplaintUseCaseProvider = Provider<CompleteComplaintUseCase>((ref) {
  return CompleteComplaintUseCase(
    repository: ref.watch(complaintsRepositoryProvider),
  );
});

final rejectComplaintUseCaseProvider = Provider<RejectComplaintUseCase>((ref) {
  return RejectComplaintUseCase(
    repository: ref.watch(complaintsRepositoryProvider),
  );
});

final reopenComplaintUseCaseProvider = Provider<ReopenComplaintUseCase>((ref) {
  return ReopenComplaintUseCase(
    repository: ref.watch(complaintsRepositoryProvider),
  );
});

final recordCollectionUseCaseProvider = Provider<RecordCollectionUseCase>((ref) {
  return RecordCollectionUseCase(
    repository: ref.watch(complaintsRepositoryProvider),
  );
});

final deleteComplaintUseCaseProvider = Provider<DeleteComplaintUseCase>((ref) {
  return DeleteComplaintUseCase(
    repository: ref.watch(complaintsRepositoryProvider),
  );
});

final markRecordingProcessedUseCaseProvider = Provider<MarkRecordingProcessedUseCase>((ref) {
  return MarkRecordingProcessedUseCase(
    repository: ref.watch(recordingsRepositoryProvider),
  );
});

final pendingComplaintsProvider = StreamProvider<List<Complaint>>((ref) {
  final repo = ref.watch(complaintsRepositoryProvider);
  return repo.watchPendingComplaints();
});

final complaintDetailsProvider = StreamProvider.family<Complaint?, int>((ref, id) {
  final repo = ref.watch(complaintsRepositoryProvider);
  return repo.watchComplaintById(id);
});

// ===== DASHBOARD PROVIDERS =====

final getDashboardDataUseCaseProvider = Provider<GetDashboardDataUseCase>((ref) {
  return GetDashboardDataUseCase();
});

class DashboardTimeFilterNotifier extends Notifier<DashboardTimeFilter> {
  @override
  DashboardTimeFilter build() => DashboardTimeFilter.allTime;

  void setFilter(DashboardTimeFilter filter) {
    state = filter;
  }
}

final dashboardTimeFilterProvider = NotifierProvider<DashboardTimeFilterNotifier, DashboardTimeFilter>(() {
  return DashboardTimeFilterNotifier();
});

final dashboardProvider = StreamProvider<DashboardData>((ref) {
  final repo = ref.watch(complaintsRepositoryProvider);
  final useCase = ref.watch(getDashboardDataUseCaseProvider);
  final filter = ref.watch(dashboardTimeFilterProvider);

  return repo.watchAllComplaints().map((complaints) {
    return useCase.computeFromComplaints(complaints, filter);
  });
});

// ===== HISTORY PROVIDERS =====

final historyRepositoryProvider = Provider((ref) {
  return HistoryRepositoryImpl(
    complaintsDao: ref.watch(complaintsDaoProvider),
  );
});

final getHistoryUseCaseProvider = Provider<GetHistoryUseCase>((ref) {
  return GetHistoryUseCase(
    repository: ref.watch(historyRepositoryProvider),
  );
});

// ===== SETTINGS PROVIDERS =====

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(
    settingsDao: ref.watch(settingsDaoProvider),
    complaintsDao: ref.watch(complaintsDaoProvider),
    database: ref.watch(appDatabaseProvider),
    googleDriveService: getIt<GoogleDriveService>(),
  );
});

final exportComplaintsUseCaseProvider = Provider<ExportComplaintsUseCase>((ref) {
  return ExportComplaintsUseCase(
    repository: ref.watch(settingsRepositoryProvider),
  );
});

final backupDatabaseUseCaseProvider = Provider<BackupDatabaseUseCase>((ref) {
  return BackupDatabaseUseCase(
    repository: ref.watch(settingsRepositoryProvider),
  );
});

final restoreDatabaseUseCaseProvider = Provider<RestoreDatabaseUseCase>((ref) {
  return RestoreDatabaseUseCase(
    repository: ref.watch(settingsRepositoryProvider),
  );
});

final recordingFolderSettingProvider = StreamProvider<String?>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return repo.watchRecordingFolderPath();
});

final autoBackupFolderSettingProvider = StreamProvider<String?>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return repo.watchAutoBackupFolderPath();
});

// Provides the current Google Drive sign-in status
final cloudAuthStatusProvider = FutureProvider.autoDispose<bool>((ref) async {
  final repo = ref.watch(settingsRepositoryProvider);
  return await repo.isCloudSignedIn();
});

// Local + Google Drive backup status shown in Settings
final backupStatusProvider = FutureProvider.autoDispose<BackupStatus>((ref) async {
  final repo = ref.watch(settingsRepositoryProvider);
  return repo.getBackupStatus();
});
