import '../../../../core/constants/db_constants.dart';

class JournalModel {
  JournalModel({
    this.id,
    required this.title,
    this.body,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  final int? id;
  final String title;
  final String? body;
  final DateTime createdAt;
  final DateTime updatedAt;

  JournalModel copyWith({
    int? id,
    String? title,
    String? body,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JournalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      AppDatabaseConstants.colJournalTitle: title,
      AppDatabaseConstants.colJournalBody: body,
      AppDatabaseConstants.colJournalCreatedAt: createdAt.millisecondsSinceEpoch,
      AppDatabaseConstants.colJournalUpdatedAt: updatedAt.millisecondsSinceEpoch,
    };

    if (id != null) map[AppDatabaseConstants.colJournalId] = id;
    return map;
  }

  factory JournalModel.fromMap(Map<String, dynamic> map) {
    return JournalModel(
      id: map[AppDatabaseConstants.colJournalId] is int
          ? map[AppDatabaseConstants.colJournalId] as int
          : (map[AppDatabaseConstants.colJournalId] as num?)?.toInt(),
      title: map[AppDatabaseConstants.colJournalTitle] as String,
      body: map[AppDatabaseConstants.colJournalBody] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map[AppDatabaseConstants.colJournalCreatedAt] as int,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        map[AppDatabaseConstants.colJournalUpdatedAt] as int,
      ),
    );
  }
}
