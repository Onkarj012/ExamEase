import 'package:ocr_app/models/classroom_data.dart';
import 'package:ocr_app/models/test_data.dart';
import 'package:ocr_app/models/user_data.dart';

class DataHolder {
  static ClassroomData? currentClassroom;
  static UserData? currentUser;
  static TestData? currentTest;

  static void clear() {
    currentClassroom = null;
    currentUser = null;
    currentTest = null;
  }
}
