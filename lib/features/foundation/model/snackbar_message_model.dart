import 'package:flutter/foundation.dart';
import 'package:golf_kakis/features/foundation/default_values.dart';

void emptySnackbarAction() {}

enum SnackbarDuration { short, long }

class SnackbarMessageModel {
  const SnackbarMessageModel({
    this.message = emptyString,
    this.action = emptySnackbarAction,
    this.actionText = emptyString,
    this.snackbarDuration = SnackbarDuration.short,
    this.withDismiss = emptyBool,
  });

  final String message;
  final VoidCallback action;
  final String actionText;
  final SnackbarDuration snackbarDuration;
  final bool withDismiss;

  bool get hasMessage => message.trim().isNotEmpty;

  static const emptyValue = SnackbarMessageModel();
}
