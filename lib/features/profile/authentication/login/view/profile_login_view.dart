import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/widgets/input/golf_kakis_phone_number_input.dart';

import '../viewmodel/profile_login_view_contract.dart';

class ProfileLoginView extends StatefulWidget {
  const ProfileLoginView({
    required this.state,
    required this.onUserIntent,
    super.key,
  });

  final ProfileLoginViewState state;
  final ValueChanged<ProfileLoginUserIntent> onUserIntent;

  @override
  State<ProfileLoginView> createState() => _ProfileLoginViewState();
}

class _ProfileLoginViewState extends State<ProfileLoginView> {
  ProfileLoginDataLoaded get _loadedState {
    return switch (widget.state) {
      ProfileLoginDataLoaded() => widget.state as ProfileLoginDataLoaded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = _loadedState;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFFAF2), Color(0xFFF2F7FF), Color(0xFFF1FCF7)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 460),
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
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2F7BFF), Color(0xFF35C7A5)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.lock_person_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Welcome back',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Log in with your phone number, then verify the OTP sent to your phone.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                    ),
                  ),
                  if (state.infoMessage != null) ...[
                    const SizedBox(height: 14),
                    _InlineBanner(
                      message: state.infoMessage!,
                      backgroundColor: const Color(0xFFFFF6E8),
                      borderColor: const Color(0xFFFFD58A),
                      textColor: const Color(0xFF7A5200),
                    ),
                  ],
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 14),
                    _InlineBanner(
                      message: state.errorMessage!,
                      backgroundColor: const Color(0xFFFDECEC),
                      borderColor: const Color(0xFFE7A1A1),
                      textColor: const Color(0xFF8A3D3D),
                    ),
                  ],
                  const SizedBox(height: 16),
                  GolfKakisPhoneNumberInput(
                    phoneNumber: state.phoneNumber,
                    onChanged: (value) =>
                        widget.onUserIntent(OnLoginPhoneChanged(value)),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: state.canSubmit
                          ? () => widget.onUserIntent(
                              const OnLoginClick(visitorId: ''),
                            )
                          : null,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: state.isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Login'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F8FF),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFD8E4FF)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.app_registration_outlined,
                          color: Color(0xFF2F7BFF),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Need an account?',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Register to get started.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: () =>
                              widget.onUserIntent(const OnRegisterClick()),
                          child: const Text('Register'),
                        ),
                      ],
                    ),
                  ),
                  if (state.isSubmitting) ...[
                    const SizedBox(height: 18),
                    const LinearProgressIndicator(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InlineBanner extends StatelessWidget {
  const _InlineBanner({
    required this.message,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });

  final String message;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
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
