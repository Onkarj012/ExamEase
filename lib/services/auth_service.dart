import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Holders/data_holder.dart';
import '../models/user_data.dart';

class AuthService {
  // static const String baseUrl = 'http://192.168.2.9:5001/api/auth';
  static const String baseUrl = 'https://examease-backend-2.onrender.com/api/auth';

  Future<int> signUp(
      String username, String fullName, String phoneNumber, String password) async {
    final url = Uri.parse('$baseUrl/signup');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'full_name': fullName,
        'phone_number': phoneNumber,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      var responseBody = json.decode(response.body);
      await _saveUserSession(responseBody);
    }

    return response.statusCode;
  }

  Future<int> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      await _saveUserSession(responseBody);
    }

    return response.statusCode;
  }

  Future<void> _saveUserSession(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    final user = userData['user'];

    await prefs.setString('auth_token', userData['token']);
    await prefs.setString('username', user['username']);
    await prefs.setString('full_name', user['fullName']);
    await prefs.setString('phone_number', user['phoneNumber']);
    await prefs.setInt('user_id', user['id']);

    DataHolder.currentUser = UserData(
      userId: user['id'],
      username: user['username'],
      phoneNumber: user['phone_number'],
    );
  }

  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') != null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
