import 'package:flutter/material.dart';
import 'package:ocr_app/Holders/data_holder.dart';
import 'package:ocr_app/models/user_data.dart';
import 'package:ocr_app/pages/classroom_list_page.dart';
import 'package:ocr_app/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool isLoggedIn = await loadUserFromPreferences();

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

Future<bool> loadUserFromPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? username = prefs.getString('username');
  String? phoneNumber = prefs.getString('phoneNumber');
  int? userId = prefs.getInt('user_id');

  if (username != null && phoneNumber != null && userId != null) {
    DataHolder.currentUser = UserData(userId: userId, username: username, phoneNumber: phoneNumber);
    return true;
  }
  return false;
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ExamEase',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: isLoggedIn ? const ClassroomListPage() : const LoginPage(),
    );
  }
}
