import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../foundation/network/api_exception.dart';

class WeatherApiService {
  WeatherApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> getWeather({
    required double latitude,
    required double longitude,
  }) async {
    final forecastUri =
        Uri.https('api.open-meteo.com', '/v1/forecast', <String, String>{
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'current': 'temperature_2m,weather_code,wind_speed_10m',
          'hourly': 'temperature_2m,weather_code,precipitation_probability',
          'daily': 'weather_code,temperature_2m_max,temperature_2m_min',
          'forecast_days': '7',
          'timezone': 'auto',
        });

    debugPrint('[API] GET $forecastUri');
    final response = await _client
        .get(
          forecastUri,
          headers: const <String, String>{'Accept': 'application/json'},
        )
        .timeout(const Duration(seconds: 12));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      debugPrint('[API] FAILED ${response.statusCode} GET $forecastUri');
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Unable to load weather right now.',
      );
    }

    debugPrint('[API] OK ${response.statusCode} GET $forecastUri');

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (error) {
      debugPrint('[WeatherApi] decode error: $error');
    }

    throw ApiException(
      statusCode: 500,
      message: 'Received an invalid weather response.',
    );
  }

  Future<Map<String, dynamic>> getKinraraWeather() async {
    return getWeather(latitude: 3.04703, longitude: 101.64744);
  }
}
