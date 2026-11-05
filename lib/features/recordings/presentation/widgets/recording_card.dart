import 'package:flutter/material.dart';
import '../../../../core/extensions/date_extensions.dart';
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

  String _formatDuration(int seconds) {
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
    final duration = _formatDuration(recording.durationSeconds);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPlay,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: cs.primaryContainer,
                    foregroundColor: cs.onPrimaryContainer,
                    child: Text(
                      _initials,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _hasName ? recording.contactName : phone,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium,
                        ),
                        if (_hasName)
                          Text(
                            phone,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: Strings.discard,
                    onPressed: onDiscard,
                    icon: Icon(Icons.delete_outline, color: cs.error),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _InfoChip(
                    icon: Icons.schedule,
                    label: recording.recordedAt.toDisplayDateTime(),
                  ),
                  if (duration.isNotEmpty)
                    _InfoChip(icon: Icons.timer_outlined, label: duration),
                  const _InfoChip(icon: Icons.call_received, label: 'Incoming'),
                ],
              ),
              const SizedBox(height: 10),
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
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Create Complaint'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 42),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
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

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: cs.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
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
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: foreground, size: 22),
          ),
        ),
      ),
    );
  }
}
