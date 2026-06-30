import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../constants/string_constants.dart';

class AudioPlayerBottomSheet extends StatefulWidget {
  const AudioPlayerBottomSheet({
    super.key,
    required this.filePath,
    required this.title,
  });

  final String filePath;
  final String title;

  static Future<void> show(BuildContext context, {required String filePath, required String title}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AudioPlayerBottomSheet(filePath: filePath, title: title),
    );
  }

  @override
  State<AudioPlayerBottomSheet> createState() => _AudioPlayerBottomSheetState();
}

class _AudioPlayerBottomSheetState extends State<AudioPlayerBottomSheet> {
  late final AudioPlayer _player;
  bool _hasError = false;
  String _errorMessage = '';
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<PlayerState>? _stateSub;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      await _player.setFilePath(widget.filePath);
      _player.play(); // Auto-play when opened

      _durationSub = _player.durationStream.listen((d) {
        if (d != null && mounted) {
          setState(() => _duration = d);
        }
      });

      _positionSub = _player.positionStream.listen((p) {
        if (mounted) {
          setState(() => _position = p);
        }
      });

      _stateSub = _player.playerStateStream.listen((state) {
        if (mounted) {
          setState(() => _isPlaying = state.playing);
          if (state.processingState == ProcessingState.completed) {
            _player.seek(Duration.zero);
            _player.pause();
          }
        }
      });
    } on PlayerException catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.message ?? Strings.audioPlayerError;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = Strings.audioPlayerError;
        });
      }
    }
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _stateSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Title
          Text(
            widget.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),

          if (_hasError) ...[
            Icon(Icons.error_outline, color: theme.colorScheme.error, size: 48),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: TextStyle(color: theme.colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            // Seek bar
            Slider(
              value: _duration.inMilliseconds > 0
                  ? _position.inMilliseconds.toDouble().clamp(0, _duration.inMilliseconds.toDouble())
                  : 0,
              max: _duration.inMilliseconds > 0 ? _duration.inMilliseconds.toDouble() : 1,
              onChanged: (value) {
                _player.seek(Duration(milliseconds: value.toInt()));
              },
            ),
            // Duration display
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(_position), style: theme.textTheme.bodySmall),
                  Text(_formatDuration(_duration), style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Play/Pause
                IconButton.filled(
                  onPressed: () {
                    if (_isPlaying) {
                      _player.pause();
                    } else {
                      _player.play();
                    }
                  },
                  iconSize: 40,
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                ),
                const SizedBox(width: 16),
                // Stop & close
                IconButton.outlined(
                  onPressed: () {
                    _player.stop();
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.stop),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
