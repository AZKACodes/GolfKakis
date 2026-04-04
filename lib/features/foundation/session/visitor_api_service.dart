import 'package:flutter/foundation.dart';

import '../network/network.dart';
import 'session_visitor.dart';

class VisitorApiService {
  VisitorApiService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<SessionVisitor> onSetVisitorHeartbeat({
    required String visitorId,
    required String platform,
  }) async {
    final response = await _apiClient.postJson(
      '/visitor/heartbeat',
      body: <String, dynamic>{'visitor_id': visitorId, 'platform': platform},
    );

    if (response is! Map<String, dynamic>) {
      throw ApiException(
        statusCode: 500,
        message: 'Visitor heartbeat returned an invalid response.',
      );
    }

    final visitor = response['visitor'];
    if (visitor is! Map<String, dynamic>) {
      throw ApiException(
        statusCode: 500,
        message: 'Visitor heartbeat response is missing visitor data.',
      );
    }

    return SessionVisitor.fromJson(visitor);
  }

  String resolvePlatform() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return 'android';
    }
  }
}
