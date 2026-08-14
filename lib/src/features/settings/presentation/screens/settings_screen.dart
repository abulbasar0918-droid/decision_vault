import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/backup_service.dart';
import '../../../../shared/widgets/decision_vault_button.dart';
import '../../../../shared/widgets/decision_vault_card.dart';
import '../../../../shared/widgets/decision_vault_loading.dart';
import '../../presentation/providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isBusy = false;

  Future<void> _performAction(Future<String> Function() action, String successMessage) async {
    if (!mounted) return;

    setState(() {
      _isBusy = true;
    });

    final messenger = ScaffoldMessenger.maybeOf(context);
    try {
      final path = await action();
      if (!mounted) return;
      messenger?.showSnackBar(SnackBar(content: Text('$successMessage:\n$path')));
    } catch (error) {
      if (!mounted) return;
      messenger?.showSnackBar(SnackBar(content: Text('Operation failed: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: _isBusy
              ? const Center(child: DecisionVaultLoading(message: 'Processing...'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    DecisionVaultCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Theme', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 12),
                          RadioListTile<ThemeMode>(
                            value: ThemeMode.light,
                            groupValue: provider.themeMode,
                            title: const Text('Light'),
                            onChanged: (value) {
                              if (value != null) {
                                provider.setThemeMode(value);
                              }
                            },
                          ),
                          RadioListTile<ThemeMode>(
                            value: ThemeMode.dark,
                            groupValue: provider.themeMode,
                            title: const Text('Dark'),
                            onChanged: (value) {
                              if (value != null) {
                                provider.setThemeMode(value);
                              }
                            },
                          ),
                          RadioListTile<ThemeMode>(
                            value: ThemeMode.system,
                            groupValue: provider.themeMode,
                            title: const Text('System'),
                            onChanged: (value) {
                              if (value != null) {
                                provider.setThemeMode(value);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    DecisionVaultCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Backup and export', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 12),
                          DecisionVaultButton(
                            label: 'Create backup',
                            icon: Icons.archive,
                            fullWidth: true,
                            onPressed: () async {
                              await _performAction(
                                () => BackupService.instance.createBackup(),
                                'Backup saved to',
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          DecisionVaultButton(
                            label: 'Restore latest backup',
                            icon: Icons.restore,
                            fullWidth: true,
                            outlined: true,
                            onPressed: () async {
                              final settingsProvider = context.read<SettingsProvider>();
                              await _performAction(
                                () async {
                                  final path = await BackupService.instance.restoreLatestBackup();
                                  await settingsProvider.reloadTheme();
                                  return path;
                                },
                                'Restored from',
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          DecisionVaultButton(
                            label: 'Export to JSON',
                            icon: Icons.code,
                            fullWidth: true,
                            onPressed: () async {
                              await _performAction(
                                () => BackupService.instance.exportToJson(),
                                'JSON export saved to',
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          DecisionVaultButton(
                            label: 'Export to PDF',
                            icon: Icons.picture_as_pdf,
                            fullWidth: true,
                            outlined: true,
                            onPressed: () async {
                              await _performAction(
                                () => BackupService.instance.exportToPdf(),
                                'PDF export saved to',
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    DecisionVaultCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('App info', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 12),
                          Text('Version: 1.0.0', style: Theme.of(context).textTheme.bodyLarge),
                          const SizedBox(height: 8),
                          Text('Decision Vault is designed to work offline and keep your data local.', style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 8),
                          Text('Future AI Ready: architecture is prepared for optional AI-driven insights.', style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    DecisionVaultCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Security', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 12),
                          Text('Offline data only. No analytics, no tracking, and minimal permissions.', style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 8),
                          Text('Your decisions stay private to this device.', style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    DecisionVaultButton(
                      label: 'View history',
                      icon: Icons.history,
                      fullWidth: true,
                      onPressed: () => Navigator.of(context).pushNamed(AppRoutes.history),
                    ),
                    const SizedBox(height: 12),
                    DecisionVaultButton(
                      label: 'Open journal',
                      icon: Icons.book,
                      fullWidth: true,
                      outlined: true,
                      onPressed: () => Navigator.of(context).pushNamed(AppRoutes.journal),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
