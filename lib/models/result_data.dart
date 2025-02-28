import 'dart:convert';

import 'package:ocr_app/Holders/data_holder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/random_id_generator.dart';

class ResultData {
  String resultId;
  int userId;
  String testId;
  int result;
  DateTime submittedAt;

  ResultData({
    String? resultId,
    int? userId = -1,
    String? testId = '',
    int? result,
    DateTime? submittedAt,
  })  : resultId = resultId ?? RandomIdGenerator.generateId(),
        submittedAt = submittedAt ?? DateTime.now(),
        testId = testId ?? DataHolder.currentTest!.testId,
        userId = userId ?? DataHolder.currentUser!.userId,
        result = result ?? DataHolder.currentTest!.result;

  Map<String, dynamic> toJson() {
    return {
      'resultId': resultId,
      'userId': userId,
      'testId': testId,
      'result': result,
      'submittedAt': submittedAt.toIso8601String(),
    };
  }

  factory ResultData.fromJson(Map<String, dynamic> json) {
    return ResultData(
      resultId: json['resultId'],
      userId: json['userId'],
      testId: json['testId'],
      result: json['result'],
      submittedAt: DateTime.parse(json['submittedAt']),
    );
  }

  Future<void> saveResult() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> allResults = prefs.getStringList('') ?? [];
    resultId = RandomIdGenerator.generateId();
    while (allResults.contains(resultId)) {
      resultId = RandomIdGenerator.generateId();
    }
    allResults.add(resultId);
    prefs.setStringList('results', allResults);
    prefs.setString(resultId, jsonEncode(toJson()));
  }


  Future<int> getResult() async {
    final prefs = await SharedPreferences.getInstance();
    final resultsJson = prefs.getStringList('results') ?? [];
    for (var jsonStr in resultsJson) {
      final result = ResultData.fromJson(jsonDecode(jsonStr));
      if (result.testId == testId && result.userId == userId) {
        print(result.result);
        return result.result;
      }
    }
    print(-1);
    return -1;
  }

  Future<void> deleteResult() async {
    final prefs = await SharedPreferences.getInstance();
    final results = prefs.getStringList('results') ?? [];
    results.removeWhere((jsonStr) {
      final result = ResultData.fromJson(jsonDecode(jsonStr));
      return result.testId == testId && result.userId == userId;
    });
    await prefs.setStringList('results', results);
  }

  static Future<List<ResultData>> getAllResults() async {
    final prefs = await SharedPreferences.getInstance();
    final resultsJson = prefs.getStringList('results') ?? [];
    return resultsJson.map((jsonStr) => ResultData.fromJson(jsonDecode(jsonStr))).toList();
  }
}