import 'package:flutter/material.dart';

import '../viewmodel/profile_register_otp_view_contract.dart';

class ProfileRegisterOtpView extends StatefulWidget {
  const ProfileRegisterOtpView({
    required this.state,
    required this.onOtpChanged,
    required this.onContinueClick,
    super.key,
  });

  final ProfileRegisterOtpViewState state;
  final void Function(int index, String value) onOtpChanged;
  final VoidCallback onContinueClick;

  @override
  State<ProfileRegisterOtpView> createState() => _ProfileRegisterOtpViewState();
}

class _ProfileRegisterOtpViewState extends State<ProfileRegisterOtpView> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List<TextEditingController>.generate(
      4,
      (index) => TextEditingController(text: widget.state.otpDigits[index]),
    );
    _focusNodes = List<FocusNode>.generate(4, (_) => FocusNode());
  }

  @override
  void didUpdateWidget(covariant ProfileRegisterOtpView oldWidget) {
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
    widget.onOtpChanged(index, value);
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
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
                      'We sent a temporary demo code to ${widget.state.phoneNumber}.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF6E8),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFFD58A)),
                      ),
                      child: Text(
                        'Showing temporary fallback. OTP verification is not connected yet, but the flow will continue for the proof of concept.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF7A5200),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (widget.state.errorMessage != null) ...[
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
                          widget.state.errorMessage!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF8A3D3D),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      children: List<Widget>.generate(4, (index) {
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: index == 3 ? 0 : 10,
                            ),
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
                        onPressed: widget.state.isSubmitting
                            ? null
                            : widget.onContinueClick,
                        child: const Text('Continue To Profile Setup'),
                      ),
                    ),
                    if (widget.state.isSubmitting) ...[
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
