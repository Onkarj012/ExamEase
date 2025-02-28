import 'dart:async';

import 'package:flutter/material.dart';

import '../Holders/data_holder.dart';
import '../widgets/option_tile.dart';
import '../widgets/question_navigation_widget.dart';

class TestAttemptPage extends StatefulWidget {

  const TestAttemptPage({super.key});

  @override
  State<TestAttemptPage> createState() => _TestAttemptPageState();
}

class _TestAttemptPageState extends State<TestAttemptPage> {
  late List<int?> selectedOptions;
  int previouslySelectedOption = 0;
  int currentQuestionIndex = 0;
  late int remainingTimeInSeconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    selectedOptions = List<int?>.filled(DataHolder.currentTest!.questions.length, null);
    remainingTimeInSeconds = DataHolder.currentTest!.testTime * 60;
    _startTimer();

  }

  void _navigateToQuestion(int index) {
    if (index >= 0 && index < DataHolder.currentTest!.questions.length) {
      setState(() {
        currentQuestionIndex = index;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTimeInSeconds > 0) {
        setState(() {
          remainingTimeInSeconds--;
        });
      } else {
        timer.cancel();
        _showTimeUpDialog();
      }
    });
  }

  void _showTimeUpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Time's Up!"),
          content: const Text("Your test time has ended."),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                // Add any additional action (like submitting the test)
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void handleOptionSelection(int optionNumber) {
    setState(() {
      selectedOptions[currentQuestionIndex] = optionNumber;
    });
  }

  void _onSubmitCallback() {
    _showSubmitConfirmationDialog();
  }

  void _showSubmitConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Submit Test?"),
          content: const Text("Are you sure you want to submit the test?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _computeAndShowResult();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A1D37),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                "Submit",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _computeAndShowResult() {
    final totalQuestions = DataHolder.currentTest!.questions.length;
    int correctAnswers = 0;

    for (int i = 0; i < totalQuestions; i++) {
      final question = DataHolder.currentTest!.questions[i];
      if (question.correctOptionIndex == selectedOptions[i]) {
        correctAnswers++;
      }
    }

    final result = ((correctAnswers / totalQuestions) * 100).round();

    DataHolder.currentTest!.result = result;

    // ResultData().saveResult();
    DataHolder.currentTest!.updateTestData();

    _showResultDialog(result);
  }

  void _showResultDialog(int result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Test Submitted"),
          content: Text("Your score is $result%."),
          actions: [
            ElevatedButton(
              onPressed: () {
                DataHolder.currentTest = null;
                int count = 2;
                Navigator.of(context).popUntil((route) {
                  return count-- <= 0;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A1D37),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                "OK",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = DataHolder.currentTest!.questions[currentQuestionIndex];
    final totalQuestions = DataHolder.currentTest!.questions.length;
    final progressPercentage = (currentQuestionIndex + 1) / totalQuestions;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DataHolder.currentTest!.testName,
                    style: const TextStyle(
                      color: Color(0xFF0A1D37),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Color(0xFF0A1D37)),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(remainingTimeInSeconds), // Display formatted time
                        style: const TextStyle(
                          color: Color(0xFF0A1D37),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(
                    value: progressPercentage,
                    color: const Color(0xFF0A1D37),
                    backgroundColor: Colors.grey[300],
                    minHeight: 8,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Question ${currentQuestionIndex + 1}/$totalQuestions",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "${(progressPercentage * 100).toStringAsFixed(0)}% Complete",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Question and Options Section
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Question Text
                      Text(
                        currentQuestion.questionText,
                        style: const TextStyle(
                          color: Color(0xFF0A1D37),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (currentQuestion.questionImage != null)
                        Image.memory(
                          currentQuestion.questionImage!,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      const SizedBox(height: 16),
                ...currentQuestion.options.map((option) {
                    return OptionTile(
                      option: option,
                      onOptionSelected: handleOptionSelection,
                      isSelected: selectedOptions[currentQuestionIndex] == option.optionNumber,
                      );
                    }),
                    ],
                  ),
                ),
              ),
            ),

            // Navigation Buttons and Submit
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: QuestionNavigationPanel(
                currentQuestionIndex: currentQuestionIndex,
                questions: List.generate(DataHolder.currentTest!.questions.length, (index) => 'Q${index + 1}'),
                onNavigateToQuestion: _navigateToQuestion,
                addNewQuestionEnabled: false,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ElevatedButton(
                onPressed: _onSubmitCallback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A1D37),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  "Submit Test",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
