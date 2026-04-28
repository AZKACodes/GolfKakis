import 'package:flutter/material.dart';

import '../viewmodel/profile_login_otp_view_contract.dart';

class ProfileLoginOtpView extends StatefulWidget {
  const ProfileLoginOtpView({
    required this.state,
    required this.onUserIntent,
    super.key,
  });

  final ProfileLoginOtpViewState state;
  final ValueChanged<ProfileLoginOtpUserIntent> onUserIntent;

  @override
  State<ProfileLoginOtpView> createState() => _ProfileLoginOtpViewState();
}

class _ProfileLoginOtpViewState extends State<ProfileLoginOtpView> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  ProfileLoginOtpDataLoaded get _loadedState {
    return switch (widget.state) {
      ProfileLoginOtpDataLoaded() => widget.state as ProfileLoginOtpDataLoaded,
    };
  }

  @override
  void initState() {
    super.initState();
    _controllers = List<TextEditingController>.generate(
      6,
      (index) => TextEditingController(text: _loadedState.otpDigits[index]),
    );
    _focusNodes = List<FocusNode>.generate(6, (_) => FocusNode());
  }

  @override
  void didUpdateWidget(covariant ProfileLoginOtpView oldWidget) {
    super.didUpdateWidget(oldWidget);
    for (var i = 0; i < _controllers.length; i++) {
      if (_controllers[i].text != _loadedState.otpDigits[i]) {
        _controllers[i].text = _loadedState.otpDigits[i];
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
    widget.onUserIntent(OnLoginOtpDigitChanged(index: index, value: value));
    if (value.isNotEmpty && index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = _loadedState;

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
                      'Enter verification code',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We sent a 6-digit OTP to ${state.phoneNumber}.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDECEC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE7A1A1)),
                        ),
                        child: Text(
                          state.errorMessage!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF8A3D3D),
                            fontWeight: FontWeight.w600,
                          ),
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
                        onPressed: state.canVerify
                            ? () => widget.onUserIntent(
                                const OnLoginOtpVerifyClick(visitorId: ''),
                              )
                            : null,
                        child: const Text('Verify OTP'),
                      ),
                    ),
                    if (state.isSubmitting) ...[
                      const SizedBox(height: 14),
                      const LinearProgressIndicator(),
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
}
