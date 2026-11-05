import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';
import '../../../../core/constants/string_constants.dart';
import '../../../../core/di/providers.dart';
import '../../../recordings/domain/entities/recording_item.dart';
import '../../domain/entities/complaint.dart';
import '../../domain/usecases/create_complaint_use_case.dart';
import '../providers/pending_complaints_provider.dart';
import '../../../history/presentation/providers/history_provider.dart';
import '../../../recordings/presentation/providers/recordings_provider.dart';

class ComplaintCreationScreen extends ConsumerStatefulWidget {
  const ComplaintCreationScreen({
    super.key,
    required this.recording,
  });

  final RecordingItem recording;

  @override
  ConsumerState<ComplaintCreationScreen> createState() =>
      _ComplaintCreationScreenState();
}

class _ComplaintCreationScreenState
    extends ConsumerState<ComplaintCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _notesController;
  final Set<ApplianceType> _selectedAppliances = {};
  bool _isSubmitting = false;

  final _logger = Logger();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.recording.contactName != 'Unknown' &&
              widget.recording.contactName != 'Unknown Contact'
          ? widget.recording.contactName
          : '',
    );
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _startSpeechToText() async {
    // Check/request microphone permission
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone permission is required for voice input'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Initialize speech engine if not done already
    if (!_speechEnabled) {
      try {
        _speechEnabled = await _speech.initialize(
          onStatus: (status) => _logger.d('Speech status: $status'),
          onError: (error) => _logger.e('Speech error: $error'),
        );
      } catch (e) {
        _logger.e('Speech initialization failed: $e');
      }
    }

    if (!_speechEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Speech recognition is not available on this device'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final recognizedWords = ValueNotifier<String>('');

    // Start listening
    await _speech.listen(
      onResult: (result) {
        if (result.recognizedWords.trim().isNotEmpty) {
          recognizedWords.value = result.recognizedWords;
          _nameController.text = result.recognizedWords;
        }
      },
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        listenFor: const Duration(seconds: 15),
        pauseFor: const Duration(seconds: 4),
      ),
    );

    // Show listening bottom sheet with live preview
    if (mounted) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isDismissible: true,
        builder: (sheetCtx) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(sheetCtx).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Listening...',
                  style: Theme.of(sheetCtx).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 32),
                const _PulsingMicIcon(),
                const SizedBox(height: 32),
                ValueListenableBuilder<String>(
                  valueListenable: recognizedWords,
                  builder: (context, value, child) {
                    return Text(
                      value.isEmpty ? 'Say customer name...' : '"$value"',
                      textAlign: TextAlign.center,
                      style: Theme.of(sheetCtx).textTheme.bodyLarge?.copyWith(
                            fontStyle: value.isEmpty ? FontStyle.italic : FontStyle.normal,
                            color: value.isEmpty
                                ? Theme.of(sheetCtx).colorScheme.onSurfaceVariant
                                : Theme.of(sheetCtx).colorScheme.primary,
                            fontWeight: value.isEmpty ? FontWeight.normal : FontWeight.bold,
                          ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () {
                    _speech.stop();
                    Navigator.of(sheetCtx).pop();
                  },
                  child: const Text('Done'),
                ),
              ],
            ),
          );
        },
      ).then((_) {
        _speech.stop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.createComplaint),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Customer Name
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: Strings.customerName,
                prefixIcon: const Icon(Icons.person),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.mic),
                  onPressed: _startSpeechToText,
                  tooltip: 'Start voice input',
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return Strings.customerNameRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Appliance Type checkboxes
            Text(
              Strings.applianceType,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...ApplianceType.values.map((type) {
              final isChecked = _selectedAppliances.contains(type);
              return CheckboxListTile(
                title: Text(type.displayName),
                value: isChecked,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                onChanged: (bool? checked) {
                  setState(() {
                    if (checked == true) {
                      _selectedAppliances.add(type);
                    } else {
                      _selectedAppliances.remove(type);
                    }
                  });
                },
              );
            }).toList(),
            // Validation error message for checkboxes
            FormField<Set<ApplianceType>>(
              initialValue: _selectedAppliances,
              validator: (val) {
                if (_selectedAppliances.isEmpty) {
                  return 'Please select at least one appliance type';
                }
                return null;
              },
              builder: (state) {
                if (state.hasError) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      state.errorText!,
                      style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 24),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: Strings.notes,
                hintText: Strings.optionalNotes,
                prefixIcon: Icon(Icons.notes),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              maxLength: 500,
            ),
            const SizedBox(height: 32),

            // Submit button
            FilledButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: const Text(Strings.save),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAppliances.isEmpty) return;

    setState(() => _isSubmitting = true);

    // Check for duplicate pending complaint
    final repo = ref.read(complaintsRepositoryProvider);
    final existing = await repo.findPendingByPhone(widget.recording.phoneNumber);

    if (existing != null && mounted) {
      setState(() => _isSubmitting = false);
      _showDuplicateDialog(existing);
      return;
    }

    final notesText = _notesController.text.trim();

    // Create the complaint
    final createUseCase = ref.read(createComplaintUseCaseProvider);
    final result = await createUseCase.call(CreateComplaintParams(
      customerName: _nameController.text.trim(),
      phoneNumber: widget.recording.phoneNumber,
      applianceTypes: _selectedAppliances.toList(),
      notes: notesText.isNotEmpty ? notesText : null,
      recordingPath: widget.recording.filePath,
    ));

    if (!mounted) return;

    result.when(
      success: (complaintId) async {
        // Mark recording as processed
        final markUseCase = ref.read(markRecordingProcessedUseCaseProvider);
        await markUseCase.call(widget.recording, complaintId);

        // Remove from recordings state immediately
        ref.read(recordingsProvider.notifier).removeRecording(widget.recording.filePath);

        ref.invalidate(pendingComplaintsNotifierProvider);
        ref.invalidate(dashboardProvider);
        ref.invalidate(historyNotifierProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(Strings.complaintCreated),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }
      },
      failure: (failure) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  void _showDuplicateDialog(Complaint existing) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(Strings.pendingComplaintExists),
        content: Text(
          'A pending complaint already exists for '
          '${existing.customerName} (${existing.phoneNumber}). '
          'Please resolve the existing complaint before creating a new one.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(Strings.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.push('/complaints/${existing.id}');
            },
            child: const Text(Strings.viewExisting),
          ),
        ],
      ),
    );
  }
}

class _PulsingMicIcon extends StatefulWidget {
  const _PulsingMicIcon();

  @override
  State<_PulsingMicIcon> createState() => _PulsingMicIconState();
}

class _PulsingMicIconState extends State<_PulsingMicIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 60, end: 85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 100,
          height: 100,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
          ),
          child: Container(
            width: _animation.value,
            height: _animation.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
            child: Icon(
              Icons.mic,
              size: 40,
              color: theme.colorScheme.primary,
            ),
          ),
        );
      },
    );
  }
}
