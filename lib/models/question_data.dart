import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';

import 'option_data.dart';

class QuestionData {
  int? questionId; // Changed to `int` for sequential IDs
  String questionText;
  Uint8List? questionImage;
  List<OptionData> options;
  int questionNumber;
  int correctOptionIndex;

  QuestionData({
    this.questionId,
    this.questionText = '',
    this.questionImage,
    List<OptionData>? options,
    this.questionNumber = 0,
    this.correctOptionIndex = 0,
  }) : options = options ?? List.generate(4, (index) => OptionData(optionNumber: index));

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'questionText': questionText,
      'questionImage': questionImage != null ? base64Encode(questionImage!) : null,
      'options': options.map((o) => o.toJson()).toList(),
      'questionNumber': questionNumber,
      'correctOptionIndex': correctOptionIndex,
    };
  }

  factory QuestionData.fromJson(Map<String, dynamic> json) {
    return QuestionData(
      questionId: json['questionId'],
      questionText: json['questionText'],
      questionImage: json['questionImage'] != null ? base64Decode(json['questionImage']) : null,
      options: (json['options'] as List)
          .map((o) => OptionData.fromJson(o))
          .toList()
        ..sort((a, b) => a.optionNumber.compareTo(b.optionNumber)),
      questionNumber: json['questionNumber'],
      correctOptionIndex: json['correctOptionIndex'],
    );
  }

  Future<void> saveToLocalDatabase() async {
    final prefs = await SharedPreferences.getInstance();

    // Get all saved question IDs
    List<String> allQuestionIds = prefs.getStringList('questionIds') ?? [];

    // Generate sequential ID
    if (questionId == null) {
      if (allQuestionIds.isEmpty) {
        questionId = 1; // Start from 1 if the list is empty
      } else {
        int lastQuestionId = int.parse(allQuestionIds.last);
        questionId = lastQuestionId + 1; // Increment the last ID
      }
    }

    // Save the new ID to the list
    allQuestionIds.add(questionId.toString());
    prefs.setStringList('questionIds', allQuestionIds);

    // Save the question data
    prefs.setString(questionId.toString(), jsonEncode(toJson()));
  }

  static Future<QuestionData?> loadFromLocalDatabase(int questionId) async {
    final prefs = await SharedPreferences.getInstance();
    String? questionJson = prefs.getString(questionId.toString());
    if (questionJson != null) {
      return QuestionData.fromJson(jsonDecode(questionJson));
    }
    return null;
  }

  static Future<void> deleteFromLocalDatabase(int questionId) async {
    final prefs = await SharedPreferences.getInstance();

    // Remove the question from the stored list
    List<String> allQuestionIds = prefs.getStringList('questionIds') ?? [];
    allQuestionIds.remove(questionId.toString());
    prefs.setStringList('questionIds', allQuestionIds);

    // Remove the question data
    prefs.remove(questionId.toString());
  }
}