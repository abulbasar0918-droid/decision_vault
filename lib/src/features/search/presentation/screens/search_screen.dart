import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../presentation/providers/search_provider.dart';
import '../../../../shared/widgets/decision_vault_card.dart';
import '../../../../shared/widgets/decision_vault_loading.dart';
import '../../../../shared/widgets/decision_vault_empty_state.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearch(String q) {
    final provider = context.read<SearchProvider>();
    if (q.trim().isEmpty) {
      provider.clear();
      return;
    }
    provider.searchAll(q.trim());
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SearchProvider>(
      create: (_) => SearchProvider(),
      child: Consumer<SearchProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            appBar: AppBar(
              title: TextField(
                controller: _controller,
                decoration: const InputDecoration(hintText: 'Search across decisions, journal and history'),
                textInputAction: TextInputAction.search,
                onSubmitted: _onSearch,
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    provider.clear();
                  },
                )
              ],
            ),
            body: provider.isSearching
                ? const Center(child: DecisionVaultLoading(message: 'Searching'))
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (provider.errorMessage != null) ...[
                        Text(provider.errorMessage!, style: Theme.of(context).textTheme.bodyLarge),
                      ],

                      // Decisions
                      const Text('Decisions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      if (provider.decisions.isEmpty)
                        const DecisionVaultEmptyState(icon: Icons.folder_open_outlined, title: 'No matching decisions', subtitle: '')
                      else
                        ...provider.decisions.map((d) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: DecisionVaultCard(
                                child: ListTile(
                                  title: Text(d.title),
                                  subtitle: Text(d.description ?? ''),
                                ),
                              ),
                            )),

                      const SizedBox(height: 16),

                      // Journal
                      const Text('Journal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      if (provider.journals.isEmpty)
                        const DecisionVaultEmptyState(icon: Icons.note_outlined, title: 'No matching journal entries', subtitle: '')
                      else
                        ...provider.journals.map((j) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: DecisionVaultCard(
                                child: ListTile(
                                  title: Text(j.title),
                                  subtitle: Text(j.body ?? ''),
                                ),
                              ),
                            )),

                      const SizedBox(height: 16),

                      // History
                      const Text('History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      if (provider.history.isEmpty)
                        const DecisionVaultEmptyState(icon: Icons.history, title: 'No matching history entries', subtitle: '')
                      else
                        ...provider.history.map((h) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: DecisionVaultCard(
                                child: ListTile(
                                  title: Text(h.event),
                                  subtitle: Text(h.payload ?? ''),
                                ),
                              ),
                            )),
                    ],
                  ),
          );
        },
      ),
    );
  }
}
