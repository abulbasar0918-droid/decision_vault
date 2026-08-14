import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/decision_vault_card.dart';
import '../../../../shared/widgets/decision_vault_empty_state.dart';
import '../../../../shared/widgets/decision_vault_error.dart';
import '../../../../shared/widgets/decision_vault_loading.dart';
import '../providers/history_provider.dart';
import '../../data/models/history_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().loadRecent();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: Consumer<HistoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.history.isEmpty) {
            return const DecisionVaultLoading(message: 'Loading history');
          }

          if (provider.errorMessage != null && provider.history.isEmpty) {
            return DecisionVaultError(
              message: provider.errorMessage!,
              onRetry: provider.loadRecent,
            );
          }

          if (provider.history.isEmpty) {
            return const DecisionVaultEmptyState(
              icon: Icons.history,
              title: 'No history entries',
              subtitle: 'Action history will appear as decisions are updated.',
            );
          }

          return RefreshIndicator(
            onRefresh: provider.loadRecent,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.history.length,
              itemBuilder: (context, index) {
                final HistoryModel event = provider.history[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DecisionVaultCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.event,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (event.payload != null &&
                            event.payload!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(event.payload!),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          event.createdAt.toLocal().toString(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
