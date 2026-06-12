class CoachSessionModel {
  final String id;
  final String title;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;

  CoachSessionModel({
    required this.id,
    required this.title,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CoachSessionModel.fromJson(Map<String, dynamic> json) {
    final rawCreatedAt = json['createdAt'] ?? json['created_at'];
    final rawUpdatedAt = json['updatedAt'] ?? json['updated_at'];

    return CoachSessionModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'New Chat Session',
      category: json['category'] as String? ?? 'General',
      createdAt: rawCreatedAt != null 
          ? DateTime.parse(rawCreatedAt as String) 
          : DateTime.now(),
      updatedAt: rawUpdatedAt != null 
          ? DateTime.parse(rawUpdatedAt as String) 
          : DateTime.now(),
    );
  }
}

class CoachMessageModel {
  final String id;
  final String sessionId;
  final String role;
  final String content;
  final DateTime createdAt;

  CoachMessageModel({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  bool get isUser => role == 'user';

  factory CoachMessageModel.fromJson(Map<String, dynamic> json) {
    final rawSessionId = json['sessionId'] ?? json['session_id'];
    final rawCreatedAt = json['createdAt'] ?? json['created_at'];

    return CoachMessageModel(
      id: json['id'] as String? ?? '',
      sessionId: rawSessionId as String? ?? '',
      role: json['role'] as String? ?? 'user',
      content: json['content'] as String? ?? '',
      createdAt: rawCreatedAt != null 
          ? DateTime.parse(rawCreatedAt as String) 
          : DateTime.now(),
    );
  }
}
