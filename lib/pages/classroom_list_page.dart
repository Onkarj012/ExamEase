import 'package:flutter/material.dart';
import 'package:ocr_app/services/classroom_service.dart';
import 'package:ocr_app/widgets/classroom_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/classroom_data.dart';
import 'login_page.dart';

class ClassroomListPage extends StatefulWidget {

  const ClassroomListPage({super.key});

  @override
  State<ClassroomListPage> createState() => _ClassroomListPageState();
}

class _ClassroomListPageState extends State<ClassroomListPage> {
  List<ClassroomData> classrooms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClassrooms();
  }

  Future<void> _loadClassrooms() async {
    try {
      final loadedClassrooms = await ClassroomService().loadAllClassroomsForUser();
      setState(() {
        classrooms = loadedClassrooms;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load classrooms: $e')),
      );
      print('Failed to load classrooms: $e');
    }
  }

  Future<void> _leaveClassroom(int index) async {
    final classroomId = classrooms[index].classroomId;
    await ClassroomService().leaveClassroom(classroomId);
    setState(() {
      classrooms.removeAt(index);
    });
  }

  Future<void> _addClassroomDialog() async {
    final TextEditingController classroomNameController = TextEditingController();
    bool isSubmitting = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Classroom'),
              content: TextField(
                controller: classroomNameController,
                decoration: InputDecoration(
                  labelText: 'Classroom Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                    if (classroomNameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Classroom name cannot be empty')),
                      );
                      return;
                    }
                    setState(() {
                      isSubmitting = true;
                    });
                    try {
                      ClassroomData newClassroom = await ClassroomService()
                          .saveClassroom(ClassroomData(
                        classroomName: classroomNameController.text.trim(),
                        createdAt: DateTime.now(),
                      ));

                      setState(() {
                        classrooms.add(newClassroom);
                        isSubmitting = false;
                      });

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Classroom added successfully')),
                      );
                    } catch (e) {
                      setState(() {
                        isSubmitting = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to add classroom: $e')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A1D37),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Text(
                    'Add',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }


  Future<void> _joinClassroomDialog() async {
    final TextEditingController classroomIdController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Join Classroom'),
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
                final classroomCode = classroomIdController.text.trim();
                if (classroomCode.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Classroom code cannot be empty')),
                  );
                  return;
                }
                try {
                  ClassroomData? newClassroom = await ClassroomService().joinClassroom(classroomCode, 'student');
                  setState(() {
                    classrooms.add(newClassroom!);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Joined classroom successfully')),
                  );
                  Navigator.pop(context);
                                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to join classroom: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A1D37),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Join',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('phoneNumber');
    await prefs.remove('user_id');

    // Navigate to LoginPage and remove previous routes
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Classroom List',
          style: TextStyle(
            color: Color(0xFF0A1D37),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF0A1D37)),
            onPressed: _logout,
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
            onRefresh: _loadClassrooms,
            child:
            classrooms.isEmpty
                ? const Center(
              child: Text(
                'No classrooms available.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: Colors.black54,
                ),
              ),
            )
                : ListView.builder(
              itemCount: classrooms.length,
              itemBuilder: (context, index) {
                final classroom = classrooms[index];
                return ClassroomCard(classroom: classroom, onLeaveClassroom: () => _leaveClassroom(index));
              },
            ))
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: _addClassroomDialog,
            tooltip: 'Add Classroom',
            backgroundColor: const Color(0xFF0A1D37),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _joinClassroomDialog,
            tooltip: 'Join Classroom',
            backgroundColor: const Color(0xFF0A1D37),
            child: const Icon(Icons.group_add, color: Colors.white),
          ),
        ],
      ),
    );
  }
}