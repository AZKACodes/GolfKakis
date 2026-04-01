class PhoneCountryCodeOption {
  const PhoneCountryCodeOption({
    required this.isoCode,
    required this.dialCode,
    required this.countryName,
  });

  final String isoCode;
  final String dialCode;
  final String countryName;

  String get bottomSheetLabel => '$countryName ($dialCode)';
  String get compactLabel => '$isoCode $dialCode';
}

class PhoneNumberParts {
  const PhoneNumberParts({
    required this.countryCode,
    required this.localNumber,
  });

  final PhoneCountryCodeOption countryCode;
  final String localNumber;
}

class PhoneUtil {
  static const PhoneCountryCodeOption defaultCountryCodeOption =
      PhoneCountryCodeOption(
        isoCode: 'MY',
        dialCode: '+60',
        countryName: 'Malaysia',
      );

  static const List<PhoneCountryCodeOption> countryCodeOptions =
      <PhoneCountryCodeOption>[
        defaultCountryCodeOption,
        PhoneCountryCodeOption(
          isoCode: 'SG',
          dialCode: '+65',
          countryName: 'Singapore',
        ),
        PhoneCountryCodeOption(
          isoCode: 'ID',
          dialCode: '+62',
          countryName: 'Indonesia',
        ),
        PhoneCountryCodeOption(
          isoCode: 'TH',
          dialCode: '+66',
          countryName: 'Thailand',
        ),
        PhoneCountryCodeOption(
          isoCode: 'VN',
          dialCode: '+84',
          countryName: 'Vietnam',
        ),
      ];

  static String normalizeLocalPhoneNumber(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  static String normalizeFullPhoneNumber({
    required PhoneCountryCodeOption countryCode,
    required String localNumber,
  }) {
    final normalizedLocal = normalizeLocalPhoneNumber(localNumber);
    final normalizedDialCode = countryCode.dialCode.replaceAll(' ', '');
    return '$normalizedDialCode$normalizedLocal';
  }

  static PhoneNumberParts splitPhoneNumber(String value) {
    final sanitized = value.replaceAll(RegExp(r'[^0-9+]'), '');

    for (final option in countryCodeOptions) {
      final dialCode = option.dialCode.replaceAll(' ', '');
      if (sanitized.startsWith(dialCode)) {
        return PhoneNumberParts(
          countryCode: option,
          localNumber: sanitized.substring(dialCode.length),
        );
      }
    }

    return PhoneNumberParts(
      countryCode: defaultCountryCodeOption,
      localNumber: normalizeLocalPhoneNumber(sanitized),
    );
  }
}
