import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gemini_ui_app/config/router/app_router.dart';
import 'package:gemini_ui_app/config/theme/app_theme.dart';

Future<void> main() async {
  AppTheme.setSysterUIOverlayStyle(isDarkMode: true);
  await dotenv.load(fileName: ".env");
  runApp(ProviderScope(child: GeminiApp()));
}

class GeminiApp extends StatelessWidget {
  const GeminiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: AppTheme(isDarkMode: true).getTheme(),
    );
  }
}
