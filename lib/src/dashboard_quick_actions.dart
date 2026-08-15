import 'package:flutter/material.dart';
import 'core/routes/app_routes.dart';

class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionItem(icon: Icons.add, label: 'Create', onPressed: () {}),
      _ActionItem(icon: Icons.upload_file, label: 'Import', onPressed: () {}),
      _ActionItem(icon: Icons.share, label: 'Share', onPressed: () {}),
      _ActionItem(icon: Icons.settings, label: 'Configure', onPressed: () {}),
      _ActionItem(icon: Icons.bar_chart, label: 'Statistics', onPressed: () => Navigator.pushNamed(context, AppRoutes.statistics)),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: actions,
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({required this.icon, required this.label, required this.onPressed});

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}
