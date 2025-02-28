import 'package:flutter/material.dart';
import 'package:ocr_app/models/classroom_data.dart';
import 'package:ocr_app/services/date_time_formatter_service.dart';
import 'package:ocr_app/pages/test_list_page.dart';
import 'package:ocr_app/Holders/data_holder.dart';

class ClassroomCard extends StatelessWidget {
  final ClassroomData classroom;
  final Future<void> Function() onLeaveClassroom;

  const ClassroomCard({super.key, required this.classroom, required this.onLeaveClassroom});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          DataHolder.currentClassroom = classroom;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TestListPage(),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF0A1D37), const Color(0xFF0A1D37).withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    classroom.classroomName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Code: ${classroom.joinCode}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Created on: ${DateTimeFormatterService.formatDate(classroom.createdAt!)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Created by: ${classroom.creatorName}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: PopupMenuButton<int>(
                  onSelected: (value) {
                    if (value == 2) {
                      onLeaveClassroom;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 2, child: Text('Leave')),
                  ],
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
