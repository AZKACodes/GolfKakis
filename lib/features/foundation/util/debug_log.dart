import 'package:flutter/foundation.dart';

void logDebug(String? message, {int? wrapWidth}) {
  if (!kDebugMode) {
    return;
  }

  debugPrint(message, wrapWidth: wrapWidth);
}

void logDebugStack({StackTrace? stackTrace, String? label}) {
  if (!kDebugMode) {
    return;
  }

  debugPrintStack(stackTrace: stackTrace, label: label);
}
