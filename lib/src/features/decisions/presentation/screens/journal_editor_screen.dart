import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/decision_vault_button.dart';
import '../../../../shared/widgets/decision_vault_card.dart';
import '../../../../shared/widgets/decision_vault_loading.dart';
import '../../../../shared/widgets/decision_vault_text_field.dart';
import '../providers/journal_provider.dart';
import '../../data/models/journal_model.dart';

class JournalEditorScreen extends StatefulWidget {
  const JournalEditorScreen({super.key, this.journalId});

  final int? journalId;

  @override
  State<JournalEditorScreen> createState() => _JournalEditorScreenState();
}

class _JournalEditorScreenState extends State<JournalEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _bodyController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.journalId != null) {
        final provider = context.read<JournalProvider>();
        final entry = await provider.getById(widget.journalId!);
        if (mounted && entry != null) {
          _titleController.text = entry.title;
          _bodyController.text = entry.body ?? '';
        }
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final provider = context.read<JournalProvider>();
    final title = _titleController.text.trim().isEmpty ? 'Untitled entry' : _titleController.text.trim();
    final model = JournalModel(
      id: widget.journalId,
      title: title,
      body: _bodyController.text.trim().isEmpty ? null : _bodyController.text.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await provider.save(model);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: DecisionVaultLoading(message: 'Preparing journal editor'));
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.journalId == null ? 'New journal entry' : 'Edit journal entry')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: DecisionVaultCard(
                child: Column(
                  children: [
                    DecisionVaultTextField(controller: _titleController, labelText: 'Title'),
                    const SizedBox(height: 16),
                    DecisionVaultTextField(controller: _bodyController, labelText: 'Notes', maxLines: 8),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            DecisionVaultButton(label: 'Save entry', icon: Icons.save, fullWidth: true, onPressed: _save),
          ],
        ),
      ),
    );
  }
}
