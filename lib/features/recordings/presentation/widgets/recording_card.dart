import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/string_constants.dart';
import '../../../../core/utils/phone_number_utils.dart';
import '../../domain/entities/recording_item.dart';

class RecordingCard extends StatelessWidget {
  const RecordingCard({
    super.key,
    required this.recording,
    required this.onPlay,
    required this.onCall,
    required this.onCreateComplaint,
    required this.onDiscard,
  });

  final RecordingItem recording;
  final VoidCallback onPlay;
  final VoidCallback onCall;
  final VoidCallback onCreateComplaint;
  final VoidCallback onDiscard;

  bool get _hasName =>
      recording.contactName.isNotEmpty &&
      recording.contactName != 'Unknown' &&
      recording.contactName != 'Unknown Contact';

  String get _initials {
    if (!_hasName) return '#';
    final parts = recording.contactName.trim().split(RegExp(r'\s+'));
    final first = parts.first.characters.first;
    final second = parts.length > 1 ? parts.last.characters.first : '';
    return (first + second).toUpperCase();
  }

  /// "05 Nov, 06:39 PM" (year shown only if not the current year).
  String get _when {
    final t = recording.recordedAt;
    final pattern =
        t.year == DateTime.now().year ? 'dd MMM, hh:mm a' : 'dd MMM yy, hh:mm a';
    return DateFormat(pattern).format(t);
  }

  String get _duration {
    final seconds = recording.durationSeconds;
    if (seconds <= 0) return '';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return m > 0 ? '${m}m ${s.toString().padLeft(2, '0')}s' : '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final phone = PhoneNumberUtils.formatForDisplay(recording.phoneNumber);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: cs.onSurfaceVariant,
      fontWeight: FontWeight.w500,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPlay,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name + phone + delete
              Row(
                children: [
                  CircleAvatar(
                    radius: 19,
                    backgroundColor: cs.primaryContainer,
                    foregroundColor: cs.onPrimaryContainer,
                    child: Text(
                      _initials,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _hasName ? recording.contactName : phone,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_hasName)
                          Text(
                            phone,
                            maxLines: 1,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: Strings.discard,
                    onPressed: onDiscard,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(Icons.delete_outline, color: cs.error, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Single info line: ↙ date, time · duration
              Row(
                children: [
                  Icon(Icons.call_received, size: 15, color: Colors.green.shade600),
                  const SizedBox(width: 6),
                  Icon(Icons.schedule, size: 14, color: cs.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      _when,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: muted,
                    ),
                  ),
                  if (_duration.isNotEmpty) ...[
                    const SizedBox(width: 10),
                    Icon(Icons.timer_outlined, size: 14, color: cs.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(_duration, maxLines: 1, style: muted),
                  ],
                ],
              ),
              const SizedBox(height: 8),

              // Actions
              Row(
                children: [
                  _RoundAction(
                    icon: Icons.play_arrow_rounded,
                    tooltip: Strings.play,
                    onTap: onPlay,
                    background: cs.primaryContainer,
                    foreground: cs.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  _RoundAction(
                    icon: Icons.call,
                    tooltip: Strings.call,
                    onTap: onCall,
                    background: Colors.green.withValues(alpha: 0.12),
                    foreground: Colors.green.shade700,
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilledButton.icon(
                      onPressed: onCreateComplaint,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Complaint'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: background,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: foreground, size: 20),
          ),
        ),
      ),
    );
  }
}
