import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/question_data.dart';
import '../models/test_data.dart';

class TestService {
  static const String baseUrl = 'http://192.168.2.9:5001/api';

  Future<TestData> saveTest(TestData test) async {
    final url = Uri.parse('$baseUrl/tests/create');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(test.toJson()),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      return TestData.fromJson(responseData);
    } else {
      throw Exception('Failed to create test: ${response.body}');
    }
  }

  Future<TestData?> loadTest(String testId) async {
    final url = Uri.parse('$baseUrl/tests/$testId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return TestData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load test: ${response.body}');
    }
  }

  Future<void> deleteTest(String testId) async {
    final url = Uri.parse('$baseUrl/tests/delete/$testId');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete test: ${response.body}');
    }
  }

  Future<List<TestData>> loadAllTests() async {
    final url = Uri.parse('$baseUrl/tests/all');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      return responseData.map((data) => TestData.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load tests: ${response.body}');
    }
  }

  Future<List<TestData>> loadTestsByGroupId(String groupId) async {
    final url = Uri.parse('$baseUrl/tests/group/$groupId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      return responseData.map((data) => TestData.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load tests for group: ${response.body}');
    }
  }

  Future<void> updateTest(TestData test) async {
    final url = Uri.parse('$baseUrl/tests/update/${test.testId}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(test.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update test: ${response.body}');
    }
  }

  Future<List<QuestionData>> loadAllQuestions(String testId) async {
    final url = Uri.parse('$baseUrl/tests/$testId/questions');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      return responseData.map((data) => QuestionData.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load questions for test: ${response.body}');
    }
  }
}
