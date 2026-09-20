import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const SharabyCenterApp());
}

class SharabyCenterApp extends StatelessWidget {
  const SharabyCenterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sharaby Center',
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}