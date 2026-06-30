import 'package:drift/drift.dart';
import '../app_database.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [AppSettings])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Future<String?> getValue(String key) async {
    final result = await (select(appSettings)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return result?.value;
  }

  Future<void> setValue(String key, String value) async {
    await into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(
        key: key,
        value: value,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Stream<String?> watchValue(String key) {
    return (select(appSettings)
          ..where((t) => t.key.equals(key)))
        .watchSingleOrNull()
        .map((row) => row?.value);
  }

  Future<void> initializeDefaults() async {
    final defaults = {
      'recording_folder_path': '',
      'last_scan_timestamp': '0',
      'db_version': '1',
      'auto_backup_folder_path': '',
      'last_auto_backup_timestamp': '0',
    };

    for (final entry in defaults.entries) {
      final existing = await getValue(entry.key);
      if (existing == null) {
        await setValue(entry.key, entry.value);
      }
    }
  }
}
