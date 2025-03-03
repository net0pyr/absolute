import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:uuid/uuid.dart';

class CustomAppointment extends Appointment {
  final String
      _trainingSessionId; // Приватное поле для хранения идентификатора тренировки

  // Геттер для получения значения идентификатора тренировки
  String get trainingSessionId => _trainingSessionId;

  CustomAppointment({
    required super.startTime,
    required super.endTime,
    required super.subject,
    required super.color,
    super.notes,
  }) : _trainingSessionId = const Uuid().v4();

  CustomAppointment.withId({
    required super.startTime,
    required super.endTime,
    required super.subject,
    required super.color,
    required String trainingSessionId,
    super.notes,
  }) : _trainingSessionId = trainingSessionId;

  // Метод для определения цвета на основе subject
  static Color _getColorForSubject(String subject) {
    switch (subject) {
      case 'Зал':
        return const Color.fromARGB(255, 68, 6, 6);
      case 'Бег':
        return const Color.fromARGB(255, 255, 0, 0);
      default:
        return Colors.grey; // Цвет по умолчанию
    }
  }

  // Метод для определения цвета на основе subject
  static String _getNotesForSubject(
      String subject, String distance, String time) {
    switch (subject) {
      case 'Зал':
        return "";
      case 'Бег':
        return "$distance км; $time минут";
      default:
        return ""; // Цвет по умолчанию
    }
  }

  factory CustomAppointment.fromJson(Map<String, dynamic> json) =>
      CustomAppointment.withId(
        startTime: DateTime.parse(
            (json['startTime']?.toString() ?? DateTime.now().toIso8601String())),
        endTime: DateTime.parse(
            (json['startTime']?.toString() ?? DateTime.now().toIso8601String())),
        subject: json['type']?.toString() ?? '',
        color: _getColorForSubject(json['type']?.toString() ?? ''),
        trainingSessionId: json['id']?.toString() ?? '',
        notes: _getNotesForSubject(
          json['type']?.toString() ?? '',
          json['distance']?.toString() ?? '',
          json['time']?.toString() ?? '',
        ),
      );
}
