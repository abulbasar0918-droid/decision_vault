import 'package:flutter/material.dart';

import 'features/decisions/presentation/providers/decision_provider.dart';

class DashboardStatisticsPreview extends StatelessWidget {
  const DashboardStatisticsPreview({super.key, required this.provider});

  final DecisionProvider provider;

  @override
  Widget build(BuildContext context) {
    final highPriorityCount = provider.decisions.where((decision) => decision.priority >= 3).length;
    final positiveScoreCount = provider.decisions.where((decision) => decision.weightedScore >= 50).length;
    final archivedCount = provider.archivedDecisions;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 240),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Activity overview', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StatisticsTile(label: 'High priority', value: highPriorityCount),
                  _StatisticsTile(label: 'Positive score', value: positiveScoreCount),
                  _StatisticsTile(label: 'Archived', value: archivedCount),
                  _StatisticsTile(label: 'Categories', value: provider.categories.length),
                ],
              ),
              const SizedBox(height: 16),
              Text('Priority matrix', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12),
              _PriorityMatrix(provider: provider),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatisticsTile extends StatelessWidget {
  const _StatisticsTile({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              Text('$value', style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriorityMatrix extends StatelessWidget {
  const _PriorityMatrix({required this.provider});

  final DecisionProvider provider;

  @override
  Widget build(BuildContext context) {
    final lowScoreHighPriority = provider.decisions.where((decision) => decision.priority >= 3 && decision.weightedScore < 50).length;
    final highScoreHighPriority = provider.decisions.where((decision) => decision.priority >= 3 && decision.weightedScore >= 50).length;
    final lowScoreLowPriority = provider.decisions.where((decision) => decision.priority < 3 && decision.weightedScore < 50).length;
    final highScoreLowPriority = provider.decisions.where((decision) => decision.priority < 3 && decision.weightedScore >= 50).length;

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _PriorityCell(title: 'Low score, low priority', value: lowScoreLowPriority, color: Colors.grey.shade100)),
            const SizedBox(width: 8),
            Expanded(child: _PriorityCell(title: 'High score, low priority', value: highScoreLowPriority, color: Colors.green.shade50)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _PriorityCell(title: 'Low score, high priority', value: lowScoreHighPriority, color: Colors.orange.shade50)),
            const SizedBox(width: 8),
            Expanded(child: _PriorityCell(title: 'High score, high priority', value: highScoreHighPriority, color: Colors.blue.shade50)),
          ],
        ),
      ],
    );
  }
}

class _PriorityCell extends StatelessWidget {
  const _PriorityCell({required this.title, required this.value, required this.color});

  final String title;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Text('$value', style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}
