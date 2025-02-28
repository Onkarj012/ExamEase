class ClassroomData {
  int classroomId;
  String joinCode;
  String classroomName;
  String creatorName;
  int createdBy;
  DateTime? createdAt;

  ClassroomData({
    this.classroomId = -1,
    this.classroomName = '',
    this.creatorName = '',
    this.createdBy = -1,
    this.joinCode = '',
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'classroom_id': classroomId,
      'classroom_name': classroomName,
      'created_by': createdBy,
      'join_code': joinCode,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory ClassroomData.fromJson(Map<String, dynamic> json) {
    return ClassroomData(
      classroomId: json['id'] ?? -1,
      classroomName: json['classroom_name'] ?? '',
      createdBy: json['created_by'] ?? -1,
      creatorName: json['creator_name'] ?? '',
      joinCode: json['join_code'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }
}

class UserClassroomData {
  final int userId;
  final int classroomId;
  final String role;

  UserClassroomData({
    required this.userId,
    required this.classroomId,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'classroom_id': classroomId,
      'role': role,
    };
  }

  factory UserClassroomData.fromJson(Map<String, dynamic> json) {
    return UserClassroomData(
      userId: json['user_id'],
      classroomId: json['classroom_id'],
      role: json['role'],
    );
  }
}
