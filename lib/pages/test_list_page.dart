import 'package:flutter/material.dart';
import 'package:ocr_app/Holders/data_holder.dart';
import 'package:ocr_app/models/test_data.dart';
import 'package:ocr_app/pages/question_builder_page.dart';

import '../widgets/test_card_widget.dart';

class TestListPage extends StatefulWidget {

  const TestListPage({super.key});

  @override
  State<TestListPage> createState() => _TestListPageState();
}

class _TestListPageState extends State<TestListPage> {
  List<TestData> tests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTestData();
  }

  @override
  void dispose() {
    DataHolder.currentClassroom = null;
    super.dispose();
  }

  Future<void> _loadTestData() async {
    try {
      List<TestData> loadedTests = await TestData.getAllTestData();

      setState(() {
        tests = loadedTests;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load test data: $e')),
      );
      print('Failed to load test data: $e');
    }
  }

  Future<void> _deleteTest(int index) async {
    final testId = tests[index].testId;
    try {
      await TestData.deleteTestData(testId);
      setState(() {
        tests.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete test: $e')),
      );
    }
  }

  Future<void> _editTest(int index) async {
    DataHolder.currentTest = tests[index];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionBuilderPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DataHolder.currentClassroom!.classroomName),
      ),
      body: Container(
        color: Colors.white,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : tests.isEmpty
            ? const Center(
          child: Text(
            "No test Posted Yet",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ) :
        ListView.builder(
          itemCount: tests.length,
          itemBuilder: (context, index) {
            final test = tests[index];
            return TestCardWidget(
              test: test,
              index: index,
              deleteTest: _deleteTest,
              editTest: _editTest,
            );
          },
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          DataHolder.currentTest = TestData();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const QuestionBuilderPage(),
            ),
          );
        },
        backgroundColor: const Color(0xFF0A1D37), // Matching button color
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}