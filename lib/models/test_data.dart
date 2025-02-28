import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/random_id_generator.dart';
import 'question_data.dart';

class TestData {
  String testId;
  String testName;
  List<QuestionData> questions;
  DateTime postedAt;
  DateTime startFrom;
  DateTime deadlineTime;
  int testTime;
  int result;
  int groupId;

  TestData({
    this.testId = '',
    this.testName = '',
    List<QuestionData>? questions,
    DateTime? postedAt,
    DateTime? startFrom,
    DateTime? deadlineTime,
    this.testTime = 0,
    this.result = -1,
    this.groupId = -1,
  })  : questions = questions ?? [...List.generate(1, (index) => QuestionData())],
        postedAt = postedAt ?? DateTime.now(),
        startFrom = startFrom ?? DateTime.now(),
        deadlineTime = deadlineTime ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'testId': testId,
      'testName': testName,
      'questions': questions.map((q) => q.toJson()).toList(),
      'postedAt': postedAt.toIso8601String(),
      'startFrom': startFrom.toIso8601String(),
      'deadlineTime': deadlineTime.toIso8601String(),
      'testTime': testTime,
      'result': result,
      'groupId': groupId,
    };
  }

  factory TestData.fromJson(Map<String, dynamic> json) {
    return TestData(
      testId: json['testId'],
      testName: json['testName'],
      questions: (json['questions'] as List)
          .map((q) => QuestionData.fromJson(q))
          .toList()
        ..sort((a, b) => a.questionNumber.compareTo(b.questionNumber)),
      postedAt: DateTime.parse(json['postedAt']),
      startFrom: DateTime.parse(json['startFrom']),
      deadlineTime: DateTime.parse(json['deadlineTime']),
      testTime: json['testTime'],
      result: json['result'],
      groupId: json['groupId'],
    );
  }

  Future<void> saveTestData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> allTests = prefs.getStringList('tests') ?? [];
    testId = RandomIdGenerator.generateId();
    while (allTests.contains(testId)) {
      testId = RandomIdGenerator.generateId();
    }
    allTests.add(testId);
    prefs.setStringList('tests', allTests);
    prefs.setString(testId, jsonEncode(toJson()));
  }

  static Future<TestData?> loadTestData(String testId) async {
    final prefs = await SharedPreferences.getInstance();
    String? testJson = prefs.getString(testId);
    if (testJson != null) {
      return TestData.fromJson(jsonDecode(testJson));
    }
    return null;
  }

  static Future<void> deleteTestData(String testId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> allTests = prefs.getStringList('tests') ?? [];
    allTests.remove(testId);
    prefs.setStringList('tests', allTests);
    prefs.remove(testId);
  }

  static Future<List<TestData>> getAllTestData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> allTests = prefs.getStringList('tests') ?? [];
    List<TestData> tests = [];

    for (String testId in allTests) {
      String? testJson = prefs.getString(testId);

      if (testJson != null && testJson.isNotEmpty) {
        try {
          tests.add(TestData.fromJson(jsonDecode(testJson)));
        } catch (e) {
          print("Error decoding test data for testId $testId: $e");

        }
      } else {
        print("No data found for testId: $testId or data is empty.");
      }
    }

    tests.sort((a, b) => b.postedAt.compareTo(a.postedAt));

    return tests;
  }

  static Future<List<TestData>> getAllTestDataByGroupId(String groupId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> allTests = prefs.getStringList('tests') ?? [];
    List<TestData> testsByGroup = [];

    for (String testId in allTests) {
      String? testJson = prefs.getString(testId);
      if (testJson != null && testJson.isNotEmpty) {
        TestData test = TestData.fromJson(jsonDecode(testJson));
        if (test.groupId == groupId) {
          testsByGroup.add(test);
        }
      } else {
        print("No data found for testId: $testId");
      }
    }

    testsByGroup.sort((a, b) => b.postedAt.compareTo(a.postedAt));

    return testsByGroup;
  }

  void updateTestData() async {
    await deleteTestData(testId);
    await saveTestData();
  }
}