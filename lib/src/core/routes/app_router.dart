import 'package:flutter/material.dart';

import '../../features/decisions/presentation/screens/decision_detail_screen.dart';
import '../../features/decisions/presentation/screens/decision_editor_screen.dart';
import '../../features/decisions/presentation/screens/decision_list_screen.dart';
import '../../features/decisions/presentation/screens/journal_list_screen.dart';
import '../../features/decisions/presentation/screens/journal_editor_screen.dart';
import '../../features/decisions/presentation/screens/history_screen.dart';
import '../../features/decisions/presentation/screens/category_management_screen.dart';
import '../../features/decisions/presentation/screens/tag_management_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/statistics/presentation/screens/statistics_screen.dart';
import '../../features_home_screen.dart';
import 'app_routes.dart';

/// Centralized route generation for Decision Vault.
///
/// This router isolates navigation logic from presentation and allows the
/// application to resolve routes consistently from a single location.
class AppRouter {
  AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.initial:
      case AppRoutes.home:
        return MaterialPageRoute<void>(
          builder: (_) => const HomeScreen(),
        );
      case AppRoutes.decisions:
        return MaterialPageRoute<void>(
          builder: (_) => const DecisionListScreen(),
        );
      case AppRoutes.newDecision:
        return MaterialPageRoute<void>(
          builder: (_) => const DecisionEditorScreen(),
        );
      case AppRoutes.editDecision:
        final decisionId = settings.arguments as int?;
        return MaterialPageRoute<void>(
          builder: (_) => DecisionEditorScreen(decisionId: decisionId),
        );
      case AppRoutes.decisionDetail:
        final decisionId = settings.arguments as int?;
        return MaterialPageRoute<void>(
          builder: (_) => DecisionDetailScreen(decisionId: decisionId ?? 0),
        );
      case AppRoutes.journal:
        return MaterialPageRoute<void>(
          builder: (_) => const JournalListScreen(),
        );
      case AppRoutes.newJournal:
        return MaterialPageRoute<void>(
          builder: (_) => const JournalEditorScreen(),
        );
      case AppRoutes.editJournal:
        final journalId = settings.arguments as int?;
        return MaterialPageRoute<void>(
          builder: (_) => JournalEditorScreen(journalId: journalId),
        );
      case AppRoutes.history:
        return MaterialPageRoute<void>(
          builder: (_) => const HistoryScreen(),
        );
      case AppRoutes.settings:
        return MaterialPageRoute<void>(
          builder: (_) => const SettingsScreen(),
        );
      case AppRoutes.categories:
        return MaterialPageRoute<void>(
          builder: (_) => const CategoryManagementScreen(),
        );
      case AppRoutes.tags:
        return MaterialPageRoute<void>(
          builder: (_) => const TagManagementScreen(),
        );
      case AppRoutes.search:
        return MaterialPageRoute<void>(
          builder: (_) => const SearchScreen(),
        );
      case AppRoutes.statistics:
        return MaterialPageRoute<void>(
          builder: (_) => const StatisticsScreen(),
        );
      default:
        return MaterialPageRoute<void>(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Page not found')),
            body: const Center(child: Text('Page not found')),
          ),
        );
    }
  }
}
