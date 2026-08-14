import 'package:flutter/material.dart';

/// Simple responsive layout helper. Provides breakpoints so features can
/// switch between rail/side navigation and bottom navigation.
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key, required this.smallScreen, required this.largeScreen});

  final Widget smallScreen;
  final Widget largeScreen;

  static const double kLargeBreakpoint = 900;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth >= kLargeBreakpoint) {
        return largeScreen;
      }
      return smallScreen;
    });
  }
}
