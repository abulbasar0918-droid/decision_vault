import 'package:flutter/material.dart';

class DecisionVaultDialog extends StatelessWidget {
  const DecisionVaultDialog({super.key, required this.title, required this.content, this.actions});

  final String title;
  final String content;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: actions,
    );
  }
}

class DecisionVaultConfirmationDialog extends StatelessWidget {
  const DecisionVaultConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onConfirm,
    required this.onCancel,
  });

  final String title;
  final String content;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(onPressed: onCancel, child: const Text('Cancel')),
        FilledButton(onPressed: onConfirm, child: const Text('Confirm')),
      ],
    );
  }
}
