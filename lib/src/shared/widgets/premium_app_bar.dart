import 'package:flutter/material.dart';

/// A premium, Material 3-styled AppBar used across the app.
class PremiumAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PremiumAppBar({super.key, required this.title, this.actions});

  final String title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(76);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      elevation: 2,
      centerTitle: false,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      titleSpacing: 16,
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: colorScheme.primaryContainer,
            child: Icon(
              Icons.lock_outline,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  'Secure decisions, simply',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: colorScheme.onSurface.withAlpha(179)),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: actions ?? [
        IconButton(
          onPressed: () => Navigator.of(context).pushNamed('/search'),
          icon: const Icon(Icons.search),
          tooltip: 'Search',
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notifications',
          ),
        ),
      ],
    );
  }
}
