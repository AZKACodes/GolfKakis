class CurrencyUtil {
  const CurrencyUtil._();

  static String formatPrice(double value, String currency, {String? suffix}) {
    final formattedValue = value.toStringAsFixed(
      value.truncateToDouble() == value ? 0 : 2,
    );
    final formattedPrice = '${currency.toUpperCase()} $formattedValue';

    if (suffix == null || suffix.isEmpty) {
      return formattedPrice;
    }

    return '$formattedPrice $suffix';
  }
}
