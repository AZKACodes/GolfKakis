import 'package:flutter/material.dart';

import 'app/app.dart';
import 'features/foundation/device/device_id_service.dart';
import 'features/foundation/network/api_client.dart';
import 'features/foundation/session/session_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sessionManager = SessionManager(deviceIdService: DeviceIdService());
  await sessionManager.initialize();
  ApiClient.configureSharedHeaders(() {
    final deviceId = sessionManager.deviceId.trim();
    if (deviceId.isEmpty) {
      return const <String, String>{};
    }

    return <String, String>{'X-Device-ID': deviceId};
  });

  runApp(MyApp(sessionManager: sessionManager));
}
