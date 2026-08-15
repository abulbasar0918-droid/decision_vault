import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/decision_provider.dart';
import '../../data/models/decision_model.dart';

class ArchiveFavoritesScreen extends StatefulWidget {
  const ArchiveFavoritesScreen({super.key});

  @override
  State<ArchiveFavoritesScreen> createState() =>
      _ArchiveFavoritesScreenState();
}

class _ArchiveFavoritesScreenState
    extends State<ArchiveFavoritesScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DecisionProvider>().loadDecisions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Archive & Favorites'),
      ),
      body: Consumer<DecisionProvider>(
        builder: (context, provider, child) {
          final decisions = _selectedTab == 0
              ? provider.decisions
                  .where((decision) => decision.isFavorite)
                  .toList()
              : provider.decisions
                  .where((decision) => decision.isArchived)
                  .toList();

          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.errorMessage ??
                          'Something went wrong.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: provider.loadDecisions,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  8,
                ),
                child: SegmentedButton<int>(
                  segments: const [
                    ButtonSegment<int>(
                      value: 0,
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                    ButtonSegment<int>(
                      value: 1,
                      icon: Icon(Icons.archive),
                      label: Text('Archived'),
                    ),
                  ],
                  selected: {_selectedTab},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _selectedTab = selection.first;
                    });
                  },
                ),
              ),
              Expanded(
                child: decisions.isEmpty
                    ? _EmptyState(
                        isFavorite: _selectedTab == 0,
                      )
                    : RefreshIndicator(
                        onRefresh: provider.loadDecisions,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: decisions.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final decision = decisions[index];

                            return _DecisionCard(
                              decision: decision,
                              isFavoriteTab: _selectedTab == 0,
                              onFavorite: () async {
                                if (decision.id == null) return;

                                await provider.toggleFavorite(
                                  decision.id!,
                                );
                              },
                              onArchive: () async {
                                if (decision.id == null) return;

                                await provider.toggleArchive(
                                  decision.id!,
                                );
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DecisionCard extends StatelessWidget {
  const _DecisionCard({
    required this.decision,
    required this.isFavoriteTab,
    required this.onFavorite,
    required this.onArchive,
  });

  final DecisionModel decision;
  final bool isFavoriteTab;
  final VoidCallback onFavorite;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    decision.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: decision.isFavorite
                      ? 'Remove favorite'
                      : 'Add favorite',
                  onPressed: onFavorite,
                  icon: Icon(
                    decision.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                  ),
                ),
              ],
            ),
            if (decision.description != null &&
                decision.description!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                decision.description!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (decision.category != null &&
                    decision.category!.trim().isNotEmpty)
                  Chip(
                    avatar: const Icon(
                      Icons.category_outlined,
                      size: 18,
                    ),
                    label: Text(decision.category!),
                  ),
                if (decision.priority > 0)
                  Chip(
                    avatar: const Icon(
                      Icons.priority_high,
                      size: 18,
                    ),
                    label: Text(
                      'Priority ${decision.priority}',
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onArchive,
                  icon: Icon(
                    decision.isArchived
                        ? Icons.unarchive
                        : Icons.archive_outlined,
                  ),
                  label: Text(
                    decision.isArchived
                        ? 'Unarchive'
                        : 'Archive',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.isFavorite,
  });

  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isFavorite
                  ? Icons.favorite_border
                  : Icons.archive_outlined,
              size: 64,
            ),
            const SizedBox(height: 20),
            Text(
              isFavorite
                  ? 'No favorite decisions'
                  : 'No archived decisions',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isFavorite
                  ? 'Decisions you mark as favorite will appear here.'
                  : 'Decisions you archive will appear here.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}