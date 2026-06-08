import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../util/debug_log.dart';
import 'api_config.dart';
import 'api_exception.dart';

typedef HeaderProvider = Map<String, String> Function();
typedef SessionRefreshProvider = Future<bool> Function();
typedef SessionRefreshCheckProvider = bool Function();

class ApiClient {
  ApiClient({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  static HeaderProvider? _sharedHeaderProvider;
  static SessionRefreshProvider? _sessionRefreshProvider;
  static SessionRefreshCheckProvider? _sessionRefreshCheckProvider;

  final http.Client _client;
  final String _baseUrl;

  static const Map<String, String> _defaultHeaders = <String, String>{
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  static void configureSharedHeaders(HeaderProvider? provider) {
    _sharedHeaderProvider = provider;
  }

  static void configureSessionRefresh(SessionRefreshProvider? provider) {
    _sessionRefreshProvider = provider;
  }

  static void configureSessionRefreshCheck(
    SessionRefreshCheckProvider? provider,
  ) {
    _sessionRefreshCheckProvider = provider;
  }

  Future<dynamic> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path, queryParameters);
    return _sendJsonRequest(
      method: 'GET',
      uri: uri,
      request: () => _client.get(uri, headers: _mergeHeaders(headers)),
    );
  }

  Future<dynamic> getJsonWithoutSharedHeaders(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path, queryParameters);
    return _sendJsonRequest(
      method: 'GET',
      uri: uri,
      shouldRefreshSession: false,
      request: () => _client.get(
        uri,
        headers: _mergeHeaders(headers, includeSharedHeaders: false),
      ),
    );
  }

  Map<String, String> resolveHeaders(Map<String, String>? headers) {
    return _mergeHeaders(headers);
  }

  Future<dynamic> postJson(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path, queryParameters);
    return _sendJsonRequest(
      method: 'POST',
      uri: uri,
      request: () => _client.post(
        uri,
        headers: _mergeHeaders(headers),
        body: body == null ? null : jsonEncode(body),
      ),
    );
  }

  Future<dynamic> postJsonWithoutSharedHeaders(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path, queryParameters);
    return _sendJsonRequest(
      method: 'POST',
      uri: uri,
      shouldRefreshSession: false,
      request: () => _client.post(
        uri,
        headers: _mergeHeaders(headers, includeSharedHeaders: false),
        body: body == null ? null : jsonEncode(body),
      ),
    );
  }

  Future<dynamic> putJson(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path, queryParameters);
    return _sendJsonRequest(
      method: 'PUT',
      uri: uri,
      request: () => _client.put(
        uri,
        headers: _mergeHeaders(headers),
        body: jsonEncode(body),
      ),
    );
  }

  Future<dynamic> patchJson(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path, queryParameters);
    return _sendJsonRequest(
      method: 'PATCH',
      uri: uri,
      request: () => _client.patch(
        uri,
        headers: _mergeHeaders(headers),
        body: jsonEncode(body),
      ),
    );
  }

  Future<dynamic> deleteJson(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path, queryParameters);
    return _sendJsonRequest(
      method: 'DELETE',
      uri: uri,
      request: () => _client.delete(
        uri,
        headers: _mergeHeaders(headers),
        body: body == null ? null : jsonEncode(body),
      ),
    );
  }

  Future<dynamic> postMultipart(
    String path, {
    required Map<String, String> fields,
    required List<MultipartFilePayload> files,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final request = http.MultipartRequest('POST', uri);
    final resolvedHeaders = _mergeHeaders(headers)..remove('Content-Type');
    request.headers.addAll(resolvedHeaders);
    request.fields.addAll(fields);
    for (final file in files) {
      request.files.add(
        await http.MultipartFile.fromPath(
          file.field,
          file.path,
          filename: file.filename,
        ),
      );
    }

    return _sendJsonRequest(
      method: 'POST',
      uri: uri,
      request: () async {
        final streamedResponse = await request.send();
        return http.Response.fromStream(streamedResponse);
      },
    );
  }

  Future<dynamic> _sendJsonRequest({
    required String method,
    required Uri uri,
    required Future<http.Response> Function() request,
    bool shouldRefreshSession = true,
  }) async {
    _logRequest(method, uri);

    try {
      if (shouldRefreshSession && _shouldRefreshBeforeRequest()) {
        logDebug('[API] Refreshing App Session Before $method $uri');
        final refreshed = await _sessionRefreshProvider!.call();
        if (!refreshed) {
          throw ApiException(
            statusCode: 401,
            message: 'Session expired. Please sign in again.',
          );
        }
      }
      final response = await request();
      return _handleJsonResponse(method: method, uri: uri, response: response);
    } on ApiException catch (error) {
      if (shouldRefreshSession && await _shouldRetryAfterRefresh(error)) {
        logDebug('[API] Refreshing App Session Before Retrying $method $uri');
        final refreshed = await _sessionRefreshProvider!.call();
        if (refreshed) {
          final response = await request();
          return _handleJsonResponse(
            method: method,
            uri: uri,
            response: response,
          );
        }
      }
      rethrow;
    } catch (error) {
      if (error is! ApiException) {
        _logTransportError(method, uri, error);
      }
      rethrow;
    }
  }

  dynamic _handleJsonResponse({
    required String method,
    required Uri uri,
    required http.Response response,
  }) {
    try {
      final decoded = _decodeJsonResponse(response);
      _logSuccess(method, uri, response.statusCode);
      return decoded;
    } on ApiException catch (error) {
      _logApiError(method, uri, error);
      rethrow;
    }
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

  Map<String, String> _mergeHeaders(
    Map<String, String>? headers, {
    bool includeSharedHeaders = true,
  }) {
    final sharedHeaders = includeSharedHeaders
        ? (_sharedHeaderProvider?.call() ?? const <String, String>{})
        : const <String, String>{};
    final resolved = <String, String>{
      ..._defaultHeaders,
      ...?headers,
      ...sharedHeaders,
    };
    if (headers != null && !sharedHeaders.containsKey('Authorization')) {
      final explicitAuthorization = headers['Authorization'];
      if (explicitAuthorization != null) {
        resolved['Authorization'] = explicitAuthorization;
      }
    }
    return resolved;
  }

  bool _shouldRefreshBeforeRequest() {
    return _sessionRefreshProvider != null &&
        (_sessionRefreshCheckProvider?.call() ?? false);
  }

  Future<bool> _shouldRetryAfterRefresh(ApiException error) async {
    if (_sessionRefreshProvider == null || error.statusCode != 401) {
      return false;
    }

    return error.message.toLowerCase().contains('invalid app session token');
  }

  void _logRequest(String method, Uri uri) {
    logDebug('[API] $method $uri');
  }

  void _logSuccess(String method, Uri uri, int statusCode) {
    logDebug('[API] OK $statusCode $method $uri');
  }

  void _logApiError(String method, Uri uri, ApiException error) {
    logDebug(
      '[API] FAILED ${error.statusCode} $method $uri - ${error.message}',
    );
  }

  void _logTransportError(String method, Uri uri, Object error) {
    logDebug('[API] ERROR $method $uri - $error');
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
      return _extractMessageFromDecoded(jsonDecode(responseBody)) ??
          responseBody;
    } catch (_) {
      // Keep fallback message below.
    }

    return responseBody;
  }

  String? _extractMessageFromDecoded(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final directMessage = decoded['message'];
      if (directMessage is String && directMessage.trim().isNotEmpty) {
        return directMessage;
      }

      final nestedDataMessage = _extractMessageFromDecoded(decoded['data']);
      if (nestedDataMessage != null) {
        return nestedDataMessage;
      }

      final nestedErrorMessage = _extractMessageFromDecoded(decoded['error']);
      if (nestedErrorMessage != null) {
        return nestedErrorMessage;
      }

      final fallbackError = decoded['error'];
      if (fallbackError is String && fallbackError.trim().isNotEmpty) {
        return fallbackError;
      }
    }

    return null;
  }
}

class MultipartFilePayload {
  const MultipartFilePayload({
    required this.field,
    required this.path,
    this.filename,
  });

  final String field;
  final String path;
  final String? filename;

  String get resolvedFilename => filename ?? File(path).uri.pathSegments.last;
}
