import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:cheguei/models/weather_model.dart';

class WeatherService {
  static Future<WeatherModel?> getCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final url =
          'https://api.open-meteo.com/v1/forecast'
          '?latitude=$latitude'
          '&longitude=$longitude'
          '&current=temperature_2m,weather_code';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(response.body);

      final current = data['current'];

      final double temperature =
          (current['temperature_2m'] as num).toDouble();

      final int weatherCode = current['weather_code'];

      final bool isRaining =
          weatherCode >= 51 && weatherCode <= 67;

      return WeatherModel(
        temperature: temperature,
        weatherCode: weatherCode,
        isRaining: isRaining,
      );
    } catch (e) {
      return null;
    }
  }
}