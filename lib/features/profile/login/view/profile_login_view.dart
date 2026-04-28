import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/util/phone_util.dart';

import '../viewmodel/profile_login_view_contract.dart';

const double _compactLoginPhoneInputHeight = 54;

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
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  ProfileLoginDataLoaded get _loadedState {
    return switch (widget.state) {
      ProfileLoginDataLoaded() => widget.state as ProfileLoginDataLoaded,
    };
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _loadedState.name);
    _phoneController = TextEditingController(text: _loadedState.phoneNumber);
  }

  @override
  void didUpdateWidget(covariant ProfileLoginView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_nameController.text != _loadedState.name) {
      _nameController.text = _loadedState.name;
    }
    if (_phoneController.text != _loadedState.phoneNumber) {
      _phoneController.text = _loadedState.phoneNumber;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
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
                        Icons.person_outline,
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
                    'Sign in to continue with your account.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (state.infoMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF6E8),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFFD58A)),
                      ),
                      child: Text(
                        state.infoMessage!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF7A5200),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    onChanged: (value) =>
                        widget.onUserIntent(OnNameChanged(value)),
                    decoration: InputDecoration(
                      hintText: 'Name',
                      prefixIcon: const Icon(Icons.person_outline),
                      filled: true,
                      fillColor: const Color(0xFFF6F8FC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _LoginPhoneInputRow(
                    selectedCountryCode: state.countryCode,
                    phoneController: _phoneController,
                    onCountryCodeChanged: (value) =>
                        widget.onUserIntent(OnCountryCodeChanged(value)),
                    onPhoneChanged: (value) =>
                        widget.onUserIntent(OnPhoneChanged(value)),
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
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: state.isSubmitting
                          ? null
                          : () => widget.onUserIntent(
                              const OnLoginClick(visitorId: ''),
                            ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text('Request OTP'),
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

class _LoginPhoneInputRow extends StatelessWidget {
  const _LoginPhoneInputRow({
    required this.selectedCountryCode,
    required this.phoneController,
    required this.onCountryCodeChanged,
    required this.onPhoneChanged,
  });

  final PhoneCountryCodeOption selectedCountryCode;
  final TextEditingController phoneController;
  final ValueChanged<PhoneCountryCodeOption> onCountryCodeChanged;
  final ValueChanged<String> onPhoneChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 136, maxWidth: 164),
          child: Container(
            height: _compactLoginPhoneInputHeight,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F8FC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<PhoneCountryCodeOption>(
                value: selectedCountryCode,
                isExpanded: true,
                icon: const Icon(Icons.expand_more_rounded),
                borderRadius: BorderRadius.circular(16),
                items: PhoneUtil.countryCodeOptions.map((option) {
                  return DropdownMenuItem<PhoneCountryCodeOption>(
                    value: option,
                    child: Text(
                      option.compactLabel,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    onCountryCodeChanged(value);
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: _compactLoginPhoneInputHeight,
            child: TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              onChanged: onPhoneChanged,
              decoration: InputDecoration(
                hintText: 'Phone Number',
                prefixIcon: const Icon(Icons.phone_outlined),
                filled: true,
                fillColor: const Color(0xFFF6F8FC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
