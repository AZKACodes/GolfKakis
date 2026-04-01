import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/util/phone_util.dart';

import '../viewmodel/profile_register_method_view_contract.dart';

const double _compactPhoneInputHeight = 54;

class ProfileRegisterMethodView extends StatefulWidget {
  const ProfileRegisterMethodView({
    required this.state,
    required this.onMethodSelected,
    required this.onCountryCodeSelected,
    required this.onPhoneChanged,
    required this.onContinueClick,
    super.key,
  });

  final ProfileRegisterMethodViewState state;
  final ValueChanged<RegisterMethod> onMethodSelected;
  final ValueChanged<PhoneCountryCodeOption> onCountryCodeSelected;
  final ValueChanged<String> onPhoneChanged;
  final VoidCallback onContinueClick;

  @override
  State<ProfileRegisterMethodView> createState() =>
      _ProfileRegisterMethodViewState();
}

class _ProfileRegisterMethodViewState extends State<ProfileRegisterMethodView> {
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.state.phoneNumber);
  }

  @override
  void didUpdateWidget(covariant ProfileRegisterMethodView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_phoneController.text != widget.state.phoneNumber) {
      _phoneController.text = widget.state.phoneNumber;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPhoneSelected = widget.state.selectedMethod == RegisterMethod.phone;

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
                      'Create your account',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Phone registration is the main proof of concept for now. Email is parked as a future step.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _MethodTabs(
                      selectedMethod: widget.state.selectedMethod,
                      onMethodSelected: widget.onMethodSelected,
                    ),
                    const SizedBox(height: 16),
                    if (widget.state.infoMessage != null) ...[
                      _InlineBanner(
                        message: widget.state.infoMessage!,
                        backgroundColor: const Color(0xFFFFF6E8),
                        borderColor: const Color(0xFFFFD58A),
                        textColor: const Color(0xFF7A5200),
                      ),
                      const SizedBox(height: 14),
                    ],
                    if (widget.state.errorMessage != null) ...[
                      _InlineBanner(
                        message: widget.state.errorMessage!,
                        backgroundColor: const Color(0xFFFDECEC),
                        borderColor: const Color(0xFFE7A1A1),
                        textColor: const Color(0xFF8A3D3D),
                      ),
                      const SizedBox(height: 14),
                    ],
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: isPhoneSelected
                          ? Column(
                              key: const ValueKey('phone-form'),
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _PhoneNumberInputRow(
                                  selectedCountryCode: widget.state.countryCode,
                                  controller: _phoneController,
                                  onCountryCodeSelected:
                                      widget.onCountryCodeSelected,
                                  onPhoneChanged: widget.onPhoneChanged,
                                ),
                                const SizedBox(height: 14),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F8FF),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: const Color(0xFFD8E4FF),
                                    ),
                                  ),
                                  child: Text(
                                    'We will take you to a dummy OTP screen next so the whole registration path can be demoed.',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFF34528D),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Container(
                              key: const ValueKey('email-coming-soon'),
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7F7F7),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFFE3E3E3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Email registration',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Coming soon. The phone-first path is the main registration route in this proof of concept.',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: widget.state.isSubmitting
                            ? null
                            : widget.onContinueClick,
                        child: Text(
                          isPhoneSelected
                              ? 'Continue With Phone'
                              : 'Email Coming Soon',
                        ),
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

class _PhoneNumberInputRow extends StatelessWidget {
  const _PhoneNumberInputRow({
    required this.selectedCountryCode,
    required this.controller,
    required this.onCountryCodeSelected,
    required this.onPhoneChanged,
  });

  final PhoneCountryCodeOption selectedCountryCode;
  final TextEditingController controller;
  final ValueChanged<PhoneCountryCodeOption> onCountryCodeSelected;
  final ValueChanged<String> onPhoneChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CountryCodePickerButton(
          value: selectedCountryCode,
          onSelected: onCountryCodeSelected,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: _compactPhoneInputHeight,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
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

class _CountryCodePickerButton extends StatelessWidget {
  const _CountryCodePickerButton({
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
      height: _compactPhoneInputHeight,
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

class _MethodTabs extends StatelessWidget {
  const _MethodTabs({
    required this.selectedMethod,
    required this.onMethodSelected,
  });

  final RegisterMethod selectedMethod;
  final ValueChanged<RegisterMethod> onMethodSelected;

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
            child: _MethodTabButton(
              label: 'Phone',
              isSelected: selectedMethod == RegisterMethod.phone,
              onTap: () => onMethodSelected(RegisterMethod.phone),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _MethodTabButton(
              label: 'Email',
              badge: 'Coming soon',
              isSelected: selectedMethod == RegisterMethod.email,
              onTap: () => onMethodSelected(RegisterMethod.email),
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodTabButton extends StatelessWidget {
  const _MethodTabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  final String label;
  final String? badge;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? const Color(0xFFD7E4FF) : Colors.transparent,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isSelected ? const Color(0xFF20458D) : Colors.black87,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(height: 4),
                Text(
                  badge!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                ),
              ],
            ],
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
