import 'package:flutter/material.dart';
import '../../entity/eating.dart';
import '../../entity/dish.dart';
import '../../globals.dart' as globals;
import 'dart:async';
import '../../db_helper.dart';
import 'package:sqflite/sqflite.dart';

class AddMealPage extends StatefulWidget {
  final DateTime selectedDate;

  const AddMealPage({super.key, required this.selectedDate});

  @override
  _AddMealPageState createState() => _AddMealPageState();
}

class _AddMealPageState extends State<AddMealPage> {
  List<Dish> filteredDishes = [];
  Dish? selectedDish;
  int weight = 100;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredDishes = globals.availableDishes;
    searchController.addListener(_filterDishes);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterDishes() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredDishes = globals.availableDishes
          .where((dish) => dish.name.toLowerCase().contains(query))
          .toList();
    });
  }

  void _addDishToDishes() {
    if (selectedDish != null) {
      _addEating(widget.selectedDate, weight, selectedDish!);
      Navigator.pop(
        context,
      );
      // Navigator.pop(context);
    }
  }

  Future<void> _addEating(DateTime date, int weight, Dish dish) async {
    DateTime dateEating = DateTime.utc(
      date.year,
      date.month,
      date.day,
      date.hour,
      date.minute,
      date.second,
    );

    // Создаем объект Eating с временным id = 0
    Eating eating = Eating(date: dateEating, weight: weight, dish: dish, id: 0);

    // Добавляем запись в глобальную коллекцию
    if (globals.dishes[date] == null) globals.dishes[date] = [];
    globals.dishes[date]?.add(eating);
    int index = globals.dishes[date]!.indexOf(eating);

    // Вставляем запись в локальную SQLite базу данных, используем 'dishId' вместо 'dish'
    final db = await DBHelper.instance.database;
    int insertedId = await db.insert(
      'eatings',
      {
        'date': dateEating.toIso8601String(),
        'weight': weight,
        'dishId': dish.id, // исправлено: используем имя поля dishId
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (insertedId > 0) {
      setState(() {
        globals.dishes[date]?[index].id = insertedId;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка при добавлении блюда')),
      );
    }
  }

  Future<void> _addToDB(int proteins, int fats, int carbs, String name) async {
    final db = await DBHelper.instance.database;
    int insertedId = await db.insert(
      'dishes',
      {
        'proteins': proteins,
        'fats': fats,
        'carbs': carbs,
        'name': name,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (insertedId > 0) {
      setState(() {
        globals.availableDishes.add(
          Dish(
            name: name,
            proteins: proteins.toDouble(),
            fats: fats.toDouble(),
            carbs: carbs.toDouble(),
            id: insertedId,
          ),
        );
        filteredDishes = globals.availableDishes;
        _filterDishes();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка при добавлении блюда')),
      );
    }
  }

  void _showAddDishDialog() {
    String name = '';
    double proteins = 0.0;
    double fats = 0.0;
    double carbs = 0.0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Добавить новое блюдо'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  decoration:
                      const InputDecoration(labelText: 'Название блюда'),
                  onChanged: (value) {
                    name = value;
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Белки (г)'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    proteins = double.tryParse(value) ?? 0.0;
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Жиры (г)'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    fats = double.tryParse(value) ?? 0.0;
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Углеводы (г)'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    carbs = double.tryParse(value) ?? 0.0;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                if (name.isNotEmpty) {
                  setState(() {
                    _addToDB(
                        proteins.toInt(), fats.toInt(), carbs.toInt(), name);
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Добавить'),
            ),
          ],
        );
      },
    );
  }

// Добавьте этот метод в класс _AddMealPageState для удаления блюда из базы данных и списка
  Future<void> _deleteDish(Dish dish) async {
    final db = await DBHelper.instance.database;
    await db.delete(
      'dishes',
      where: 'id = ?',
      whereArgs: [dish.id],
    );
    setState(() {
      globals.availableDishes.removeWhere((d) => d.id == dish.id);
      filteredDishes = globals.availableDishes;
      _filterDishes();
      if (selectedDish?.id == dish.id) {
        selectedDish = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить прием пищи'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Поиск блюда',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: filteredDishes.length,
                itemBuilder: (context, index) {
                  Dish dish = filteredDishes[index];
                  return ListTile(
                    title: Text(dish.name),
                    subtitle: Text(
                      'Белки: ${dish.proteins}, Жиры: ${dish.fats}, Углеводы: ${dish.carbs}',
                    ),
                    onTap: () {
                      setState(() {
                        selectedDish = dish;
                      });
                    },
                    selected: selectedDish == dish,
                    selectedTileColor: Colors.grey[300],
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteDish(dish);
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Вес (в граммах)'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  weight = int.tryParse(value) ?? 100;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _addDishToDishes,
                  child: const Text('Добавить'),
                ),
                TextButton(
                  onPressed: _showAddDishDialog,
                  child: const Text('Добавить новое блюдо'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
