import 'dart:convert';

import '../../../../core/constants/db_constants.dart';

class TodoDepModel {
  final int? id;
  final int todoId;
  final int dependsOn;
  final DateTime createdAt;

  TodoDepModel({
    this.id,
    required this.todoId,
    required this.dependsOn,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  TodoDepModel copyWith({
    int? id,
    int? todoId,
    int? dependsOn,
    DateTime? createdAt,
  }) {
    return TodoDepModel(
      id: id ?? this.id,
      todoId: todoId ?? this.todoId,
      dependsOn: dependsOn ?? this.dependsOn,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      AppDatabaseConstants.colTodoDepTodoId: todoId,
      AppDatabaseConstants.colTodoDepDependsOn: dependsOn,
      AppDatabaseConstants.colTodoDepCreatedAt: createdAt.millisecondsSinceEpoch,
    };

    if (id != null) map[AppDatabaseConstants.colTodoDepId] = id;

    return map;
  }

  factory TodoDepModel.fromMap(Map<String, dynamic> map) {
    return TodoDepModel(
      id: map[AppDatabaseConstants.colTodoDepId] is int
          ? map[AppDatabaseConstants.colTodoDepId] as int
          : (map[AppDatabaseConstants.colTodoDepId] as num?)?.toInt(),
      todoId: (map[AppDatabaseConstants.colTodoDepTodoId] as int),
      dependsOn: (map[AppDatabaseConstants.colTodoDepDependsOn] as int),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
          map[AppDatabaseConstants.colTodoDepCreatedAt] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory TodoDepModel.fromJson(String source) => TodoDepModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'TodoDepModel(id: $id, todoId: $todoId, dependsOn: $dependsOn, createdAt: $createdAt)';
  }
}
