import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/entrance_screen.dart';

void main() {
  runApp(const JobbyApp());
}

class JobbyApp extends StatelessWidget {
  const JobbyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jobby',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const EntranceScreen(),
    );
  }
}
