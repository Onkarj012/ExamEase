import 'package:flutter/material.dart';
import 'package:ocr_app/models/classroom_data.dart';

class ClassroomDialog extends StatelessWidget {
  final TextEditingController classroomIdController;
  final String dialogType;
  final Function onSubmit;

  const ClassroomDialog({
    super.key,
    required this.classroomIdController,
    required this.dialogType,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(dialogType == 'add' ? 'Add New Classroom' : 'Join Classroom'),
      content: TextField(
        controller: classroomIdController,
        decoration: const InputDecoration(
          labelText: 'Enter Classroom Code',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            onSubmit();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0A1D37),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Text(
            'Submit',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
