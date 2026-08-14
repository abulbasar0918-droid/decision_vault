import 'package:flutter/material.dart';

class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionItem(icon: Icons.add, label: 'Create'),
      _ActionItem(icon: Icons.upload_file, label: 'Import'),
      _ActionItem(icon: Icons.share, label: 'Share'),
      _ActionItem(icon: Icons.settings, label: 'Configure'),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: actions,
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        onPressed: () {},
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}
