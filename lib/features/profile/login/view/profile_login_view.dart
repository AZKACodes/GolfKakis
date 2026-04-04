import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/util/phone_util.dart';

import '../viewmodel/profile_login_view_contract.dart';

const double _compactLoginPhoneInputHeight = 54;

class ProfileLoginView extends StatefulWidget {
  const ProfileLoginView({
    required this.state,
    required this.onLoginMethodChanged,
    required this.onEmailChanged,
    required this.onCountryCodeChanged,
    required this.onPhoneChanged,
    required this.onPasswordChanged,
    required this.onLoginClick,
    required this.onRegisterClick,
    super.key,
  });

  final ProfileLoginViewState state;
  final ValueChanged<LoginMethod> onLoginMethodChanged;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<PhoneCountryCodeOption> onCountryCodeChanged;
  final ValueChanged<String> onPhoneChanged;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onLoginClick;
  final VoidCallback onRegisterClick;

  @override
  State<ProfileLoginView> createState() => _ProfileLoginViewState();
}

class _ProfileLoginViewState extends State<ProfileLoginView> {
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.state.email);
    _phoneController = TextEditingController(text: widget.state.phoneNumber);
    _passwordController = TextEditingController(text: widget.state.password);
  }

  @override
  void didUpdateWidget(covariant ProfileLoginView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_emailController.text != widget.state.email) {
      _emailController.text = widget.state.email;
    }
    if (_phoneController.text != widget.state.phoneNumber) {
      _phoneController.text = widget.state.phoneNumber;
    }
    if (_passwordController.text != widget.state.password) {
      _passwordController.text = widget.state.password;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPhoneLogin = widget.state.loginMethod == LoginMethod.phone;

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
                  Container(
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
                  const SizedBox(height: 20),
                  _LoginMethodTabs(
                    selectedMethod: widget.state.loginMethod,
                    onChanged: widget.onLoginMethodChanged,
                  ),
                  const SizedBox(height: 14),
                  if (widget.state.infoMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF6E8),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFFD58A)),
                      ),
                      child: Text(
                        widget.state.infoMessage!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF7A5200),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: isPhoneLogin
                        ? _LoginPhoneInputRow(
                            key: const ValueKey('phone-login'),
                            selectedCountryCode: widget.state.countryCode,
                            phoneController: _phoneController,
                            onCountryCodeChanged: widget.onCountryCodeChanged,
                            onPhoneChanged: widget.onPhoneChanged,
                          )
                        : const SizedBox.shrink(key: ValueKey('email-empty')),
                  ),
                  if (isPhoneLogin) ...[
                    const SizedBox(height: 14),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      onChanged: widget.onPasswordChanged,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        filled: true,
                        fillColor: const Color(0xFFF6F8FC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
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
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: widget.state.isSubmitting || !isPhoneLogin
                          ? null
                          : widget.onLoginClick,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text('Login'),
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
                          onPressed: widget.onRegisterClick,
                          child: const Text('Register'),
                        ),
                      ],
                    ),
                  ),
                  if (widget.state.isSubmitting) ...[
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

class _LoginMethodTabs extends StatelessWidget {
  const _LoginMethodTabs({
    required this.selectedMethod,
    required this.onChanged,
  });

  final LoginMethod selectedMethod;
  final ValueChanged<LoginMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5F8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: _LoginMethodTabButton(
              label: 'Email',
              badge: 'Coming soon',
              isSelected: selectedMethod == LoginMethod.email,
              onTap: () => onChanged(LoginMethod.email),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _LoginMethodTabButton(
              label: 'Phone',
              isSelected: selectedMethod == LoginMethod.phone,
              onTap: () => onChanged(LoginMethod.phone),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginMethodTabButton extends StatelessWidget {
  const _LoginMethodTabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x12224A8B),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isSelected ? const Color(0xFF1A2A44) : Colors.black54,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(height: 2),
                Text(
                  badge!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.black45,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
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
    super.key,
  });

  final PhoneCountryCodeOption selectedCountryCode;
  final TextEditingController phoneController;
  final ValueChanged<PhoneCountryCodeOption> onCountryCodeChanged;
  final ValueChanged<String> onPhoneChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _LoginCountryCodePickerButton(
          value: selectedCountryCode,
          onSelected: onCountryCodeChanged,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: _compactLoginPhoneInputHeight,
            child: TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              onChanged: onPhoneChanged,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                hintText: 'Phone number',
                prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 16,
                ),
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

class _LoginCountryCodePickerButton extends StatelessWidget {
  const _LoginCountryCodePickerButton({
    required this.value,
    required this.onSelected,
  });

  final PhoneCountryCodeOption value;
  final ValueChanged<PhoneCountryCodeOption> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 118,
      height: _compactLoginPhoneInputHeight,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showCountryCodeBottomSheet(context),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F8FC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value.compactLabel,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showCountryCodeBottomSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Country Code',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'Choose the dialing code before entering the phone number.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: PhoneUtil.countryCodeOptions.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final option = PhoneUtil.countryCodeOptions[index];
                    final isSelected = option.dialCode == value.dialCode;

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          Navigator.of(context).pop();
                          onSelected(option);
                        },
                        child: Ink(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFF0F8F2)
                                : const Color(0xFFF8F8F6),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF0D7A3A)
                                  : const Color(0x14000000),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  option.bottomSheetLabel,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF0D7A3A),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
