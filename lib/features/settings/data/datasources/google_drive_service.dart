import 'dart:io';
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
}

class GoogleDriveService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveFileScope,
    ],
  );

  Future<GoogleSignInAccount?> signIn() async {
    try {
      var account = _googleSignIn.currentUser ?? await _googleSignIn.signInSilently();
      account ??= await _googleSignIn.signIn();
      return account;
    } catch (e) {
      print('Google SignIn Error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  Future<bool> get isSignedIn async => await _googleSignIn.isSignedIn();

  Future<void> uploadBackup(String localFilePath) async {
    final account = await signIn();
    if (account == null) throw Exception('Google Sign-In failed');

    final headers = await account.authHeaders;
    final client = GoogleAuthClient(headers);
    final driveApi = drive.DriveApi(client);

    final file = File(localFilePath);
    if (!await file.exists()) throw Exception('Backup file not found locally');

    final fileName = p.basename(localFilePath);

    // 1. Create or find a folder named "Sagar Refrigeration Backups"
    final folderId = await _getOrCreateFolder(driveApi, 'Sagar Refrigeration Backups');

    // 2. Check if file exists inside this folder
    final query = "name = '$fileName' and '$folderId' in parents and trashed = false";
    final fileList = await driveApi.files.list(q: query);
    
    drive.File driveFile = drive.File();
    driveFile.name = fileName;

    final media = drive.Media(file.openRead(), file.lengthSync());

    if (fileList.files != null && fileList.files!.isNotEmpty) {
      // Overwrite existing file
      final existingFileId = fileList.files!.first.id!;
      await driveApi.files.update(driveFile, existingFileId, uploadMedia: media);
      print('Google Drive: Overwrote existing backup $fileName');
    } else {
      // Create new file
      driveFile.parents = [folderId];
      await driveApi.files.create(driveFile, uploadMedia: media);
      print('Google Drive: Created new backup $fileName');
    }
  }

  Future<String> _getOrCreateFolder(drive.DriveApi driveApi, String folderName) async {
    final query = "mimeType='application/vnd.google-apps.folder' and name='$folderName' and trashed=false";
    final folderList = await driveApi.files.list(q: query);

    if (folderList.files != null && folderList.files!.isNotEmpty) {
      return folderList.files!.first.id!;
    }

    // Create folder
    drive.File folder = drive.File();
    folder.name = folderName;
    folder.mimeType = 'application/vnd.google-apps.folder';

    final createdFolder = await driveApi.files.create(folder);
    return createdFolder.id!;
  }
}
