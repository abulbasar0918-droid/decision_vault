import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/statistics_provider.dart';
import '../../../../shared/widgets/decision_vault_card.dart';
import '../../../../shared/widgets/decision_vault_loading.dart';
import '../../../../shared/widgets/decision_vault_empty_state.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatisticsProvider>().load();
    });
  }

  Widget _buildBar(BuildContext context, String label, int value, int max) {
    final double fraction = max > 0 ? (value / max).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 18,
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                child: Stack(
                  children: [
                    FractionallySizedBox(widthFactor: fraction, child: Container(decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(8)))),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text('$value', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StatisticsProvider>(
      create: (_) => StatisticsProvider(),
      child: Consumer<StatisticsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Scaffold(body: DecisionVaultLoading(message: 'Loading statistics'));
          }

          if (provider.errorMessage != null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Statistics')),
              body: Center(child: Text(provider.errorMessage!)),
            );
          }

          final maxCount = provider.total > 0 ? provider.total : 1;

          return Scaffold(
            appBar: AppBar(title: const Text('Statistics')),
            body: RefreshIndicator(
              onRefresh: () => provider.load(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  DecisionVaultCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Overview', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        Wrap(spacing: 12, runSpacing: 12, children: [
                          _StatisticTile(label: 'Total', value: provider.total),
                          _StatisticTile(label: 'Active', value: provider.active),
                          _StatisticTile(label: 'Favorites', value: provider.favorites),
                          _StatisticTile(label: 'Archived', value: provider.archived),
                        ]),
                        const SizedBox(height: 12),
                        Text('Weighted score', style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 8),
                        Text('Average: ${provider.averageScore.toStringAsFixed(1)}', style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: 4),
                        Text('Sum: ${provider.sumScore.toStringAsFixed(1)}', style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  DecisionVaultCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('By category', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        if (provider.byCategory.isEmpty) const DecisionVaultEmptyState(icon: Icons.folder_open_outlined, title: 'No categories', subtitle: 'No decisions yet.')
                        else ...provider.byCategory.entries.map((e) => _buildBar(context, e.key.isEmpty ? 'Uncategorized' : e.key, e.value, maxCount)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  DecisionVaultCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('By tag', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        if (provider.byTag.isEmpty) const DecisionVaultEmptyState(icon: Icons.tag, title: 'No tags', subtitle: 'No tags have been applied.' )
                        else ...provider.byTag.entries.map((e) => _buildBar(context, e.key, e.value, maxCount)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  DecisionVaultCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Priority distribution', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        if (provider.priorityDistribution.isEmpty) const DecisionVaultEmptyState(icon: Icons.flag, title: 'No priorities', subtitle: 'No decisions yet.' )
                        else ...[1,2,3,4].map((p) => _buildBar(context, 'P$p', provider.priorityDistribution[p] ?? 0, maxCount)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  DecisionVaultCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Recent activity', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        if (provider.recentActivity.isEmpty) const DecisionVaultEmptyState(icon: Icons.history, title: 'No recent activity', subtitle: '')
                        else Column(children: provider.recentActivity.entries.map((e) => _buildBar(context, e.key, e.value, provider.recentActivity.values.fold<int>(0, (a,b)=> a>b? a:b))).toList()),
                      ],
                    ),
                  ),

                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatisticTile extends StatelessWidget {
  const _StatisticTile({required this.label, required this.value});
  final String label;
  final int value;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: DecisionVaultCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Text('$value', style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}
