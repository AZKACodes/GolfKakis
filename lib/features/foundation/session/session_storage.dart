import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'session_state.dart';

class SessionStorage {
  SessionStorage({Future<SharedPreferences>? sharedPreferences})
    : _sharedPreferencesFuture =
          sharedPreferences ?? SharedPreferences.getInstance();

  static const String _sessionStateKey = 'session_state';

  final Future<SharedPreferences> _sharedPreferencesFuture;

  Future<SessionState?> read() async {
    final sharedPreferences = await _sharedPreferencesFuture;
    final encoded = sharedPreferences.getString(_sessionStateKey);
    if (encoded == null || encoded.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map) {
        return null;
      }
      return SessionState.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }

  Future<void> write(SessionState state) async {
    final sharedPreferences = await _sharedPreferencesFuture;
    await sharedPreferences.setString(
      _sessionStateKey,
      jsonEncode(state.toJson()),
    );
  }
}
