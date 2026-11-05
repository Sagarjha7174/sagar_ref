import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }

  @override
  void close() {
    _client.close();
    super.close();
  }
}

enum DriveErrorKind { notSignedIn, network, quota, other }

/// A Drive failure with a message that is safe to show to the user.
class DriveBackupException implements Exception {
  const DriveBackupException(this.kind, this.message);

  final DriveErrorKind kind;
  final String message;

  @override
  String toString() => message;
}

/// Metadata of the backup file stored on Drive.
class DriveBackupInfo {
  const DriveBackupInfo({required this.id, this.modifiedTime, this.sizeBytes});

  final String id;
  final DateTime? modifiedTime;
  final int? sizeBytes;
}

class GoogleDriveService {
  static const String folderName = 'Sagar Refrigeration Backups';
  static const Duration _timeout = Duration(minutes: 5);

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveFileScope,
    ],
  );

  String? _cachedFolderId;

  /// Interactive sign-in. Only call from a UI action (shows account picker).
  Future<GoogleSignInAccount?> signIn() async {
    try {
      var account = await _silentAccount();
      account ??= await _googleSignIn.signIn();
      return account;
    } catch (e) {
      debugPrint('Google SignIn Error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    _cachedFolderId = null;
    await _googleSignIn.signOut();
  }

  Future<bool> get isSignedIn async => await _googleSignIn.isSignedIn();

  /// Uploads [localFilePath] to the backup folder, replacing the previous
  /// backup with the same name.
  ///
  /// When [interactive] is false (automatic/background backups), it never
  /// shows the account picker: if the silent sign-in fails, it throws a
  /// [DriveBackupException] of kind [DriveErrorKind.notSignedIn].
  Future<void> uploadBackup(
    String localFilePath, {
    bool interactive = false,
  }) async {
    final file = File(localFilePath);
    if (!await file.exists()) {
      throw const DriveBackupException(
        DriveErrorKind.other,
        'Backup file not found locally',
      );
    }
    final fileName = p.basename(localFilePath);

    await _withDrive(interactive, (api) async {
      final folderId = await _getOrCreateFolder(api);
      final existing = await _findFile(api, folderId, fileName);
      final media = drive.Media(file.openRead(), await file.length());
      final driveFile = drive.File()..name = fileName;

      if (existing != null) {
        await api.files.update(driveFile, existing.id, uploadMedia: media);
        debugPrint('Google Drive: Overwrote existing backup $fileName');
      } else {
        driveFile.parents = [folderId];
        await api.files.create(driveFile, uploadMedia: media);
        debugPrint('Google Drive: Created new backup $fileName');
      }
    });
  }

  /// Returns info about the backup named [fileName] on Drive, or null if
  /// there is none.
  Future<DriveBackupInfo?> getBackupInfo(
    String fileName, {
    bool interactive = true,
  }) {
    return _withDrive(interactive, (api) async {
      final folderId = await _findFolder(api);
      if (folderId == null) return null;
      return _findFile(api, folderId, fileName);
    });
  }

  /// Downloads the backup named [fileName] from Drive to [destinationPath].
  /// Returns its info, or null if no backup exists on Drive.
  Future<DriveBackupInfo?> downloadBackup(
    String fileName,
    String destinationPath, {
    bool interactive = true,
  }) {
    return _withDrive(interactive, (api) async {
      final folderId = await _findFolder(api);
      if (folderId == null) return null;
      final info = await _findFile(api, folderId, fileName);
      if (info == null) return null;

      final media = await api.files.get(
        info.id,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final out = File(destinationPath);
      if (await out.exists()) await out.delete();
      final sink = out.openWrite();
      try {
        await media.stream.pipe(sink);
      } catch (_) {
        await sink.close();
        if (await out.exists()) await out.delete();
        rethrow;
      }
      return info;
    });
  }

  // ===== internals =====

  Future<GoogleSignInAccount?> _silentAccount() async {
    try {
      return _googleSignIn.currentUser ?? await _googleSignIn.signInSilently();
    } catch (_) {
      return null;
    }
  }

  /// Runs [action] with an authenticated Drive client, converting every
  /// failure into a [DriveBackupException] with a user-facing message.
  Future<T> _withDrive<T>(
    bool interactive,
    Future<T> Function(drive.DriveApi api) action,
  ) async {
    GoogleAuthClient? client;
    try {
      final account =
          interactive ? await signIn() : await _silentAccount();
      if (account == null) {
        throw const DriveBackupException(
          DriveErrorKind.notSignedIn,
          'Google sign-in expired. Open Settings and sign in to Google Drive again.',
        );
      }
      client = GoogleAuthClient(await account.authHeaders);
      return await action(drive.DriveApi(client)).timeout(_timeout);
    } on DriveBackupException {
      rethrow;
    } catch (e) {
      throw _mapError(e);
    } finally {
      client?.close();
    }
  }

  DriveBackupException _mapError(Object e) {
    if (e is SocketException ||
        e is http.ClientException ||
        e is TimeoutException ||
        e is HandshakeException) {
      return const DriveBackupException(
        DriveErrorKind.network,
        'No internet connection. Will retry automatically.',
      );
    }
    if (e is drive.DetailedApiRequestError) {
      final reasons = e.errors.map((x) => x.reason).join(',');
      if (reasons.contains('storageQuotaExceeded')) {
        return const DriveBackupException(
          DriveErrorKind.quota,
          'Google Drive storage is full.',
        );
      }
      if (e.status == 401 || e.status == 403) {
        return const DriveBackupException(
          DriveErrorKind.notSignedIn,
          'Google Drive access denied. Sign out and sign in again in Settings.',
        );
      }
      return DriveBackupException(
        DriveErrorKind.other,
        'Google Drive error ${e.status}: ${e.message}',
      );
    }
    if (e is PlatformException) {
      return const DriveBackupException(
        DriveErrorKind.notSignedIn,
        'Google sign-in failed. Sign in to Google Drive again in Settings.',
      );
    }
    return DriveBackupException(DriveErrorKind.other, 'Google Drive error: $e');
  }

  Future<String?> _findFolder(drive.DriveApi api) async {
    if (_cachedFolderId != null) return _cachedFolderId;
    final list = await api.files.list(
      q: "mimeType='application/vnd.google-apps.folder' "
          "and name='$folderName' and trashed=false",
      // Oldest first so every run (and every device) picks the same folder
      // even if a duplicate was ever created.
      orderBy: 'createdTime',
      $fields: 'files(id)',
    );
    final id = list.files?.isNotEmpty == true ? list.files!.first.id : null;
    _cachedFolderId = id;
    return id;
  }

  Future<String> _getOrCreateFolder(drive.DriveApi api) async {
    final existing = await _findFolder(api);
    if (existing != null) return existing;

    final folder = drive.File()
      ..name = folderName
      ..mimeType = 'application/vnd.google-apps.folder';
    final created = await api.files.create(folder);
    _cachedFolderId = created.id!;
    return created.id!;
  }

  Future<DriveBackupInfo?> _findFile(
    drive.DriveApi api,
    String folderId,
    String fileName,
  ) async {
    final list = await api.files.list(
      q: "name='$fileName' and '$folderId' in parents and trashed=false",
      orderBy: 'modifiedTime desc',
      $fields: 'files(id,modifiedTime,size)',
    );
    final f = list.files?.isNotEmpty == true ? list.files!.first : null;
    if (f?.id == null) return null;
    return DriveBackupInfo(
      id: f!.id!,
      modifiedTime: f.modifiedTime?.toLocal(),
      sizeBytes: int.tryParse(f.size ?? ''),
    );
  }
}
