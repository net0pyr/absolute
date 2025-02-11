import 'package:flutter/material.dart';
// import '../../entity/exercise.dart';
import '../../entity/sets.dart';
// import 'exercise_selection_page.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
import '../../db_helper.dart';
import 'package:sqflite/sqflite.dart';
import '../../globals.dart' as globals;

/// Страница для создания и редактирования тренировки в зале
class GymTrainingPage extends StatefulWidget {
  final String trainingSessionId; // Добавляем идентификатор тренировки
  final void Function(String)
      onTrainingDeleted; // Коллбэк для удаления тренировки из календаря

  const GymTrainingPage({
    super.key,
    required this.trainingSessionId,
    required this.onTrainingDeleted, // Добавляем параметр в конструктор
  });

  @override
  _GymTrainingPageState createState() => _GymTrainingPageState();
}

class _GymTrainingPageState extends State<GymTrainingPage> {
  /// Метод для добавления нового упражнения
  void _addExercise() async {
    // Открываем страницу выбора упражнения
    // final selectedExercise = await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => ExerciseSelectionPage(
    //       onExerciseSelected: (exerciseName) {
    //         _addExerciseToDB(
    //             widget.trainingSessionId,
    //             globals.availableExercises
    //                 .firstWhere((exercise) => exercise.name == exerciseName)
    //                 .id,
    //             exerciseName);
    //       },
    //     ),
    //   ),
    // );

    // // Если упражнение было выбрано, добавляем его в словарь (на случай использования другого способа возврата)
    // if (selectedExercise != null) {
    //   setState(() {
    //     if (globals.exercisesMap.containsKey(widget.trainingSessionId)) {
    //       // Если упражнение выбрано, добавляем его в словарь с пустым списком сетов
    //       globals.exercisesMap[widget.trainingSessionId]!
    //           .add(Exercise(id: 0, name: selectedExercise, sets: []));
    //     } else {
    //       globals.exercisesMap[widget.trainingSessionId] = [
    //         Exercise(id: 0, name: selectedExercise, sets: [])
    //       ];
    //     }
    //   });
    // }
  }

  /// Метод для открытия диалога добавления нового подхода (сета) к упражнению
  void _addSetDialog(String exerciseName, int indexExercise) {
    showDialog(
      context: context,
      builder: (context) {
        return AddSetDialog(
          exerciseName: exerciseName,
          onSetAdded: (set) {
            _addSetToDB(
                widget.trainingSessionId,
                indexExercise,
                set.weight,
                set.reps,
                globals
                    .exercisesMap[widget.trainingSessionId]![indexExercise].id);
          },
          onSetEdited: (index, set) {
            setState(() {
              // Обновляем существующий сет
              globals.exercisesMap[widget.trainingSessionId]?[indexExercise]
                  .sets[index] = set;
            });
          },
        );
      },
    );
  }

  Future<void> _deleteAppointmentFromDB(String id) async {
    final db = await DBHelper.instance.database;
    int count = await db.delete(
      'appointments',
      where: 'id = ? AND type = ?',
      whereArgs: [id, "Зал"],
    );

    if (count == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Произошла ошибка при удалении тренировки')),
      );
    }
  }

  Future<void> _deleteExerciseFromDB(int index) async {
    final db = await DBHelper.instance.database;
    // Получаем ID упражнения из глобальной переменной
    int exerciseId = globals.exercisesMap[widget.trainingSessionId]![index].id;
    int count = await db.delete(
      'exercises',
      where: 'id = ?',
      whereArgs: [exerciseId],
    );

    if (count == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Произошла ошибка при удалении упражнения')),
      );
    } else {
      setState(() {
        globals.exercisesMap[widget.trainingSessionId]?.removeAt(index);
      });
    }
  }

  Future<void> _deleteSetFromDB(int index, int setIndex) async {
    final db = await DBHelper.instance.database;
    int setId = globals
        .exercisesMap[widget.trainingSessionId]![index].sets[setIndex].id;
    int count = await db.delete(
      'sets',
      where: 'id = ?',
      whereArgs: [setId],
    );

    if (count == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Произошла ошибка при удалении подхода')),
      );
    } else {
      setState(() {
        globals.exercisesMap[widget.trainingSessionId]?[index].sets
            .removeAt(setIndex);
      });
    }
  }

  // Future<void> _addExerciseToDB(
  //     String training, int exercise, String exerciseName) async {
  //   final db = await DBHelper.instance.database;
  //   // Вставляем запись в таблицу exercises.
  //   // Предполагается, что таблица exercises имеет столбцы:
  //   // 'id' (PRIMARY KEY AUTOINCREMENT), 'training' (TEXT) и 'exercise' (TEXT)
  //   int insertedId = await db.insert(
  //     'exercises',
  //     {
  //       'training': training,
  //       'exercise': exerciseName,
  //     },
  //     conflictAlgorithm: ConflictAlgorithm.replace,
  //   );

  //   setState(() {
  //     if (globals.exercisesMap.containsKey(training)) {
  //       globals.exercisesMap[training]!
  //           .add(Exercise(id: insertedId, name: exerciseName, sets: []));
  //     } else {
  //       globals.exercisesMap[training] = [
  //         Exercise(id: insertedId, name: exerciseName, sets: [])
  //       ];
  //     }
  //   });
  // }

  Future<void> _addSetToDB(
      String training, int index, double weight, int reps, int exercise) async {
    final db = await DBHelper.instance.database;
    // Вставляем новую запись в таблицу 'sets'
    int insertedId = await db.insert(
      'sets',
      {
        'exerciseId':
            exercise, // предполагается, что поле называется 'exerciseId'
        'weight': weight,
        'reps': reps,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    setState(() {
      globals.exercisesMap[training]![index].sets.add(
        SetExercise(id: insertedId, weight: weight, reps: reps),
      );
    });
  }

  Future<void> _updateSet(
      int id, double weight, int reps, int indexExercise, int index) async {
    final db = await DBHelper.instance.database;
    int count = await db.update(
      'sets',
      {
        'weight': weight,
        'reps': reps,
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    if (count == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Произошла ошибка при обновлении подхода')),
      );
    } else {
      setState(() {
        globals.exercisesMap[widget.trainingSessionId]![indexExercise]
            .sets[index] = SetExercise(id: id, weight: weight, reps: reps);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Тренировка'),
        actions: [
          // Кнопка для удаления текущей тренировки
          IconButton(
            icon: const Icon(Icons.delete), // Иконка удаления
            onPressed: () {
              // Показываем диалог подтверждения
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title:
                        const Text('Удалить тренировку'), // Заголовок диалога
                    content: const Text(
                        'Вы уверены, что хотите удалить эту тренировку?'), // Основное сообщение диалога
                    actions: [
                      // Кнопка для отмены удаления
                      TextButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pop(); // Закрываем диалог без удаления
                        },
                        child: const Text('Отмена'),
                      ),
                      // Кнопка для подтверждения удаления
                      TextButton(
                        onPressed: () {
                          _deleteAppointmentFromDB(widget.trainingSessionId);
                          setState(() {
                            // Удаляем тренировку
                            globals.exercisesMap
                                .remove(widget.trainingSessionId);
                            // Удаляем тренировку из календаря
                            widget.onTrainingDeleted(widget.trainingSessionId);
                          });
                          Navigator.of(context).pop(); // Закрываем диалог
                          // Возвращаемся на предыдущую страницу с действием 'delete'
                          Navigator.pop(context, {'action': 'delete'});
                        },
                        child: const Text(
                            'Удалить'), // Красный цвет для кнопки удаления
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        // Определение количества элементов в списке
        itemCount: globals.exercisesMap[widget.trainingSessionId]?.length ?? 0,
        itemBuilder: (context, index) {
          // Получение названия упражнения по индексу
          final exerciseName =
              globals.exercisesMap[widget.trainingSessionId]?[index].name ?? "";
          // Получение списка подходов для данного упражнения
          final sets =
              globals.exercisesMap[widget.trainingSessionId]?[index].sets ?? [];

          return Column(
            children: [
              // Отображение названия упражнения и кнопок "Добавить подход" и "Удалить упражнение"
              ListTile(
                title: Text(
                  exerciseName,
                  style: const TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Кнопка для добавления нового подхода
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _addSetDialog(exerciseName, index),
                    ),
                    // Кнопка для удаления упражнения
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _deleteExerciseFromDB(index);
                      },
                    ),
                  ],
                ),
              ),
              // Отступ для списка подходов и изменение их внешнего вида
              Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0), // Отступы для подходов
                child: Column(
                  children: sets.asMap().entries.map((entry) {
                    final set = entry.value;
                    final setIndex = entry.key;
                    return Container(
                      decoration: BoxDecoration(
                        color:
                            Colors.grey[200], // Светло-серый фон для подходов
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      margin: const EdgeInsets.symmetric(
                          vertical: 4.0), // Отступы между подходами
                      child: ListTile(
                        title: Text(
                          'Вес: ${set.weight} кг, Повторения: ${set.reps}', // Отображение веса и количества повторений
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Colors.black87,
                          ),
                        ),
                        // Открытие диалога редактирования подхода при нажатии на элемент
                        onTap: () =>
                            _editSetDialog(exerciseName, setIndex, index),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const Divider(), // Разделительная линия между упражнениями
            ],
          );
        },
      ),
      // Плавающая кнопка для добавления нового упражнения
      floatingActionButton: FloatingActionButton(
        onPressed: _addExercise,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Диалог для редактирования или удаления подхода
  void _editSetDialog(String exerciseName, int setIndex, int index) {
    // Получаем подход, который будем редактировать
    final set =
        globals.exercisesMap[widget.trainingSessionId]?[index].sets[setIndex];
    // Контроллеры для полей ввода веса и количества повторений
    final TextEditingController weightController =
        TextEditingController(text: set?.weight.toString());
    final TextEditingController repetitionsController =
        TextEditingController(text: set?.reps.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Редактировать подход'), // Заголовок диалога
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Поле для ввода веса
              TextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Вес (кг)'),
              ),
              // Поле для ввода количества повторений
              TextField(
                controller: repetitionsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Повторения'),
              ),
            ],
          ),
          actions: [
            // Кнопка для удаления подхода
            TextButton(
              onPressed: () {
                _deleteSetFromDB(index, setIndex);
                Navigator.pop(context); // Закрытие диалога
              },
              child: const Text('Удалить'),
            ),
            // Кнопка для сохранения изменений
            TextButton(
              onPressed: () {
                if (weightController.text.isNotEmpty &&
                    repetitionsController.text.isNotEmpty) {
                  _updateSet(
                      globals.exercisesMap[widget.trainingSessionId]?[index]
                              .sets[setIndex].id ??
                          1,
                      double.parse(weightController.text),
                      int.parse(repetitionsController.text),
                      index,
                      setIndex);
                  //setState(() {});
                  Navigator.pop(context); // Закрытие диалога
                }
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }
}

/// Диалог для добавления или редактирования подхода (сета) к упражнению
class AddSetDialog extends StatelessWidget {
  final String exerciseName; // Название упражнения
  final void Function(SetExercise)
      onSetAdded; // Коллбэк при добавлении нового сета
  final void Function(int, SetExercise)
      onSetEdited; // Коллбэк при редактировании сета

  // Конструктор принимает название упражнения и функции для обработки добавления и редактирования
  const AddSetDialog({
    super.key,
    required this.exerciseName,
    required this.onSetAdded,
    required this.onSetEdited,
  });

  @override
  Widget build(BuildContext context) {
    // Контроллеры для ввода веса и количества повторений
    final TextEditingController weightController = TextEditingController();
    final TextEditingController repetitionsController = TextEditingController();

    return AlertDialog(
      title: Text('Добавить подход к $exerciseName'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Поле для ввода веса
          TextField(
            controller: weightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Вес (кг)'),
          ),
          // Поле для ввода количества повторений
          TextField(
            controller: repetitionsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Повторения'),
          ),
        ],
      ),
      actions: [
        // Кнопка отмены диалога
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        // Кнопка подтверждения добавления сета
        TextButton(
          onPressed: () {
            // Проверяем, что оба поля заполнены
            if (weightController.text.isNotEmpty &&
                repetitionsController.text.isNotEmpty) {
              // Создаем новый сет на основе введенных данных
              final newSet = SetExercise(
                id: 0,
                weight: double.parse(weightController.text),
                reps: int.parse(repetitionsController.text),
              );
              // Передаем новый сет в коллбэк и закрываем диалог
              onSetAdded(newSet);
              Navigator.pop(context);
            }
          },
          child: const Text('Ок'),
        ),
      ],
    );
  }
}
