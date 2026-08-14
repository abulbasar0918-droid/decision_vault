import '../../../../core/constants/db_constants.dart';

class DecisionModel {
  DecisionModel({
    this.id,
    required this.title,
    this.description,
    this.category,
    this.notes,
    this.priority = 0,
    this.pros = const [],
    this.cons = const [],
    this.tags = const [],
    this.weightedScore = 0.0,
    this.isDraft = false,
    this.isFavorite = false,
    this.isArchived = false,
    this.status = 'active',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  final int? id;
  final String title;
  final String? description;
  final String? category;
  final String? notes;
  final int priority;
  final List<String> pros;
  final List<String> cons;
  final List<String> tags;
  final double weightedScore;
  final bool isDraft;
  final bool isFavorite;
  final bool isArchived;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  DecisionModel copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    String? notes,
    int? priority,
    List<String>? pros,
    List<String>? cons,
    List<String>? tags,
    double? weightedScore,
    bool? isDraft,
    bool? isFavorite,
    bool? isArchived,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DecisionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      priority: priority ?? this.priority,
      pros: pros ?? this.pros,
      cons: cons ?? this.cons,
      tags: tags ?? this.tags,
      weightedScore: weightedScore ?? this.weightedScore,
      isDraft: isDraft ?? this.isDraft,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      AppDatabaseConstants.colDecisionTitle: title,
      AppDatabaseConstants.colDecisionDescription: description,
      AppDatabaseConstants.colDecisionCategory: category,
      AppDatabaseConstants.colDecisionNotes: notes,
      AppDatabaseConstants.colDecisionPriority: priority,
      AppDatabaseConstants.colDecisionPros: pros.join('\n'),
      AppDatabaseConstants.colDecisionCons: cons.join('\n'),
      AppDatabaseConstants.colDecisionTags: tags.join(','),
      AppDatabaseConstants.colDecisionWeightedScore: weightedScore,
      AppDatabaseConstants.colDecisionIsDraft: isDraft ? 1 : 0,
      AppDatabaseConstants.colDecisionIsFavorite: isFavorite ? 1 : 0,
      AppDatabaseConstants.colDecisionIsArchived: isArchived ? 1 : 0,
      'status': status,
      AppDatabaseConstants.colDecisionCreatedAt: createdAt.millisecondsSinceEpoch,
      AppDatabaseConstants.colDecisionUpdatedAt: updatedAt.millisecondsSinceEpoch,
    };

    if (id != null) {
      map[AppDatabaseConstants.colDecisionId] = id;
    }

    return map;
  }

  factory DecisionModel.fromMap(Map<String, dynamic> map) {
    return DecisionModel(
      id: _toInt(map[AppDatabaseConstants.colDecisionId] ?? map['id']),
      title: (map[AppDatabaseConstants.colDecisionTitle] ?? map['title']) as String? ?? '',
      description: (map[AppDatabaseConstants.colDecisionDescription] ?? map['description']) as String?,
      category: (map[AppDatabaseConstants.colDecisionCategory] ?? map['category']) as String?,
      notes: (map[AppDatabaseConstants.colDecisionNotes] ?? map['notes']) as String?,
      priority: _toInt(map[AppDatabaseConstants.colDecisionPriority] ?? map['priority']) ?? 0,
      pros: _toList(map[AppDatabaseConstants.colDecisionPros] ?? map['pros']),
      cons: _toList(map[AppDatabaseConstants.colDecisionCons] ?? map['cons']),
      tags: _toList(map[AppDatabaseConstants.colDecisionTags] ?? map['tags']),
      weightedScore: _toDouble(map[AppDatabaseConstants.colDecisionWeightedScore] ?? map['weighted_score']),
      isDraft: _toBool(map[AppDatabaseConstants.colDecisionIsDraft] ?? map['is_draft']),
      isFavorite: _toBool(map[AppDatabaseConstants.colDecisionIsFavorite] ?? map['is_favorite']),
      isArchived: _toBool(map[AppDatabaseConstants.colDecisionIsArchived] ?? map['is_archived']),
      status: (map['status'] as String?) ?? 'active',
      createdAt: _toDateTime(map[AppDatabaseConstants.colDecisionCreatedAt] ?? map['created_at']),
      updatedAt: _toDateTime(map[AppDatabaseConstants.colDecisionUpdatedAt] ?? map['updated_at']),
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;

    final text = value?.toString().toLowerCase();
    return text == 'true' || text == '1';
  }

  static List<String> _toList(dynamic value) {
    if (value == null) return const [];

    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }

    final text = value.toString().trim();
    if (text.isEmpty) return const [];

    if (text.contains(',')) {
      return text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  static DateTime _toDateTime(dynamic value) {
    final milliseconds = _toInt(value);

    if (milliseconds == null) {
      return DateTime.now();
    }

    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }
}
