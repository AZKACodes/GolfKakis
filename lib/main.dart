import 'package:flutter/material.dart';

import 'app/app.dart';
import 'features/foundation/device/device_id_service.dart';
import 'features/foundation/session/session_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sessionManager = SessionManager(deviceIdService: DeviceIdService());
  await sessionManager.initialize();

  runApp(MyApp(sessionManager: sessionManager));
}
