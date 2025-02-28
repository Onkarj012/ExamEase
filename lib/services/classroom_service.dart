import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/classroom_data.dart';
import '../Holders/data_holder.dart';

class ClassroomService {
  // static const String baseUrl = 'http://192.168.2.9:5001/api'; // For Android Emulator
  // static const String baseUrl = 'http://localhost:5001/api'; // For other platforms

  static const String baseUrl = 'https://examease-backend-2.onrender.com/api';

  Future<ClassroomData> saveClassroom(ClassroomData classroom) async {
    final url = Uri.parse('$baseUrl/classrooms/create');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'classroom_name': classroom.classroomName,
        'created_by': DataHolder.currentUser?.userId ?? 0,
      }),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      return ClassroomData.fromJson(responseData);
    } else {
      throw Exception('Failed to create classroom: ${response.body}');
    }
  }

  Future<ClassroomData?> loadClassroomData(int classroomId) async {
    final url = Uri.parse('$baseUrl/classrooms/$classroomId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return ClassroomData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load classroom: ${response.body}');
    }
  }

  Future<ClassroomData?> joinClassroom(String classroomCode, String role) async {
    final url = Uri.parse('$baseUrl/classrooms/join');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': DataHolder.currentUser?.userId ?? 0,
        'join_code': classroomCode,
        'role': role,
      }),
    );

    if (response.statusCode == 200) {
      return ClassroomData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load classroom: ${response.body}');
    }
  }

  Future<List<ClassroomData>> loadAllClassroomsForUser() async {
    final userId = DataHolder.currentUser?.userId ?? 0;
    final url = Uri.parse('$baseUrl/classrooms/user/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      return responseData.map((data) => ClassroomData.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load classrooms: ${response.body}');
    }
  }

  Future<void> leaveClassroom(int classroomId) async {
    final url = Uri.parse('$baseUrl/classrooms/leave');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': DataHolder.currentUser?.userId ?? 0,
        'classroom_id': classroomId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to leave classroom: ${response.body}');
    }
  }

  Future<void> removeStudent(String userId, int classroomId) async {
    final url = Uri.parse('$baseUrl/classrooms/remove-student');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'classroom_id': classroomId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove student: ${response.body}');
    }
  }
}
