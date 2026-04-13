import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/util/phone_util.dart';

import '../viewmodel/profile_login_view_contract.dart';

const double _compactLoginPhoneInputHeight = 54;

class ProfileLoginView extends StatefulWidget {
  const ProfileLoginView({
    required this.state,
    required this.onNameChanged,
    required this.onCountryCodeChanged,
    required this.onPhoneChanged,
    required this.onLoginClick,
    required this.onRegisterClick,
    super.key,
  });

  final ProfileLoginViewState state;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<PhoneCountryCodeOption> onCountryCodeChanged;
  final ValueChanged<String> onPhoneChanged;
  final VoidCallback onLoginClick;
  final VoidCallback onRegisterClick;

  @override
  State<ProfileLoginView> createState() => _ProfileLoginViewState();
}

class _ProfileLoginViewState extends State<ProfileLoginView> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.state.name);
    _phoneController = TextEditingController(text: widget.state.phoneNumber);
  }

  @override
  void didUpdateWidget(covariant ProfileLoginView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_nameController.text != widget.state.name) {
      _nameController.text = widget.state.name;
    }
    if (_phoneController.text != widget.state.phoneNumber) {
      _phoneController.text = widget.state.phoneNumber;
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
                  TextField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    onChanged: widget.onNameChanged,
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
                    selectedCountryCode: widget.state.countryCode,
                    phoneController: _phoneController,
                    onCountryCodeChanged: widget.onCountryCodeChanged,
                    onPhoneChanged: widget.onPhoneChanged,
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
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: widget.state.isSubmitting
                          ? null
                          : widget.onLoginClick,
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
