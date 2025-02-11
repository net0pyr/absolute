import 'package:flutter/material.dart';
import './screens/nutrition_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'absolute',
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.white,
        // Переопределяем цветовую схему для светлой темы
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.red),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: const Color(0xFF121212),
        // Переопределяем цветовую схему для темной темы
        colorScheme: ColorScheme.dark(primary: Colors.red),
      ),
      themeMode: ThemeMode.dark,
      home: const NutritionPage(),
    );
  }
}
