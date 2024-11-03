import 'package:flutter/material.dart';
import 'package:qr_code_app/theme/app_theme.dart';
import 'package:qr_code_app/view/screens/unified_scanner_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Scanner Pro',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const UnifiedScannerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
