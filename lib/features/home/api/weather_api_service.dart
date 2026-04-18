import 'dart:convert';

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
          'daily': 'temperature_2m_max,temperature_2m_min',
          'forecast_days': '1',
          'timezone': 'auto',
        });

    final response = await _client.get(
      forecastUri,
      headers: const <String, String>{'Accept': 'application/json'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Unable to load weather right now.',
      );
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      // Keep fallback below.
    }

    throw ApiException(
      statusCode: 500,
      message: 'Received an invalid weather response.',
    );
  }

  Future<Map<String, dynamic>> getKinraraWeather() async {
    return getWeather(latitude: 3.0434, longitude: 101.6914);
  }
}
