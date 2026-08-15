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

  Future<void> _performAction(
    Future<String> Function() action,
    String successMessage,
  ) async {
    if (!mounted) return;

    setState(() {
      _isBusy = true;
    });

    try {
      final path = await action();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$successMessage:\n$path'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Operation failed: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
        final theme = Theme.of(context);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
          ),
          body: _isBusy
              ? const Center(
                  child: DecisionVaultLoading(
                    message: 'Processing...',
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  children: [
                    _SectionHeader(
                      icon: Icons.palette_outlined,
                      title: 'Appearance',
                      subtitle: 'Customize how Decision Vault looks.',
                    ),
                    const SizedBox(height: 10),

                    DecisionVaultCard(
                      child: Column(
                        children: [
                          RadioListTile<ThemeMode>(
                            contentPadding: EdgeInsets.zero,
                            value: ThemeMode.light,
                            groupValue: provider.themeMode,
                            title: const Text('Light'),
                            subtitle: const Text(
                              'Use the light appearance.',
                            ),
                            secondary: const Icon(Icons.light_mode_outlined),
                            onChanged: (value) {
                              if (value != null) {
                                provider.setThemeMode(value);
                              }
                            },
                          ),
                          const Divider(height: 1),
                          RadioListTile<ThemeMode>(
                            contentPadding: EdgeInsets.zero,
                            value: ThemeMode.dark,
                            groupValue: provider.themeMode,
                            title: const Text('Dark'),
                            subtitle: const Text(
                              'Use the dark appearance.',
                            ),
                            secondary: const Icon(Icons.dark_mode_outlined),
                            onChanged: (value) {
                              if (value != null) {
                                provider.setThemeMode(value);
                              }
                            },
                          ),
                          const Divider(height: 1),
                          RadioListTile<ThemeMode>(
                            contentPadding: EdgeInsets.zero,
                            value: ThemeMode.system,
                            groupValue: provider.themeMode,
                            title: const Text('System'),
                            subtitle: const Text(
                              'Follow your device setting.',
                            ),
                            secondary: const Icon(
                              Icons.brightness_auto_outlined,
                            ),
                            onChanged: (value) {
                              if (value != null) {
                                provider.setThemeMode(value);
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    _SectionHeader(
                      icon: Icons.backup_outlined,
                      title: 'Backup & Export',
                      subtitle:
                          'Protect your decisions and export your data.',
                    ),
                    const SizedBox(height: 10),

                    DecisionVaultCard(
                      child: Column(
                        children: [
                          DecisionVaultButton(
                            label: 'Create backup',
                            icon: Icons.archive_outlined,
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
                              final settingsProvider =
                                  context.read<SettingsProvider>();

                              await _performAction(
                                () async {
                                  final path = await BackupService
                                      .instance
                                      .restoreLatestBackup();

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
                            icon: Icons.data_object,
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
                            icon: Icons.picture_as_pdf_outlined,
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

                    const SizedBox(height: 24),

                    _SectionHeader(
                      icon: Icons.manage_history_outlined,
                      title: 'Your Data',
                      subtitle:
                          'Quick access to your saved decision information.',
                    ),
                    const SizedBox(height: 10),

                    DecisionVaultCard(
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              child: Icon(Icons.history),
                            ),
                            title: const Text('History'),
                            subtitle: const Text(
                              'View your recent decision activity.',
                            ),
                            trailing: const Icon(
                              Icons.chevron_right,
                            ),
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                AppRoutes.history,
                              );
                            },
                          ),
                          const Divider(height: 1),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              child: Icon(Icons.book_outlined),
                            ),
                            title: const Text('Journal'),
                            subtitle: const Text(
                              'Write and review your personal notes.',
                            ),
                            trailing: const Icon(
                              Icons.chevron_right,
                            ),
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                AppRoutes.journal,
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    _SectionHeader(
                      icon: Icons.info_outline,
                      title: 'About Decision Vault',
                      subtitle: 'Information about this application.',
                    ),
                    const SizedBox(height: 10),

                    DecisionVaultCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: theme.colorScheme.primaryContainer,
                                ),
                                child: Icon(
                                  Icons.account_balance_outlined,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Decision Vault',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const _InfoRow(
                            label: 'Version',
                            value: '1.0.0',
                          ),
                          const SizedBox(height: 10),
                          const _InfoRow(
                            label: 'Storage',
                            value: 'Offline / Local',
                          ),
                          const SizedBox(height: 10),
                          const _InfoRow(
                            label: 'Privacy',
                            value: 'Your data stays on this device',
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Decision Vault is designed to help you record, '
                            'organize, review, and improve important decisions '
                            'while keeping your information locally on your device.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    _SectionHeader(
                      icon: Icons.security_outlined,
                      title: 'Privacy & Security',
                      subtitle: 'Your data remains under your control.',
                    ),
                    const SizedBox(height: 10),

                    DecisionVaultCard(
                      child: Column(
                        children: [
                          const _SecurityRow(
                            icon: Icons.cloud_off_outlined,
                            title: 'Offline first',
                            subtitle:
                                'Core decision data is stored locally.',
                          ),
                          const Divider(height: 24),
                          const _SecurityRow(
                            icon: Icons.analytics_outlined,
                            title: 'No analytics',
                            subtitle:
                                'Decision Vault does not require analytics '
                                'to manage your decisions.',
                          ),
                          const Divider(height: 24),
                          const _SecurityRow(
                            icon: Icons.lock_outline,
                            title: 'Private by design',
                            subtitle:
                                'Your decisions remain on your device.',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'Future AI Ready',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'The application architecture can support optional '
                      'AI-driven insights in future versions without '
                      'changing the core offline workflow.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 22,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _SecurityRow extends StatelessWidget {
  const _SecurityRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}