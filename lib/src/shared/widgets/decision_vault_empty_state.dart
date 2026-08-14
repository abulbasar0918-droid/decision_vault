import 'package:flutter/material.dart';

class DecisionVaultEmptyState extends StatelessWidget {
  const DecisionVaultEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: style.titleLarge),
            const SizedBox(height: 8),
            Text(subtitle, style: style.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
