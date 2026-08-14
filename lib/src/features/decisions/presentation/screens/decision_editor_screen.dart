import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/decision_vault_card.dart';
import '../../../../shared/widgets/decision_vault_loading.dart';
import '../../../../shared/widgets/decision_vault_text_field.dart';
import '../../data/models/decision_model.dart';
import '../providers/decision_provider.dart';

/// A multi-step decision creation/edit wizard with auto-save draft support.
class DecisionEditorScreen extends StatefulWidget {
  const DecisionEditorScreen({super.key, this.decisionId});

  final int? decisionId;

  @override
  State<DecisionEditorScreen> createState() => _DecisionEditorScreenState();
}

class _DecisionEditorScreenState extends State<DecisionEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryController;
  late final TextEditingController _notesController;
  late final TextEditingController _prosController;
  late final TextEditingController _consController;
  late final TextEditingController _tagsController;
  int _priority = 2;
  double _score = 0;
  bool _isLoading = true;
  DecisionModel? _existingDecision;

  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _categoryController = TextEditingController();
    _notesController = TextEditingController();
    _prosController = TextEditingController();
    _consController = TextEditingController();
    _tagsController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.decisionId != null) {
        await context.read<DecisionProvider>().initialize();
        if (!mounted) return;
        final decision = await context.read<DecisionProvider>().getDecisionById(widget.decisionId!);
        if (decision != null && mounted) {
          setState(() {
            _existingDecision = decision;
            _titleController.text = decision.title;
            _descriptionController.text = decision.description ?? '';
            _categoryController.text = decision.category ?? '';
            _notesController.text = decision.notes ?? '';
            _prosController.text = decision.pros.join(', ');
            _consController.text = decision.cons.join(', ');
            _tagsController.text = decision.tags.join(', ');
            _priority = decision.priority;
            _score = decision.weightedScore;
            _isLoading = false;
          });
        }
      } else {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    _prosController.dispose();
    _consController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  DecisionModel _buildDecision({bool draft = false}) {
    return DecisionModel(
      id: widget.decisionId ?? _existingDecision?.id,
      title: _titleController.text.trim().isEmpty ? 'Untitled decision' : _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      category: _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
      priority: _priority,
      weightedScore: _score,
      pros: _parseList(_prosController.text),
      cons: _parseList(_consController.text),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      tags: _parseList(_tagsController.text),
      isFavorite: _existingDecision?.isFavorite ?? false,
      isArchived: _existingDecision?.isArchived ?? false,
      isDraft: draft,
      createdAt: _existingDecision?.createdAt,
    );
  }

  List<String> _parseList(String value) {
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  Future<void> _autoSaveDraft() async {
    try {
      final draft = _buildDecision(draft: true);
      await context.read<DecisionProvider>().saveDraft(draft);
    } catch (e) {
      // Swallow auto-save errors but log in debug
      // ignore: avoid_print
      print('Auto-save failed: $e');
    }
  }

  void _nextStep() async {
    if (_currentStep == 0) {
      // Validate title on first step
      if (_titleController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title is required')));
        return;
      }
    }

    // Auto-save draft when moving between steps
    await _autoSaveDraft();

    setState(() => _currentStep = (_currentStep + 1).clamp(0, 7));
  }

  void _previousStep() {
    setState(() => _currentStep = (_currentStep - 1).clamp(0, 7));
  }

  Future<void> _saveFinal() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title is required')));
      setState(() => _currentStep = 0);
      return;
    }

    final finalDecision = _buildDecision(draft: false);
    await context.read<DecisionProvider>().saveDecision(finalDecision);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: DecisionVaultLoading(message: 'Preparing wizard'));
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.decisionId == null ? 'Create Decision' : 'Edit Decision')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Stepper(
                currentStep: _currentStep,
                onStepCancel: _previousStep,
                onStepContinue: _currentStep == 7 ? _saveFinal : _nextStep,
                controlsBuilder: (context, details) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: details.onStepContinue,
                          child: Text(_currentStep == 7 ? 'Save' : 'Next'),
                        ),
                        const SizedBox(width: 8),
                        if (_currentStep > 0)
                          OutlinedButton(onPressed: details.onStepCancel, child: const Text('Back')),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            await _autoSaveDraft();
                            messenger.showSnackBar(const SnackBar(content: Text('Draft saved')));
                          },
                          child: const Text('Save draft'),
                        ),
                      ],
                    ),
                  );
                },
                steps: [
                  Step(
                    title: const Text('General Information'),
                    content: DecisionVaultCard(
                      child: Column(
                        children: [
                          DecisionVaultTextField(
                            controller: _titleController,
                            labelText: 'Decision title',
                          ),
                          const SizedBox(height: 12),
                          DecisionVaultTextField(
                            controller: _descriptionController,
                            labelText: 'Description',
                            maxLines: 4,
                          ),
                          const SizedBox(height: 12),
                          DecisionVaultTextField(
                            controller: _categoryController,
                            labelText: 'Category',
                            hintText: 'Finance, Career, Lifestyle',
                          ),
                        ],
                      ),
                    ),
                  ),
                  Step(
                    title: const Text('Options'),
                    content: DecisionVaultCard(
                      child: Column(
                        children: [
                          DecisionVaultTextField(
                            controller: _tagsController,
                            labelText: 'Tags (comma separated)',
                          ),
                        ],
                      ),
                    ),
                  ),
                  Step(
                    title: const Text('Pros'),
                    content: DecisionVaultCard(
                      child: DecisionVaultTextField(
                        controller: _prosController,
                        labelText: 'Pros (comma separated)',
                        maxLines: 3,
                      ),
                    ),
                  ),
                  Step(
                    title: const Text('Cons'),
                    content: DecisionVaultCard(
                      child: DecisionVaultTextField(
                        controller: _consController,
                        labelText: 'Cons (comma separated)',
                        maxLines: 3,
                      ),
                    ),
                  ),
                  Step(
                    title: const Text('Weighted Score'),
                    content: DecisionVaultCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${_score.round()} / 100'),
                          Slider(
                            value: _score,
                            min: 0,
                            max: 100,
                            divisions: 100,
                            label: _score.round().toString(),
                            onChanged: (value) => setState(() => _score = value),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Step(
                    title: const Text('Priority'),
                    content: DecisionVaultCard(
                      child: DropdownButtonFormField<int>(
                        value: _priority,
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('Low')),
                          DropdownMenuItem(value: 2, child: Text('Medium')),
                          DropdownMenuItem(value: 3, child: Text('High')),
                          DropdownMenuItem(value: 4, child: Text('Critical')),
                        ],
                        onChanged: (value) => setState(() => _priority = value ?? 2),
                      ),
                    ),
                  ),
                  Step(
                    title: const Text('Notes'),
                    content: DecisionVaultCard(
                      child: DecisionVaultTextField(
                        controller: _notesController,
                        labelText: 'Notes',
                        maxLines: 4,
                      ),
                    ),
                  ),
                  Step(
                    title: const Text('Review'),
                    content: DecisionVaultCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_titleController.text, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          if (_descriptionController.text.isNotEmpty)
                            Text(_descriptionController.text),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              Chip(label: Text('Priority $_priority')),
                              Chip(label: Text('Score ${_score.round()}')),
                              if (_categoryController.text.isNotEmpty) Chip(label: Text(_categoryController.text)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (_parseList(_tagsController.text).isNotEmpty)
                            Wrap(spacing: 8, children: _parseList(_tagsController.text).map((t) => Chip(label: Text(t))).toList()),
                          const SizedBox(height: 12),
                          const Text('Pros'),
                          const SizedBox(height: 8),
                          if (_parseList(_prosController.text).isEmpty)
                            const Text('No pros added')
                          else
                            ..._parseList(_prosController.text).map((p) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Text('• $p'),
                                )),
                          const SizedBox(height: 12),
                          const Text('Cons'),
                          const SizedBox(height: 8),
                          if (_parseList(_consController.text).isEmpty)
                            const Text('No cons added')
                          else
                            ..._parseList(_consController.text).map((c) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Text('• $c'),
                                )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
