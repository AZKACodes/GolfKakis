import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class DeviceIdService {
  static const _deviceIdKey = 'golf_kakis_device_uuid_v4';
  static final _uuidV4Pattern = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  Future<String> getDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedDeviceId = prefs.getString(_deviceIdKey);

      if (_isUuidV4(storedDeviceId)) {
        return storedDeviceId!.toLowerCase();
      }

      final deviceId = _buildUuidV4();
      await prefs.setString(_deviceIdKey, deviceId);
      return deviceId;
    } catch (_) {
      return _buildUuidV4();
    }
  }

  bool _isUuidV4(String? value) {
    return value != null && _uuidV4Pattern.hasMatch(value.trim());
  }

  String _buildUuidV4() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));

    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    final hex = bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();

    return '${hex.substring(0, 8)}-'
        '${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-'
        '${hex.substring(16, 20)}-'
        '${hex.substring(20, 32)}';
  }
}
