import 'package:flutter/material.dart';

import '../features/home/presentation/home_shell_page.dart';

class BjutCampusApp extends StatelessWidget {
  const BjutCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '日新工大',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F8F7),
        cardTheme: const CardThemeData(margin: EdgeInsets.zero, elevation: 0),
      ),
      home: const HomeShellPage(),
    );
  }
}
