import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../shared/widgets/decision_vault_button.dart';
import '../../../../shared/widgets/decision_vault_card.dart';
import '../../../../shared/widgets/decision_vault_error.dart';
import '../../../../shared/widgets/decision_vault_loading.dart';
import '../../data/models/decision_model.dart';
import '../../data/models/history_model.dart';
import '../providers/decision_provider.dart';
import '../providers/history_provider.dart';
import '../../../../core/utils/date_time_utils.dart';

class DecisionDetailScreen extends StatefulWidget {
  const DecisionDetailScreen({super.key, required this.decisionId});

  final int decisionId;

  @override
  State<DecisionDetailScreen> createState() => _DecisionDetailScreenState();
}

class _DecisionDetailScreenState extends State<DecisionDetailScreen> {
  late Future<DecisionModel?> _future;
  late Future<List<HistoryModel>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _future = _loadDecision();

    // Capture provider reference synchronously to avoid using BuildContext after
    // an async gap and satisfy the analyzer's `use_build_context_synchronously`.
    final historyProvider = context.read<HistoryProvider>();
    // Load history in parallel so the detail view can show timeline without
    // delaying the primary decision content.
    _historyFuture = Future.microtask(() => historyProvider.loadForDecision(widget.decisionId));
  }

  Future<DecisionModel?> _loadDecision() async {
    final provider = context.read<DecisionProvider>();
    await provider.initialize();
    if (!mounted) {
      return null;
    }
    return provider.getDecisionById(widget.decisionId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Decision Details')),
      body: FutureBuilder<DecisionModel?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const DecisionVaultLoading(message: 'Loading decision');
          }

          if (snapshot.hasError || snapshot.data == null) {
            return DecisionVaultError(
              message: 'Unable to load this decision.',
              onRetry: () => setState(() {
                _future = _loadDecision();
                _historyFuture = context.read<HistoryProvider>().loadForDecision(widget.decisionId);
              }),
            );
          }

          final decision = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DecisionVaultCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(decision.title, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (decision.isFavorite)
                          IconButton(
                            icon: const Icon(Icons.star, color: Colors.amber),
                            onPressed: () => context.read<DecisionProvider>().toggleFavorite(decision.id!),
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.star_border),
                            onPressed: () => context.read<DecisionProvider>().toggleFavorite(decision.id!),
                          ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(decision.isArchived ? Icons.unarchive : Icons.archive),
                          onPressed: () => context.read<DecisionProvider>().toggleArchive(decision.id!),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (decision.description != null && decision.description!.isNotEmpty) ...[
                      Text(decision.description!, style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 16),
                    ],
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(label: Text('Priority ${decision.priority}')),
                        Chip(label: Text('Score ${decision.weightedScore}')),
                        if (decision.category != null && decision.category!.isNotEmpty)
                          Chip(label: Text(decision.category!)),
                        if (decision.isFavorite) const Chip(label: Text('Favorite')),
                        if (decision.isArchived) const Chip(label: Text('Archived')),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              DecisionVaultCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pros'),
                    const SizedBox(height: 8),
                    if (decision.pros.isEmpty)
                      const Text('No pros added.')
                    else
                      ...decision.pros.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check_circle_outline, size: 18),
                                const SizedBox(width: 8),
                                Expanded(child: Text(item)),
                              ],
                            ),
                          )),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              DecisionVaultCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Cons'),
                    const SizedBox(height: 8),
                    if (decision.cons.isEmpty)
                      const Text('No cons added.')
                    else
                      ...decision.cons.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.remove_circle_outline, size: 18),
                                const SizedBox(width: 8),
                                Expanded(child: Text(item)),
                              ],
                            ),
                          )),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              DecisionVaultCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Notes'),
                    const SizedBox(height: 8),
                    Text(decision.notes?.isNotEmpty == true ? decision.notes! : 'No notes added.'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              DecisionVaultCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tags'),
                    const SizedBox(height: 8),
                    if (decision.tags.isEmpty)
                      const Text('No tags added.')
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: decision.tags.map((tag) => Chip(label: Text(tag))).toList(),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              DecisionVaultCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Created: ${DateTimeUtils.formatIso8601(decision.createdAt)}'),
                    const SizedBox(height: 4),
                    Text('Updated: ${DateTimeUtils.formatIso8601(decision.updatedAt)}'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // History section
              DecisionVaultCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('History'),
                    const SizedBox(height: 8),
                    FutureBuilder<List<HistoryModel>>(
                      future: _historyFuture,
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const DecisionVaultLoading(message: 'Loading history');
                        }
                        if (snap.hasError) {
                          return DecisionVaultError(
                            message: 'Unable to load history.',
                            onRetry: () => setState(() {
                              _historyFuture = context.read<HistoryProvider>().loadForDecision(widget.decisionId);
                            }),
                          );
                        }

                        final items = snap.data ?? <HistoryModel>[];
                        if (items.isEmpty) {
                          return const Text('No history available for this decision.');
                        }

                        return Column(
                          children: items.map((h) {
                            final date = h.createdAt;
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.history),
                              title: Text(h.event),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (h.payload != null && h.payload!.isNotEmpty) Text(h.payload!),
                                  const SizedBox(height: 4),
                                  Text(DateTimeUtils.formatIso8601(date), style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DecisionVaultButton(
                      label: 'Edit',
                      icon: Icons.edit,
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          AppRoutes.editDecision,
                          arguments: decision.id,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DecisionVaultButton(
                      label: 'Back',
                      icon: Icons.arrow_back,
                      outlined: true,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
