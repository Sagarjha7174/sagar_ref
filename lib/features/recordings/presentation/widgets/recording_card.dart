import 'package:flutter/material.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/constants/string_constants.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 4),
            _buildSubtitle(theme),
            const SizedBox(height: 8),
            _buildInfo(theme),
            const SizedBox(height: 12),
            _buildActions(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Text(
      recording.contactName,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSubtitle(ThemeData theme) {
    return Text(
      recording.phoneNumber,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildInfo(ThemeData theme) {
    return Row(
      children: [
        Icon(Icons.calendar_today, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          recording.recordedAt.toDisplayDateTime(),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ActionButton(
          icon: Icons.play_circle_outline,
          label: Strings.play,
          onTap: onPlay,
          color: theme.colorScheme.primary,
        ),
        _ActionButton(
          icon: Icons.call,
          label: Strings.call,
          onTap: onCall,
          color: Colors.green,
        ),
        _ActionButton(
          icon: Icons.add_circle_outline,
          label: 'Complaint',
          onTap: onCreateComplaint,
          color: theme.colorScheme.tertiary,
        ),
        _ActionButton(
          icon: Icons.delete_outline,
          label: Strings.discard,
          onTap: onDiscard,
          color: Colors.red,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
