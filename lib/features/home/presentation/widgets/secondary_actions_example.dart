// Example usage of SecondaryActions widget in the optimized homepage
// 
// This file demonstrates how to integrate the SecondaryActions widget
// into your home screen for optimal user experience.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymbro_flutter_new/features/home/presentation/widgets/secondary_actions.dart';
import 'package:gymbro_flutter_new/shared/presentation/theme/app_icons.dart';

/// Example integration in a home screen
class HomeScreenWithSecondaryActions extends ConsumerWidget {
  const HomeScreenWithSecondaryActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Your other homepage widgets would go here
              // e.g., greeting, active workout banner, progress cards, etc.
              
              // Example spacing
              SizedBox(height: 32),
              
              // Secondary Actions Widget
              SecondaryActions(),
              
              // Additional spacing at bottom
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

/// Example showing the widget in both themes
class SecondaryActionsThemePreview extends StatefulWidget {
  const SecondaryActionsThemePreview({super.key});

  @override
  State<SecondaryActionsThemePreview> createState() => _SecondaryActionsThemePreviewState();
}

class _SecondaryActionsThemePreviewState extends State<SecondaryActionsThemePreview> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secondary Actions Preview',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Secondary Actions Preview'),
          actions: [
            IconButton(
              onPressed: () => setState(() => isDarkMode = !isDarkMode),
              icon: Icon(isDarkMode ? AppIcons.lightMode : AppIcons.darkMode),
            ),
          ],
        ),
        body: const Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                'Secondary Actions Widget',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              SecondaryActions(),
            ],
          ),
        ),
      ),
    );
  }
}
