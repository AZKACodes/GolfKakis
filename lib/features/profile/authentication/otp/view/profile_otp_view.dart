import 'package:flutter/material.dart';

import '../viewmodel/profile_otp_view_contract.dart';

class ProfileOtpView extends StatefulWidget {
  const ProfileOtpView({
    required this.state,
    required this.onUserIntent,
    super.key,
  });

  final ProfileOtpViewState state;
  final ValueChanged<ProfileOtpUserIntent> onUserIntent;

  @override
  State<ProfileOtpView> createState() => _ProfileOtpViewState();
}

class _ProfileOtpViewState extends State<ProfileOtpView> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List<TextEditingController>.generate(
      6,
      (index) => TextEditingController(text: widget.state.otpDigits[index]),
    );
    _focusNodes = List<FocusNode>.generate(6, (_) => FocusNode());
  }

  @override
  void didUpdateWidget(covariant ProfileOtpView oldWidget) {
    super.didUpdateWidget(oldWidget);
    for (var i = 0; i < _controllers.length; i++) {
      if (_controllers[i].text != widget.state.otpDigits[i]) {
        _controllers[i].text = widget.state.otpDigits[i];
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _handleChanged(int index, String value) {
    widget.onUserIntent(OnProfileOtpDigitChanged(index: index, value: value));
    if (value.isNotEmpty && index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFFBF4), Color(0xFFF2F7FF), Color(0xFFF0FCF6)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A2F7BFF),
                      blurRadius: 30,
                      offset: Offset(0, 18),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verify your phone',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We sent a 6-digit OTP to ${widget.state.destinationLabel}.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                    if (widget.state.successMessage.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _InlineBanner(
                        message: widget.state.successMessage,
                        isError: false,
                      ),
                    ],
                    if (widget.state.errorMessage != null) ...[
                      const SizedBox(height: 14),
                      _InlineBanner(
                        message: widget.state.errorMessage!,
                        isError: true,
                      ),
                    ],
                    if (widget.state.otpRemainingSeconds > 0) ...[
                      const SizedBox(height: 14),
                      Text(
                        'Code expires in ${_formatDuration(widget.state.otpRemainingSeconds)}.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      children: List<Widget>.generate(6, (index) {
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: index == 5 ? 0 : 8),
                            child: TextField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              onChanged: (value) =>
                                  _handleChanged(index, value),
                              decoration: InputDecoration(
                                counterText: '',
                                filled: true,
                                fillColor: const Color(0xFFF6F8FC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: widget.state.canVerify
                            ? () => widget.onUserIntent(
                                const OnProfileOtpVerifyClick(visitorId: ''),
                              )
                            : null,
                        child: widget.state.isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Verify OTP'),
                      ),
                    ),
                    if (widget.state.showsResend) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: widget.state.canResend
                              ? () => widget.onUserIntent(
                                  const OnProfileOtpResendClick(visitorId: ''),
                                )
                              : null,
                          child: Text(
                            widget.state.isSendingOtp
                                ? 'Sending WhatsApp OTP...'
                                : 'Resend OTP',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class _InlineBanner extends StatelessWidget {
  const _InlineBanner({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isError
        ? const Color(0xFFFDECEC)
        : const Color(0xFFF0F8F2);
    final borderColor = isError
        ? const Color(0xFFE7A1A1)
        : const Color(0xFF9CCFAB);
    final textColor = isError
        ? const Color(0xFF8A3D3D)
        : const Color(0xFF0D6B35);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
