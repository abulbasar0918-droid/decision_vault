import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/decision_vault_card.dart';
import '../../../../shared/widgets/decision_vault_error.dart';
import '../../../../shared/widgets/decision_vault_loading.dart';
import '../../../../shared/widgets/decision_vault_empty_state.dart';
import '../../data/models/journal_model.dart';
import '../providers/journal_provider.dart';

class JournalListScreen extends StatefulWidget {
  const JournalListScreen({super.key});

  @override
  State<JournalListScreen> createState() => _JournalListScreenState();
}

class _JournalListScreenState extends State<JournalListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JournalProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Journal')),
      body: Consumer<JournalProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.items.isEmpty) {
            return const DecisionVaultLoading(message: 'Loading journal');
          }

          if (provider.errorMessage != null && provider.items.isEmpty) {
            return DecisionVaultError(
              message: provider.errorMessage!,
              onRetry: provider.loadAll,
            );
          }

          if (provider.items.isEmpty) {
            return const DecisionVaultEmptyState(
              icon: Icons.note_outlined,
              title: 'No journal entries',
              subtitle: 'Write down your thoughts to reflect later.',
            );
          }

          return RefreshIndicator(
            onRefresh: provider.loadAll,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.items.length,
              itemBuilder: (context, index) {
                final JournalModel item = provider.items[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DecisionVaultCard(
                    child: ListTile(
                      title: Text(item.title),
                      subtitle: Text(item.body ?? ''),
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
