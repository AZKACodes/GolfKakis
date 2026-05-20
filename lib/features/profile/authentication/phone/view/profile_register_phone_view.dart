import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/widgets/input/golf_kakis_phone_number_input.dart';

import '../viewmodel/profile_register_phone_view_contract.dart';

class ProfileRegisterPhoneView extends StatefulWidget {
  const ProfileRegisterPhoneView({
    required this.state,
    required this.onPhoneChanged,
    required this.onContinueClick,
    super.key,
  });

  final ProfileRegisterPhoneViewState state;
  final ValueChanged<String> onPhoneChanged;
  final VoidCallback onContinueClick;

  @override
  State<ProfileRegisterPhoneView> createState() =>
      _ProfileRegisterPhoneViewState();
}

class _ProfileRegisterPhoneViewState extends State<ProfileRegisterPhoneView> {
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
                      'Enter your phone number',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We’ll send a one-time password to verify your account.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
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
                    const SizedBox(height: 18),
                    GolfKakisPhoneNumberInput(
                      phoneNumber: widget.state.phoneNumber,
                      onChanged: widget.onPhoneChanged,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: widget.state.isSubmitting
                            ? null
                            : widget.onContinueClick,
                        child: const Text('Send OTP'),
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
