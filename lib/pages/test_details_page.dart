import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Holders/data_holder.dart';
import '../models/test_data.dart';

class TestDetailsPage extends StatefulWidget {

  const TestDetailsPage({super.key});

  @override
  State<TestDetailsPage> createState() =>
      _TestDetailsPageState();
}

class _TestDetailsPageState extends State<TestDetailsPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _testNameController;
  late TextEditingController _startTimeController;
  late TextEditingController _deadlineController;
  late TextEditingController _testDurationController;

  DateTime? _startDateTime;
  DateTime? _deadlineDateTime;
  bool isEditTest = false;

  @override
  void initState() {
    isEditTest = DataHolder.currentTest!.testId != '';

    super.initState();
    _testNameController = TextEditingController(
        text: DataHolder.currentTest!.testName
    );
    _startTimeController = TextEditingController(
        text: DateFormat('yyyy-MM-dd HH:mm').format(DataHolder.currentTest!.startFrom)
    );
    _deadlineController = TextEditingController(
        text: DateFormat('yyyy-MM-dd HH:mm').format(DataHolder.currentTest!.deadlineTime)
    );
    _testDurationController = TextEditingController(
        text: DataHolder.currentTest!.testTime > 0
            ? DataHolder.currentTest!.testTime.toString()
            : ''
    );
  }

  @override
  void dispose() {
    _testNameController.dispose();
    _startTimeController.dispose();
    _deadlineController.dispose();
    _testDurationController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime(
      BuildContext context, TextEditingController controller, bool isStart) async {
    DateTime initialDate =
    isStart ? (_startDateTime ?? DateTime.now()) : (_deadlineDateTime ?? DateTime.now());
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (pickedTime == null) return;

    DateTime fullDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      if (isStart) {
        _startDateTime = fullDateTime;
        DataHolder.currentTest!.startFrom = fullDateTime;
      } else {
        _deadlineDateTime = fullDateTime;
        DataHolder.currentTest!.deadlineTime = fullDateTime;
      }
      controller.text = DateFormat('yyyy-MM-dd HH:mm').format(fullDateTime);
    });
  }

  void _onSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      DataHolder.currentTest!.testName = _testNameController.text;
      DataHolder.currentTest!.testTime = int.tryParse(_testDurationController.text) ?? 0;

      try {
        if (!isEditTest) {
          DataHolder.currentTest!.classroomId = DataHolder.currentClassroom!.classroomId!;
          DataHolder.currentTest!.saveTestData();
        } else {
          DataHolder.currentTest!.updateTestData();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Test saved successfully!')),
        );

        DataHolder.currentTest = null;

        int count = 2;
        Navigator.of(context).popUntil((route) {
          return count-- <= 0;
        });

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save test: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Options'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _onSave,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _testNameController,
                decoration: const InputDecoration(
                  labelText: 'Test Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a test name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _startTimeController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Start Time',
                  border: OutlineInputBorder(),
                ),
                onTap: () => _pickDateTime(context, _startTimeController, true),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _deadlineController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Deadline',
                  border: OutlineInputBorder(),
                ),
                onTap: () => _pickDateTime(context, _deadlineController, false),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _testDurationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Test Duration (minutes)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the test duration';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
