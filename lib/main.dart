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
    final accessToken = sessionManager.state.accessToken?.trim();

    return <String, String>{
      if (deviceId.isNotEmpty) 'X-Device-ID': deviceId,
      if (accessToken != null && accessToken.isNotEmpty)
        'Authorization': 'Bearer $accessToken',
    };
  });

  runApp(MyApp(sessionManager: sessionManager));
}
