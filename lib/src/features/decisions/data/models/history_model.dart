import '../../../../core/constants/db_constants.dart';

class HistoryModel {
  HistoryModel({
    this.id,
    this.decisionId,
    required this.event,
    this.payload,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final int? id;
  final int? decisionId;
  final String event;
  final String? payload;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      AppDatabaseConstants.colHistoryDecisionId: decisionId,
      AppDatabaseConstants.colHistoryEvent: event,
      AppDatabaseConstants.colHistoryPayload: payload,
      AppDatabaseConstants.colHistoryCreatedAt: createdAt.millisecondsSinceEpoch,
    };
    if (id != null) map[AppDatabaseConstants.colHistoryId] = id;
    return map;
  }

  factory HistoryModel.fromMap(Map<String, dynamic> map) {
    return HistoryModel(
      id: map[AppDatabaseConstants.colHistoryId] is int
          ? map[AppDatabaseConstants.colHistoryId] as int
          : (map[AppDatabaseConstants.colHistoryId] as num?)?.toInt(),
      decisionId: map[AppDatabaseConstants.colHistoryDecisionId] is int
          ? map[AppDatabaseConstants.colHistoryDecisionId] as int
          : (map[AppDatabaseConstants.colHistoryDecisionId] as num?)?.toInt(),
      event: map[AppDatabaseConstants.colHistoryEvent] as String,
      payload: map[AppDatabaseConstants.colHistoryPayload] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map[AppDatabaseConstants.colHistoryCreatedAt] as int,
      ),
    );
  }
}
