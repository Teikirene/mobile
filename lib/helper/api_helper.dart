import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiHelper {
  static const String _baseUrl = 'https://67e26dbc97fc65f535360587.mockapi.io/calo/calo';

  static Future<List<Map<String, dynamic>>> fetchMultipleCalories(List<Map<String, dynamic>> foods) async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return foods.map((food) {
        final match = data.firstWhere(
          (item) => item['name'].toLowerCase() == food['food'].toLowerCase(),
          orElse: () => null,
        );

        if (match != null) {
          return {
            'name': match['name'],'gram': food['gram'],'calorie': (match['calo'] * food['gram']).round(),
          };
        } else {
          return {'name': food['food'], 'gram': food['gram'], 'calorie': 0};
        }
      }).toList();
    } else {
      throw Exception('Failed to fetch calories from Mock API');
    }
  }
}