import 'package:equatable/equatable.dart';

class RecordingItem extends Equatable {
  const RecordingItem({
    required this.filePath,
    required this.phoneNumber,
    required this.contactName,
    required this.recordedAt,
    required this.durationSeconds,
    required this.isIncoming,
  });

  final String filePath;
  final String phoneNumber;
  final String contactName;
  final DateTime recordedAt;
  final int durationSeconds;
  final bool isIncoming;

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  Map<String, dynamic> toJson() => {
        'filePath': filePath,
        'phoneNumber': phoneNumber,
        'contactName': contactName,
        'recordedAt': recordedAt.millisecondsSinceEpoch,
        'durationSeconds': durationSeconds,
        'isIncoming': isIncoming,
      };

  factory RecordingItem.fromJson(Map<String, dynamic> json) => RecordingItem(
        filePath: json['filePath'] as String,
        phoneNumber: json['phoneNumber'] as String,
        contactName: json['contactName'] as String,
        recordedAt:
            DateTime.fromMillisecondsSinceEpoch(json['recordedAt'] as int),
        durationSeconds: json['durationSeconds'] as int,
        isIncoming: json['isIncoming'] as bool,
      );

  @override
  List<Object?> get props => [
        filePath,
        phoneNumber,
        contactName,
        recordedAt,
        durationSeconds,
        isIncoming,
      ];
}
