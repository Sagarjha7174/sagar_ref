# Sagar Refrigeration Service

Flutter app that turns incoming call recordings into service complaints, tracks
their status and earnings, and backs up its data to a local folder and Google Drive.

## Features

- **Recordings** – scans the call-recording folder (`.mp3` / `.m4a`).
  Filenames like `NAME YYYY-MM-DD HH-MM-SS.m4a` (24-hour time) are decoded and
  shown in AM/PM; the phone number is resolved from the call log. Legacy MIUI
  names (`Name(0091…)_yyyyMMddHHmmss.mp3`) are still supported.
- **Complaints** – create from a recording or manually, complete with amount /
  photo, reject, reopen; dashboard and history.
- **Backup** – consistent SQLite snapshot (`VACUUM INTO`) saved to a local
  folder and uploaded to Google Drive daily (WorkManager background job +
  on app start). Failed uploads are retried automatically. Restore from a file
  or directly from Google Drive.

## Build

```bash
flutter pub get
flutter build apk --release
```

Requires a full JDK 17 or 21 (not a JRE). If Gradle picks the wrong Java:

```bash
flutter config --jdk-dir /usr/lib/jvm/java-21-openjdk-amd64
```

### Release signing

Create `android/key.properties` (not committed):

```properties
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=/absolute/path/to/upload-keystore.jks
```

Without it, release builds are signed with the debug key.

### Google Drive sign-in

In Google Cloud Console (same project):

1. Enable **Google Drive API**.
2. Create an **Android OAuth client** with package name
   `com.example.flutter_application_1` and the SHA-1 of the key that signs the APK:
   `keytool -list -v -keystore <keystore> -alias <alias>`
3. On the OAuth consent screen, add your account as a test user while in Testing mode.

A wrong SHA-1/package name shows up as `ApiException: 10` on sign-in.
