import 'dart:convert';

import '../../../../core/constants/db_constants.dart';

class TodoModel {
  final int? id;
  final String title;
  final String? description;
  final bool isDone;
  final DateTime createdAt;
  final DateTime updatedAt;

  TodoModel({
    this.id,
    required this.title,
    this.description,
    required this.isDone,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  TodoModel copyWith({
    int? id,
    String? title,
    String? description,
    bool? isDone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      AppDatabaseConstants.colTodoTitle: title,
      AppDatabaseConstants.colTodoDescription: description,
      AppDatabaseConstants.colTodoIsDone: isDone ? 1 : 0,
      AppDatabaseConstants.colTodoCreatedAt: createdAt.millisecondsSinceEpoch,
      AppDatabaseConstants.colTodoUpdatedAt: updatedAt.millisecondsSinceEpoch,
    };

    if (id != null) map[AppDatabaseConstants.colTodoId] = id;

    return map;
  }

  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      id: map[AppDatabaseConstants.colTodoId] is int
          ? map[AppDatabaseConstants.colTodoId] as int
          : (map[AppDatabaseConstants.colTodoId] as num?)?.toInt(),
      title: map[AppDatabaseConstants.colTodoTitle] as String,
      description: map[AppDatabaseConstants.colTodoDescription] as String?,
      isDone: (map[AppDatabaseConstants.colTodoIsDone] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
          map[AppDatabaseConstants.colTodoCreatedAt] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
          map[AppDatabaseConstants.colTodoUpdatedAt] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory TodoModel.fromJson(String source) => TodoModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'TodoModel(id: $id, title: $title, description: $description, isDone: $isDone, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
