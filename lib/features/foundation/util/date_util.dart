import 'package:flutter/material.dart';

class DateUtil {
  const DateUtil._();

  static DateTime dateOnly(DateTime date) {
    return DateUtils.dateOnly(date);
  }

  static String formatApiDate(DateTime date) {
    final normalized = dateOnly(date);
    final year = normalized.year.toString().padLeft(4, '0');
    final month = normalized.month.toString().padLeft(2, '0');
    final day = normalized.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
