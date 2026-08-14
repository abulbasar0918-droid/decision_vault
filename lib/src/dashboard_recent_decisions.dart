import 'package:flutter/material.dart';

import 'shared/widgets/empty_state.dart';

class DashboardRecentDecisions extends StatelessWidget {
  const DashboardRecentDecisions({super.key});

  @override
  Widget build(BuildContext context) {
    // No fake data - show an empty state for recent decisions until real data
    return SizedBox(
      height: 220,
      child: const EmptyState(
        icon: Icons.inbox_outlined,
        title: 'No recent decisions',
        subtitle: 'Create your first decision or import existing ones.',
      ),
    );
  }
}
