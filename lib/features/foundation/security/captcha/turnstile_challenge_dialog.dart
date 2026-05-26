import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'captcha_token_provider.dart';

const String _turnstileSiteKey = String.fromEnvironment('TURNSTILE_SITE_KEY');
const String _turnstileChallengeUrl = String.fromEnvironment(
  'TURNSTILE_CHALLENGE_URL',
  defaultValue: 'https://golfkakis-web.vercel.app/mobile-turnstile',
);

Future<String> showTurnstileChallenge({
  required BuildContext context,
  required CaptchaTokenAction action,
}) async {
  if (!context.mounted) {
    return '';
  }

  final token = await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _TurnstileChallengeDialog(action: action),
  );

  if (token == null || token.trim().isEmpty) {
    throw const CaptchaTokenException('Captcha verification was cancelled.');
  }

  return token;
}

class _TurnstileChallengeDialog extends StatefulWidget {
  const _TurnstileChallengeDialog({required this.action});

  final CaptchaTokenAction action;

  @override
  State<_TurnstileChallengeDialog> createState() =>
      _TurnstileChallengeDialogState();
}

class _TurnstileChallengeDialogState extends State<_TurnstileChallengeDialog> {
  String _errorMessage = '';
  bool _isLoaded = false;
  bool _hasCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SizedBox(
        width: 360,
        height: 420,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Security check',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            if (!_isLoaded) const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: Stack(
                children: [
                  InAppWebView(
                    initialUrlRequest: _initialUrlRequest,
                    initialData: _initialData,
                    initialUserScripts: UnmodifiableListView<UserScript>([
                      UserScript(
                        source: _turnstileBridgeScript,
                        injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
                      ),
                    ]),
                    initialSettings: InAppWebViewSettings(
                      javaScriptEnabled: true,
                      domStorageEnabled: true,
                      useShouldOverrideUrlLoading: true,
                      supportZoom: false,
                      transparentBackground: true,
                    ),
                    onWebViewCreated: (controller) {
                      controller.addJavaScriptHandler(
                        handlerName: 'turnstileToken',
                        callback: (arguments) {
                          _handleTurnstileMessage(arguments);
                        },
                      );
                      controller.addJavaScriptHandler(
                        handlerName: 'turnstileError',
                        callback: (arguments) {
                          final message = arguments.isEmpty
                              ? 'Unable to complete security check.'
                              : arguments.first.toString();
                          if (mounted) {
                            setState(() => _errorMessage = message);
                          }
                        },
                      );
                    },
                    onLoadStop: (controller, url) async {
                      await controller.evaluateJavascript(
                        source: _turnstileBridgeScript,
                      );
                      _completeWithToken(_tokenFromUri(url));
                      if (mounted) {
                        setState(() => _isLoaded = true);
                      }
                    },
                    onReceivedError: (controller, request, error) {
                      if (mounted) {
                        setState(() => _errorMessage = error.description);
                      }
                    },
                    shouldOverrideUrlLoading:
                        (controller, navigationAction) async {
                          final uri = navigationAction.request.url;
                          final token = _tokenFromUri(uri);
                          if (token.trim().isNotEmpty) {
                            _completeWithToken(token);
                            return NavigationActionPolicy.CANCEL;
                          }

                          return NavigationActionPolicy.ALLOW;
                        },
                  ),
                  if (_errorMessage.trim().isNotEmpty)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        color: Theme.of(context).colorScheme.errorContainer,
                        child: Text(
                          _errorMessage,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  URLRequest? get _initialUrlRequest {
    final url = _resolvedChallengeUrl;
    if (url == null) {
      return null;
    }

    return URLRequest(url: WebUri.uri(url));
  }

  InAppWebViewInitialData? get _initialData {
    if (_resolvedChallengeUrl != null) {
      return null;
    }

    if (_turnstileSiteKey.trim().isEmpty) {
      return InAppWebViewInitialData(
        data: _errorHtml('Turnstile site key is not configured.'),
      );
    }

    return InAppWebViewInitialData(
      data: _inlineChallengeHtml(
        siteKey: _turnstileSiteKey.trim(),
        action: widget.action.value,
      ),
      baseUrl: WebUri('https://golfkakis-turnstile.local'),
    );
  }

  Uri? get _resolvedChallengeUrl {
    final rawUrl = _turnstileChallengeUrl.trim();
    if (rawUrl.isEmpty) {
      return null;
    }

    final uri = Uri.parse(rawUrl);
    final queryParameters = <String, String>{
      ...uri.queryParameters,
      'action': widget.action.value,
      if (_turnstileSiteKey.trim().isNotEmpty)
        'sitekey': _turnstileSiteKey.trim(),
    };

    return uri.replace(queryParameters: queryParameters);
  }

  void _handleTurnstileMessage(List<dynamic> arguments) {
    if (arguments.isEmpty) {
      return;
    }

    final message = arguments.first;
    if (message is Map) {
      final type = message['type']?.toString() ?? '';
      if (type == 'turnstile_error') {
        _showError(message['message']?.toString() ?? '');
        return;
      }

      _completeWithToken(message['token']?.toString() ?? '');
      return;
    }

    final rawMessage = message.toString();
    try {
      final decoded = jsonDecode(rawMessage);
      if (decoded is Map<String, dynamic>) {
        _handleTurnstileMessage(<dynamic>[decoded]);
        return;
      }
    } catch (_) {
      // Keep plain-token fallback below.
    }

    _completeWithToken(rawMessage);
  }

  void _completeWithToken(String token) {
    final trimmedToken = token.trim();
    if (trimmedToken.isEmpty || _hasCompleted || !mounted) {
      return;
    }

    _hasCompleted = true;
    Navigator.of(context).pop(trimmedToken);
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }

    setState(() {
      _errorMessage = message.trim().isEmpty
          ? 'Unable to complete security check.'
          : message;
    });
  }

  String _tokenFromUri(Uri? uri) {
    if (uri == null) {
      return '';
    }

    if (uri.scheme == 'golfkakis-turnstile') {
      return uri.queryParameters['token'] ??
          uri.queryParameters['captchaToken'] ??
          '';
    }

    return uri.queryParameters['token'] ??
        uri.queryParameters['captchaToken'] ??
        uri.queryParameters['cf-turnstile-response'] ??
        '';
  }
}

const String _turnstileBridgeScript = '''
(function () {
  if (window.__golfKakisTurnstileBridgeInstalled) {
    return;
  }
  window.__golfKakisTurnstileBridgeInstalled = true;

  function forward(message) {
    try {
      if (window.flutter_inappwebview) {
        window.flutter_inappwebview.callHandler('turnstileToken', message);
      }
    } catch (error) {}
  }

  window.TurnstileToken = window.TurnstileToken || {};
  window.TurnstileToken.postMessage = forward;
  window.Captcha = window.Captcha || {};
  window.Captcha.postMessage = forward;
})();
''';

String _inlineChallengeHtml({
  required String siteKey,
  required String action,
}) {
  final escapedSiteKey = _escapeJs(siteKey);
  final escapedAction = _escapeJs(action);

  return '''
<!doctype html>
<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style>
      html, body {
        align-items: center;
        background: #ffffff;
        display: flex;
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
        height: 100%;
        justify-content: center;
        margin: 0;
      }
    </style>
    <script>
      function sendToken(token) {
        if (window.flutter_inappwebview) {
          window.flutter_inappwebview.callHandler('turnstileToken', token);
          return;
        }
        window.location.href = 'golfkakis-turnstile://token?token=' + encodeURIComponent(token);
      }

      function sendError(message) {
        if (window.flutter_inappwebview) {
          window.flutter_inappwebview.callHandler('turnstileError', message);
        }
      }

      window.onloadTurnstileCallback = function () {
        turnstile.render('#turnstile-container', {
          sitekey: '$escapedSiteKey',
          action: '$escapedAction',
          callback: sendToken,
          'error-callback': function (code) {
            sendError('Security check failed: ' + code);
          },
          'expired-callback': function () {
            sendError('Security check expired. Please try again.');
          },
          'timeout-callback': function () {
            sendError('Security check timed out. Please try again.');
          }
        });
      };
    </script>
    <script src="https://challenges.cloudflare.com/turnstile/v0/api.js?render=explicit&onload=onloadTurnstileCallback" async defer></script>
  </head>
  <body>
    <div id="turnstile-container"></div>
  </body>
</html>
''';
}

String _errorHtml(String message) {
  final escapedMessage = message
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');

  return '''
<!doctype html>
<html>
  <body style="font-family: sans-serif; padding: 24px;">
    <p>$escapedMessage</p>
  </body>
</html>
''';
}

String _escapeJs(String value) {
  return value
      .replaceAll(r'\', r'\\')
      .replaceAll("'", r"\'")
      .replaceAll('\n', r'\n')
      .replaceAll('\r', r'\r');
}
