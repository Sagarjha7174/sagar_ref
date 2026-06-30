import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../../../core/constants/string_constants.dart';

class CompleteComplaintDialog extends StatefulWidget {
  const CompleteComplaintDialog({
    super.key,
    required this.onComplete,
  });

  final void Function(
    double earnedAmount,
    double collectedAmount,
    double pendingAmount,
    String? notes,
    String? imagePath,
  ) onComplete;

  @override
  State<CompleteComplaintDialog> createState() => _CompleteComplaintDialogState();
}

class _CompleteComplaintDialogState extends State<CompleteComplaintDialog> {
  final _formKey = GlobalKey<FormState>();
  final _earnedAmountController = TextEditingController();
  final _collectedAmountController = TextEditingController();
  final _pendingAmountController = TextEditingController(text: '0.00');
  final _notesController = TextEditingController();
  String? _imagePath;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _earnedAmountController.addListener(_updatePendingAmount);
    _collectedAmountController.addListener(_updatePendingAmount);
  }

  @override
  void dispose() {
    _earnedAmountController.removeListener(_updatePendingAmount);
    _collectedAmountController.removeListener(_updatePendingAmount);
    _earnedAmountController.dispose();
    _collectedAmountController.dispose();
    _pendingAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updatePendingAmount() {
    final earned = double.tryParse(_earnedAmountController.text) ?? 0.0;
    final collected = double.tryParse(_collectedAmountController.text) ?? 0.0;
    final pending = earned - collected;
    if (pending >= 0) {
      _pendingAmountController.text = pending.toStringAsFixed(0);
    } else {
      _pendingAmountController.text = '0';
    }
  }

  Future<void> _captureImage() async {
    if (_isCapturing) return;
    setState(() => _isCapturing = true);

    try {
      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1600,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (photo != null) {
        // Save the image in the app's application documents directory (private, hidden from gallery)
        final appDir = await getApplicationDocumentsDirectory();
        final String fileExtension = p.extension(photo.path).isNotEmpty ? p.extension(photo.path) : '.jpg';
        final String newFileName = 'complaint_complete_${DateTime.now().millisecondsSinceEpoch}$fileExtension';
        final String targetPath = p.join(appDir.path, newFileName);
        
        final File localFile = await File(photo.path).copy(targetPath);

        setState(() {
          _imagePath = localFile.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to capture image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(Strings.completeComplaint),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Earned Amount Field
              TextFormField(
                controller: _earnedAmountController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Total Earned Amount',
                  prefixText: '₹ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return Strings.amountRequired;
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return Strings.amountMustBePositive;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
      
              // Collected Amount Field
              TextFormField(
                controller: _collectedAmountController,
                decoration: InputDecoration(
                  labelText: 'Collected Amount',
                  prefixText: '₹ ',
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () {
                          _collectedAmountController.text = _earnedAmountController.text;
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('All'),
                      ),
                      TextButton(
                        onPressed: () {
                          _collectedAmountController.text = '0';
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('0'),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Collected amount is required';
                  }
                  final collected = double.tryParse(value);
                  if (collected == null || collected < 0) {
                    return 'Collected amount must be zero or positive';
                  }
                  final earned = double.tryParse(_earnedAmountController.text) ?? 0.0;
                  if (collected > earned) {
                    return 'Collected amount cannot exceed total earned';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      _collectedAmountController.text = '0';
                    },
                    icon: const Icon(Icons.money_off, size: 14),
                    label: const Text('Collected: ₹0'),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      final earned = double.tryParse(_earnedAmountController.text) ?? 0.0;
                      _collectedAmountController.text = earned.toStringAsFixed(0);
                    },
                    icon: const Icon(Icons.done_all, size: 14),
                    label: const Text('Collected: All'),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
      
              // Pending Amount (Read-only)
              TextFormField(
                controller: _pendingAmountController,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Pending Amount (Remaining)',
                  prefixText: '₹ ',
                  filled: true,
                ),
              ),
              const SizedBox(height: 16),

              // Image Capture UI
              Row(
                children: [
                  Expanded(
                    child: _imagePath == null
                        ? OutlinedButton.icon(
                            onPressed: _isCapturing ? null : _captureImage,
                            icon: _isCapturing
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.camera_alt),
                            label: const Text('Capture Work Image'),
                          )
                        : Text(
                            'Work image captured',
                            style: TextStyle(
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                  ),
                  if (_imagePath != null) ...[
                    const SizedBox(width: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.file(
                        File(_imagePath!),
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _imagePath = null;
                        });
                      },
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
      
              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: Strings.completionNotes,
                  hintText: Strings.optionalCompletionNotes,
                ),
                maxLines: 3,
                maxLength: 500,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(Strings.cancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text(Strings.complete),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final earned = double.parse(_earnedAmountController.text);
      final collected = double.parse(_collectedAmountController.text);
      final pending = earned - collected;
      final notes = _notesController.text.isEmpty ? null : _notesController.text;
      Navigator.of(context).pop();
      widget.onComplete(earned, collected, pending, notes, _imagePath);
    }
  }
}
