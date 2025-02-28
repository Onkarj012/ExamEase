import 'package:flutter/material.dart';
import 'package:ocr_app/models/test_data.dart';
import 'package:ocr_app/services/date_time_formatter_service.dart';
import 'package:ocr_app/widgets/test_action_button.dart';

class TestCardWidget extends StatelessWidget {
  final TestData test;
  final int index;
  final Function(int) deleteTest, editTest;

  const TestCardWidget({
    required this.test,
    required this.index,
    required this.deleteTest,
    required this.editTest,
    super.key,
  });

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
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF0A1D37), const Color(0xFF0A1D37).withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              test.testName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Start: ${DateTimeFormatterService.formatDate(test.startFrom)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.date_range,
                                  size: 16,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Deadline: ${DateTimeFormatterService.formatDate(test.deadlineTime)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.timer,
                                  size: 16,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Duration: ${test.testTime} mins',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TestActionButtons(test: test),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      PopupMenuButton<int>(
                        onSelected: (value) {
                          if (value == 1) {
                            deleteTest(index);
                          } else {
                            editTest(index);
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          const PopupMenuItem<int>(value: 1, child: Text('Delete Test')),
                          const PopupMenuItem<int>(value: 2, child: Text('Edit Test')),
                        ],
                        icon: const Icon(
                          Icons.more_vert,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 8,
              right: 16,
              child: Text(
                'Posted At: ${DateTimeFormatterService.formatDate(test.postedAt)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
