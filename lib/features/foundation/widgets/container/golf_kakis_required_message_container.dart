import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/widgets/card_message.dart';

class GolfKakisRequiredMessageContainer extends StatelessWidget {
  const GolfKakisRequiredMessageContainer({
    required this.message,
    this.title,
    this.icon = Icons.info_outline_rounded,
    super.key,
  });

  final String message;
  final String? title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return CardMessage(title: title, message: message, icon: icon);
  }
}
