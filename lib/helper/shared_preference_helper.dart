import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPreferenceHelper {
  static const String _key = 'meal_history';
  static const String _tempKeyPrefix = 'temp_meal_'; 

  static Future<void> saveTempMeal(String mealType, List<Map<String, dynamic>> foods) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_tempKeyPrefix$mealType', jsonEncode(foods));
  }

  static Future<List<Map<String, dynamic>>> getTempMeal(String mealType) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('$_tempKeyPrefix$mealType');
    if (data != null) {
      return (jsonDecode(data) as List).map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  }

  static Future<void> saveMeal(String name, int gram, int calorie, String mealType) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_key) ?? [];
    final meal = jsonEncode({
      'name': name,
      'gram': gram,
      'calorie': calorie,
      'mealType': mealType,
      'date': DateTime.now().toString().split(' ')[0],
    });
    history.add(meal);
    await prefs.setStringList(_key, history);
  }

  static Future<List<Map<String, dynamic>>> getMealHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_key) ?? [];
    return history.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }
}