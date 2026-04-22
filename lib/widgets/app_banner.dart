import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppBanner extends StatelessWidget {
  final String title;
  final Color color;

  const AppBanner({
    super.key,
    required this.title,
    this.color = AppTheme.green,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: color,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
