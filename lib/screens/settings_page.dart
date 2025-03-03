import 'package:flutter/material.dart';
import './nutrition_page.dart';
import './calendar_page.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
import '../globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _proteinsController = TextEditingController();
  final TextEditingController _fatsController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _proteinsController.text = globals.proteins.toString();
    _fatsController.text = globals.fats.toString();
    _carbsController.text = globals.carbs.toString();
  }

  void _saveSettings() {
    // Обновляем глобальные переменные
    setState(() {
      globals.proteins = int.tryParse(_proteinsController.text) ?? 0;
      globals.fats = int.tryParse(_fatsController.text) ?? 0;
      globals.carbs = int.tryParse(_carbsController.text) ?? 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Настройки сохранены')),
    );
  }

  // Сохранение данных
  Future<void> _saveUserPFC() async {
    globals.proteins = globals.proteins;
    globals.fats = globals.fats;
    globals.carbs = globals.carbs;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('proteins', globals.proteins);
    await prefs.setInt('fats', globals.fats);
    await prefs.setInt('carbs', globals.carbs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            TextField(
              controller: _proteinsController,
              decoration: const InputDecoration(labelText: 'Белки (г)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _fatsController,
              decoration: const InputDecoration(labelText: 'Жиры (г)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _carbsController,
              decoration: const InputDecoration(labelText: 'Углеводы (г)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                _saveSettings(); // сохраняем изменения
                _saveUserPFC(); // изменяем в бд
              }, // Сохраняем изменения
              child: const Text('Сохранить изменения'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),

      // Панель навигации
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Индекс текущей страницы (настройки)
        selectedItemColor: Colors.red,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    CalendarPage(),
                transitionDuration: Duration.zero, // Убирает анимацию перехода
                reverseTransitionDuration:
                    Duration.zero, // Убирает анимацию возврата
              ),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    const NutritionPage(),
                transitionDuration: Duration.zero, // Убирает анимацию перехода
                reverseTransitionDuration:
                    Duration.zero, // Убирает анимацию возврата
              ),
            );
          } else if (index == 2) {
            // Остаемся на текущей странице
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Тренировки',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Еда',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
      ),
    );
  }
}
