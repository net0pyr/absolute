import 'package:flutter/material.dart';
import '../../entity/exercise.dart';
import '../../globals.dart'
    as globals; // Импортируем файл с глобальной переменной exercisesList
import '../../db_helper.dart';
import 'package:sqflite/sqflite.dart';

/// Страница для выбора упражнения из списка или добавления нового упражнения
class ExerciseSelectionPage extends StatefulWidget {
  final void Function(String)
      onExerciseSelected; // Коллбэк, вызываемый при выборе упражнения

  const ExerciseSelectionPage({
    super.key,
    required this.onExerciseSelected,
  });

  @override
  _ExerciseSelectionPageState createState() => _ExerciseSelectionPageState();
}

class _ExerciseSelectionPageState extends State<ExerciseSelectionPage> {
  // Контроллеры для ввода текста в полях
  final TextEditingController _exerciseController =
      TextEditingController(); // Для ввода нового упражнения
  final TextEditingController _searchController =
      TextEditingController(); // Для поиска по списку упражнений

  // Список упражнений, отфильтрованный по поисковому запросу
  late List<AvailableExercise> _filteredExercises;

  @override
  void dispose() {
    _exerciseController.dispose(); // Освобождаем ресурсы контроллера
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Инициализируем отфильтрованный список всеми доступными упражнениями
    _filteredExercises = List.from(globals.availableExercises);
  }

  /// Метод для фильтрации упражнений на основе поискового запроса
  void _filterExercises(String query) {
    setState(() {
      _filteredExercises = globals.availableExercises
          .where((exercise) =>
              exercise.name.toLowerCase().contains(query.toLowerCase()))
          .toList(); // Фильтруем список упражнений
    });
  }

  Future<void> _addToDB(String name) async {
    final db = await DBHelper.instance.database;
    // Вставляем новое упражнение в таблицу 'available_exercises'
    int insertedId = await db.insert(
      'available_exercises',
      {
        'name': name,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (insertedId > 0) {
      final newExercise = AvailableExercise(name: name, id: insertedId);
      globals.availableExercises.add(newExercise);
      _filteredExercises.add(newExercise);
      _filterExercises(_searchController.text);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка при добавлении упражнения')),
      );
    }
  }

  /// Метод для открытия диалогового окна добавления нового упражнения
  void _addExerciseDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Добавить новое упражнение'),
          content: TextField(
            controller: _exerciseController,
            decoration: const InputDecoration(
              labelText: 'Название упражнения',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _exerciseController.clear();
                Navigator.pop(
                    context); // Закрываем диалоговое окно без добавления
              },
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _addToDB(_exerciseController
                      .text); // Добавляем новое упражнение в БД
                });
                _exerciseController.clear();
                Navigator.pop(
                    context); // Закрываем диалоговое окно после добавления
              },
              child: const Text('Добавить'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выбор упражнения'),
      ),
      body: Column(
        children: [
          // Поле для поиска упражнения
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged:
                  _filterExercises, // Обновляем список упражнений при каждом изменении текста
              decoration: const InputDecoration(
                labelText: 'Поиск упражнений',
                prefixIcon: Icon(Icons.search), // Иконка поиска в поле ввода
              ),
            ),
          ),
          // Список упражнений, отфильтрованный по поисковому запросу
          Expanded(
            child: ListView.builder(
              itemCount: _filteredExercises.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_filteredExercises[index].name),
                  onTap: () {
                    widget.onExerciseSelected(_filteredExercises[index].name);
                    Navigator.pop(context);
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _deleteExercise(_filteredExercises[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // Кнопка для добавления нового упражнения
      floatingActionButton: FloatingActionButton(
        onPressed: _addExerciseDialog,
        child: const Icon(
            Icons.add), // Открываем диалог добавления нового упражнения
      ),
    );
  }

  Future<void> _deleteExercise(AvailableExercise exercise) async {
    final db = await DBHelper.instance.database;
    await db.delete(
      'available_exercises',
      where: 'id = ?',
      whereArgs: [exercise.id],
    );
    setState(() {
      globals.availableExercises.removeWhere((e) => e.id == exercise.id);
      _filteredExercises.removeWhere((e) => e.id == exercise.id);
    });
  }
}
