import 'sets.dart';

class AvailableExercise {
  final String name;
  final int id;

  AvailableExercise({required this.name, required this.id});

  factory AvailableExercise.fromJson(Map<String, dynamic> json) {
    return AvailableExercise(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }
}

class Exercise {
  final String name;
  final int id;
  final List<SetExercise> sets;

  Exercise({required this.id, required this.name, required this.sets});
}
