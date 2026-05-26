class StringUtil {
  const StringUtil._();

  static String buildInitials(String fullName, {String fallback = 'U'}) {
    final parts = fullName
        .split(' ')
        .where((part) => part.trim().isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return fallback;
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  static String capitalizeFirst(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return normalized;
    }
    return normalized[0].toUpperCase() + normalized.substring(1);
  }

  static String formatSentenceLabel(String? value, {String fallback = ''}) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      return fallback;
    }

    return normalized
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  static String formatEnumLabel(String? value, {String fallback = '-'}) {
    return formatSentenceLabel(value, fallback: fallback);
  }
}
