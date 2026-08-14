import 'package:flutter/material.dart';

import 'premium_app_bar.dart';

/// A reusable scaffold wrapper for Decision Vault pages.
///
/// This widget provides a consistent application shell for pages that are
/// added later. It uses the PremiumAppBar for a unified premium header.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    this.body,
  });

  final String title;
  final Widget? body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PremiumAppBar(title: title),
      body: body ??
          Center(
            child: Text(
              'Welcome to $title',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
    );
  }
}
