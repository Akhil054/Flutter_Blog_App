import 'package:flutter/material.dart';

/// Shows a popup (AlertDialog) for errors like wrong password or username
/// instead of a bottom snack bar.
void showErrorDialog(
  BuildContext context,
  String message, {
  String title = 'Login failed',
}) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
