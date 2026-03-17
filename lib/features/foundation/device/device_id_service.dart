import 'package:flutter/services.dart';

class DeviceIdService {
  static const _channel = MethodChannel('golf_kakis/device_id');

  Future<String> getDeviceId() async {
    try {
      final value = await _channel.invokeMethod<String>('getDeviceId');
      if (value == null || value.trim().isEmpty) {
        return 'unknown-device';
      }
      return value;
    } on PlatformException {
      return 'unknown-device';
    } on MissingPluginException {
      return 'unknown-device';
    }
  }
}
