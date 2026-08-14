import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/core/constants/app_constants.dart';
import 'src/core/navigation/navigation_service.dart';
import 'src/core/routes/app_router.dart';
import 'src/core/routes/app_routes.dart';
import 'src/core/theme/app_theme.dart';
import 'src/features/decisions/presentation/providers/decision_provider.dart';
import 'src/features/decisions/presentation/providers/history_provider.dart';
import 'src/features/decisions/presentation/providers/journal_provider.dart';
import 'src/features/settings/presentation/providers/settings_provider.dart';

/// The root widget for Decision Vault.
///
/// This widget wires together the application theme, the routing system,
/// and the provider scope for state management.
class DecisionVaultApp extends StatelessWidget {
  const DecisionVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DecisionProvider>(create: (_) => DecisionProvider()),
        ChangeNotifierProvider<HistoryProvider>(create: (_) => HistoryProvider()),
        ChangeNotifierProvider<JournalProvider>(create: (_) => JournalProvider()),
        ChangeNotifierProvider<SettingsProvider>(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            navigatorKey: AppNavigationService.navigatorKey,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsProvider.themeMode,
            initialRoute: AppRoutes.initial,
            onGenerateRoute: AppRouter.generateRoute,
          );
        },
      ),
    );
  }
}
