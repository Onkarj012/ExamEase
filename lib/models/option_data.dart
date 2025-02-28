import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';

class OptionData {
  int? optionId; // Changed to `int` for sequential IDs
  String optionText;
  Uint8List? image;
  int optionNumber;

  OptionData({
    this.optionId,
    this.optionText = '',
    this.image,
    this.optionNumber = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'optionId': optionId,
      'optionText': optionText,
      'image': image != null ? base64Encode(image!) : null,
      'optionNumber': optionNumber,
    };
  }

  factory OptionData.fromJson(Map<String, dynamic> json) {
    return OptionData(
      optionId: json['optionId'],
      optionText: json['optionText'],
      image: json['image'] != null ? base64Decode(json['image']) : null,
      optionNumber: json['optionNumber'],
    );
  }

  Future<void> saveToLocalDatabase() async {
    final prefs = await SharedPreferences.getInstance();

    // Get all saved option IDs
    List<String> allOptionIds = prefs.getStringList('optionIds') ?? [];

    // Generate sequential ID
    if (optionId == null) {
      if (allOptionIds.isEmpty) {
        optionId = 1; // Start from 1 if the list is empty
      } else {
        int lastOptionId = int.parse(allOptionIds.last);
        optionId = lastOptionId + 1; // Increment the last ID
      }
    }

    // Save the new ID to the list
    allOptionIds.add(optionId.toString());
    prefs.setStringList('optionIds', allOptionIds);

    // Save the option data
    prefs.setString(optionId.toString(), jsonEncode(toJson()));
  }

  static Future<OptionData?> loadFromLocalDatabase(int optionId) async {
    final prefs = await SharedPreferences.getInstance();
    String? optionJson = prefs.getString(optionId.toString());
    if (optionJson != null) {
      return OptionData.fromJson(jsonDecode(optionJson));
    }
    return null;
  }

  static Future<void> deleteFromLocalDatabase(int optionId) async {
    final prefs = await SharedPreferences.getInstance();

    // Remove the option from the stored list
    List<String> allOptionIds = prefs.getStringList('optionIds') ?? [];
    allOptionIds.remove(optionId.toString());
    prefs.setStringList('optionIds', allOptionIds);

    // Remove the option data
    prefs.remove(optionId.toString());
  }
}