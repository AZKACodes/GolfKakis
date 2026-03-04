import 'package:flutter/material.dart';

class AppDatePickerButton extends StatelessWidget {
  const AppDatePickerButton({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDatePicked,
    this.label = 'Pick Date',
    this.icon = Icons.calendar_today,
    this.buttonStyle,
    super.key,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onDatePicked;
  final String label;
  final IconData icon;
  final ButtonStyle? buttonStyle;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _handlePressed(context),
      icon: Icon(icon, size: 16),
      label: Text(label),
      style:
          buttonStyle ??
          OutlinedButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
    );
  }

  Future<void> _handlePressed(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (!context.mounted || picked == null) {
      return;
    }

    onDatePicked(picked);
  }
}
