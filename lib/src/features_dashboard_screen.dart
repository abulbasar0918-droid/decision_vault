import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/routes/app_routes.dart';
import 'features/decisions/presentation/providers/decision_provider.dart';
import 'shared/widgets/decision_vault_button.dart';
import 'shared/widgets/decision_vault_card.dart';
import 'shared/widgets/decision_vault_empty_state.dart';
import 'shared/widgets/decision_vault_loading.dart';
import 'dashboard_statistics_preview.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DecisionProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DecisionProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.decisions.isEmpty) {
          return const DecisionVaultLoading(message: 'Preparing dashboard');
        }

        return RefreshIndicator(
          onRefresh: provider.loadDecisions,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              _WelcomeHeader(provider: provider),
              const SizedBox(height: 20),
              _StatCards(provider: provider),
              const SizedBox(height: 20),
              DashboardStatisticsPreview(provider: provider),
              const SizedBox(height: 20),
              const Text('Quick actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: 180,
                    child: DecisionVaultButton(
                      label: 'New decision',
                      icon: Icons.add,
                      fullWidth: true,
                      onPressed: () => Navigator.of(context).pushNamed(AppRoutes.newDecision),
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    child: DecisionVaultButton(
                      label: 'Review list',
                      icon: Icons.list,
                      outlined: true,
                      fullWidth: true,
                      onPressed: () => Navigator.of(context).pushNamed(AppRoutes.decisions),
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    child: DecisionVaultButton(
                      label: 'History',
                      icon: Icons.history,
                      fullWidth: true,
                      outlined: true,
                      onPressed: () => Navigator.of(context).pushNamed(AppRoutes.history),
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    child: DecisionVaultButton(
                      label: 'Settings',
                      icon: Icons.settings,
                      fullWidth: true,
                      onPressed: () => Navigator.of(context).pushNamed(AppRoutes.settings),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Recent decisions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              if (provider.decisions.isEmpty)
                const DecisionVaultEmptyState(
                  icon: Icons.inbox_outlined,
                  title: 'No decisions yet',
                  subtitle: 'Create your first decision to populate this dashboard.',
                )
              else
                ...provider.decisions.take(3).map((decision) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DecisionVaultCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(decision.title, style: Theme.of(context).textTheme.titleMedium),
                                  const SizedBox(height: 6),
                                  Text(decision.description ?? 'No notes yet', style: Theme.of(context).textTheme.bodyMedium),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Chip(label: Text('P${decision.priority}')),
                          ],
                        ),
                      ),
                    )),
            ],
          ),
        );
      },
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({required this.provider});

  final DecisionProvider provider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecisionVaultCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Good morning', style: theme.textTheme.labelLarge),
          const SizedBox(height: 6),
          Text('Welcome back to ${AppConstants.appName}', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(AppConstants.appDescription, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          Text('You have ${provider.totalDecisions} decisions in your vault.', style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _StatCards extends StatelessWidget {
  const _StatCards({required this.provider});

  final DecisionProvider provider;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _StatCard(title: 'Total', value: '${provider.totalDecisions}', color: Colors.indigo),
        _StatCard(title: 'Active', value: '${provider.activeDecisions}', color: Colors.teal),
        _StatCard(title: 'Favorites', value: '${provider.favoriteDecisions}', color: Colors.amber),
        _StatCard(title: 'Archived', value: '${provider.archivedDecisions}', color: Colors.deepPurple),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value, required this.color});

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: DecisionVaultCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
