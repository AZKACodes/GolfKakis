import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:golf_kakis/features/foundation/util/phone_util.dart';

class GolfKakisPhoneNumberInput extends StatefulWidget {
  const GolfKakisPhoneNumberInput({
    required this.phoneNumber,
    required this.onChanged,
    this.hintText = 'Phone number',
    this.enabled = true,
    super.key,
  });

  final String phoneNumber;
  final ValueChanged<String> onChanged;
  final String hintText;
  final bool enabled;

  @override
  State<GolfKakisPhoneNumberInput> createState() =>
      _GolfKakisPhoneNumberInputState();
}

class _GolfKakisPhoneNumberInputState extends State<GolfKakisPhoneNumberInput> {
  late final TextEditingController _phoneController;
  late PhoneCountryCodeOption _selectedCountryCode;

  @override
  void initState() {
    super.initState();
    final phoneParts = PhoneUtil.splitPhoneNumber(widget.phoneNumber);
    _selectedCountryCode = phoneParts.countryCode;
    _phoneController = TextEditingController(text: phoneParts.localNumber);
  }

  @override
  void didUpdateWidget(covariant GolfKakisPhoneNumberInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phoneNumber == widget.phoneNumber) {
      return;
    }

    final phoneParts = PhoneUtil.splitPhoneNumber(widget.phoneNumber);
    if (_selectedCountryCode != phoneParts.countryCode) {
      _selectedCountryCode = phoneParts.countryCode;
    }
    if (_phoneController.text != phoneParts.localNumber) {
      _phoneController.value = _phoneController.value.copyWith(
        text: phoneParts.localNumber,
        selection: TextSelection.collapsed(
          offset: phoneParts.localNumber.length,
        ),
      );
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CountryCodePickerButton(
          value: _selectedCountryCode,
          enabled: widget.enabled,
          onSelected: (value) {
            setState(() {
              _selectedCountryCode = value;
            });
            _emitChanged();
          },
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: _phoneController,
            enabled: widget.enabled,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => _emitChanged(),
            decoration: InputDecoration(
              hintText: widget.hintText,
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
      ],
    );
  }

  void _emitChanged() {
    widget.onChanged(
      PhoneUtil.normalizeFullPhoneNumber(
        countryCode: _selectedCountryCode,
        localNumber: _phoneController.text,
      ),
    );
  }
}

class _CountryCodePickerButton extends StatelessWidget {
  const _CountryCodePickerButton({
    required this.value,
    required this.enabled,
    required this.onSelected,
  });

  final PhoneCountryCodeOption value;
  final bool enabled;
  final ValueChanged<PhoneCountryCodeOption> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 118,
      height: 56,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: enabled ? () => _showCountryCodeBottomSheet(context) : null,
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
