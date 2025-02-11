import './dish.dart';
import '../globals.dart';

class Eating {
  int id;
  final Dish dish;
  int weight;
  final DateTime date;

  Eating({
    required this.id,
    required this.dish,
    required this.weight,
    required this.date,
  });

  static Dish _getDishById(int id) {
    return availableDishes.firstWhere(
      (dish) => dish.id == id,
      orElse: () => Dish(
        id: id,
        name: 'Неизвестно',
        proteins: 0,
        fats: 0,
        carbs: 0,
      ),
    );
  }

  factory Eating.fromJson(Map<String, dynamic> json) {
    return Eating(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      // Use 'dishId' since the database table column is named 'dishId'
      dish: _getDishById(json['dishId'] is int
          ? json['dishId']
          : int.parse(json['dishId'].toString())),
      weight: json['weight'] is int
          ? json['weight']
          : int.parse(json['weight'].toString()),
      date: DateTime.parse(json['date'] as String),
    );
  }
}
