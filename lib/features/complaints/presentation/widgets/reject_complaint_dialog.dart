import 'package:flutter/material.dart';
import '../../../../core/constants/string_constants.dart';

class RejectComplaintDialog extends StatelessWidget {
  const RejectComplaintDialog({
    super.key,
    required this.customerName,
    required this.onReject,
  });

  final String customerName;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(Strings.rejectComplaint),
      content: Text('${Strings.rejectConfirmBody} $customerName?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(Strings.cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onReject();
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text(Strings.reject),
        ),
      ],
    );
  }
}
