import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../shared/widgets/decision_vault_button.dart';
import '../../../../shared/widgets/decision_vault_card.dart';
import '../../../../shared/widgets/decision_vault_dialog.dart';
import '../../../../shared/widgets/decision_vault_empty_state.dart';
import '../../../../shared/widgets/decision_vault_error.dart';
import '../../../../shared/widgets/decision_vault_loading.dart';
import '../../../../shared/widgets/decision_vault_search_bar.dart';
import '../providers/decision_provider.dart';
import '../../data/models/decision_model.dart';

class DecisionListScreen extends StatefulWidget {
  const DecisionListScreen({super.key});

  @override
  State<DecisionListScreen> createState() => _DecisionListScreenState();
}

class _DecisionListScreenState extends State<DecisionListScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DecisionProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Decisions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Reset filters',
            onPressed: () async {
              await context.read<DecisionProvider>().resetFilters();
              _searchController.clear();
            },
          ),
        ],
      ),
      body: Consumer<DecisionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.decisions.isEmpty) {
            return const DecisionVaultLoading(message: 'Loading decisions');
          }

          if (provider.errorMessage != null && provider.decisions.isEmpty) {
            return DecisionVaultError(
              message: provider.errorMessage!,
              onRetry: provider.initialize,
            );
          }

          return RefreshIndicator(
            onRefresh: provider.loadDecisions,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                DecisionVaultSearchBar(
                  controller: _searchController,
                  onChanged: (value) => provider.setSearchQuery(value),
                  onClear: () => provider.setSearchQuery(''),
                ),
                const SizedBox(height: 16),
                _FilterSummary(provider: provider),
                const SizedBox(height: 16),
                if (provider.filteredDecisions.isEmpty)
                  const DecisionVaultEmptyState(
                    icon: Icons.folder_open_outlined,
                    title: 'No decisions match your filters',
                    subtitle: 'Create a new decision to get started.',
                  )
                else
                  ...provider.filteredDecisions.map((decision) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _DecisionTile(decision: decision),
                      )),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed(AppRoutes.newDecision);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add decision'),
      ),
    );
  }
}

class _FilterSummary extends StatelessWidget {
  const _FilterSummary({required this.provider});

  final DecisionProvider provider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Filter summary', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: Text('Favorites ${provider.favoriteDecisions}'),
              selected: provider.showFavoritesOnly,
              onSelected: (value) => provider.setFavoritesOnly(value),
            ),
            FilterChip(
              label: Text('Archived ${provider.archivedDecisions}'),
              selected: provider.showArchivedOnly,
              onSelected: (value) => provider.setArchivedOnly(value),
            ),
            if (provider.categories.isNotEmpty)
              ...provider.categories.map(
                (category) => FilterChip(
                  label: Text(category),
                  selected: provider.selectedCategory == category,
                  onSelected: (_) => provider.setSelectedCategory(
                    provider.selectedCategory == category ? null : category,
                  ),
                ),
              ),
            if (provider.tags.isNotEmpty)
              ...provider.tags.map(
                (tag) => FilterChip(
                  label: Text(tag),
                  selected: provider.selectedTag == tag,
                  onSelected: (_) => provider.setSelectedTag(
                    provider.selectedTag == tag ? null : tag,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _DecisionTile extends StatelessWidget {
  const _DecisionTile({required this.decision});

  final DecisionModel decision;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<DecisionProvider>();
    final theme = Theme.of(context);

    return DecisionVaultCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  decision.title,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              IconButton(
                icon: Icon(
                  decision.isFavorite ? Icons.star : Icons.star_border,
                  color: decision.isFavorite ? Colors.amber : null,
                ),
                onPressed: () => provider.toggleFavorite(decision.id!),
              ),
            ],
          ),
          if (decision.description != null && decision.description!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(decision.description!, style: theme.textTheme.bodyMedium),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text('Priority ${decision.priority}')),
              Chip(label: Text('Score ${decision.weightedScore}')),
              if (decision.category != null && decision.category!.isNotEmpty)
                Chip(label: Text(decision.category!)),
              if (decision.isArchived) const Chip(label: Text('Archived')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  children: decision.tags.map((tag) => Chip(label: Text(tag))).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DecisionVaultButton(
                  label: 'Open',
                  icon: Icons.visibility,
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      AppRoutes.decisionDetail,
                      arguments: decision.id,
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DecisionVaultButton(
                  label: 'Edit',
                  icon: Icons.edit,
                  outlined: true,
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      AppRoutes.editDecision,
                      arguments: decision.id,
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (_) => DecisionVaultConfirmationDialog(
                      title: 'Delete decision',
                      content: 'This action cannot be undone.',
                      onConfirm: () => Navigator.of(context).pop(true),
                      onCancel: () => Navigator.of(context).pop(false),
                    ),
                  );

                  if (confirmed == true && context.mounted) {
                    await provider.deleteDecision(decision.id!);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
