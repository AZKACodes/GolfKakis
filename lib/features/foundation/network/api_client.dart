import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final http.Client _client;
  final String _baseUrl;

  static const Map<String, String> _defaultHeaders = <String, String>{
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  Future<dynamic> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final response = await _client.get(uri, headers: _mergeHeaders(headers));
    return _decodeJsonResponse(response);
  }

  Future<dynamic> postJson(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final response = await _client.post(
      uri,
      headers: _mergeHeaders(headers),
      body: jsonEncode(body),
    );
    return _decodeJsonResponse(response);
  }

  Uri _buildUri(String path, Map<String, dynamic>? queryParameters) {
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    final resolved = Uri.parse(_baseUrl).resolve(normalizedPath);

    if (queryParameters == null || queryParameters.isEmpty) {
      return resolved;
    }

    return resolved.replace(
      queryParameters: queryParameters.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }

  Map<String, String> _mergeHeaders(Map<String, String>? headers) {
    return <String, String>{
      ..._defaultHeaders,
      if (headers != null) ...headers,
    };
  }

  dynamic _decodeJsonResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        statusCode: response.statusCode,
        message: _extractErrorMessage(response.body),
      );
    }

    if (response.body.isEmpty) {
      return <String, dynamic>{};
    }

    try {
      return jsonDecode(response.body);
    } catch (_) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Expected JSON response but received invalid payload.',
      );
    }
  }

  String _extractErrorMessage(String responseBody) {
    if (responseBody.isEmpty) {
      return 'Request failed.';
    }

    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'] ?? decoded['error'];
        if (message is String && message.trim().isNotEmpty) {
          return message;
        }
      }
    } catch (_) {
      // Keep fallback message below.
    }

    return responseBody;
  }
}
