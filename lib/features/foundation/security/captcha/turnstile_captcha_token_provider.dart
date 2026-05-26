import 'package:flutter/material.dart';

import 'captcha_token_provider.dart';
import 'turnstile_challenge_dialog.dart';

class TurnstileCaptchaTokenProvider implements CaptchaTokenProvider {
  const TurnstileCaptchaTokenProvider({required BuildContext context})
    : _context = context;

  final BuildContext _context;

  @override
  Future<String> execute(CaptchaTokenAction action) {
    return showTurnstileChallenge(context: _context, action: action);
  }
}
