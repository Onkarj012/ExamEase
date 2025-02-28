import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserData {
  int userId;
  String username;
  String phoneNumber;
  String fullName;

  UserData({
    this.userId = -1,
    this.username = '',
    this.phoneNumber = '',
    this.fullName = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'phone_number': phoneNumber,
      'full_name': fullName,
    };
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      userId: json['user_id'],
      username: json['username'],
      phoneNumber: json['phone_number'],
      fullName: json['full_name'],
    );
  }

  Future<void> saveToSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList('user') ?? [];
    users.add(jsonEncode(toJson()));
    await prefs.setStringList('user', users);
  }

  static Future<UserData?> loadUserData(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getStringList('user') ?? [];
    for (var jsonStr in usersJson) {
      final user = UserData.fromJson(jsonDecode(jsonStr));
      if (user.userId == userId) {
        return user;
      }
    }
    return null;
  }

  static Future<void> updateUserData(UserData updatedUser) async {
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList('user') ?? [];
    for (int i = 0; i < users.length; i++) {
      final user = UserData.fromJson(jsonDecode(users[i]));
      if (user.userId == updatedUser.userId) {
        users[i] = jsonEncode(updatedUser.toJson()); // Update the user data
        await prefs.setStringList('user', users);
        return;
      }
    }
  }

  static Future<void> deleteUserData(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList('user') ?? [];
    users.removeWhere((jsonStr) {
      final user = UserData.fromJson(jsonDecode(jsonStr));
      return user.userId == userId;
    });
    await prefs.setStringList('user', users);
  }
}