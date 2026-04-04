import 'dart:math';

class UserUtil {
  UserUtil._();

  static const Duration _bookingUuidLifetime = Duration(minutes: 5);
  static final Random _random = Random.secure();

  static String? _cachedBookingUuid;
  static DateTime? _cachedBookingUuidExpiresAt;

  static String onGenerateBookingUUID() {
    final now = DateTime.now();
    final cachedBookingUuid = _cachedBookingUuid;
    final cachedBookingUuidExpiresAt = _cachedBookingUuidExpiresAt;

    if (cachedBookingUuid != null &&
        cachedBookingUuidExpiresAt != null &&
        now.isBefore(cachedBookingUuidExpiresAt)) {
      return cachedBookingUuid;
    }

    final uuid = _buildUuidV4();
    _cachedBookingUuid = uuid;
    _cachedBookingUuidExpiresAt = now.add(_bookingUuidLifetime);
    return uuid;
  }

  static void clearBookingUUID() {
    _cachedBookingUuid = null;
    _cachedBookingUuidExpiresAt = null;
  }

  static String _buildUuidV4() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    final hex = bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();

    return '${hex.substring(0, 8)}-'
        '${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-'
        '${hex.substring(16, 20)}-'
        '${hex.substring(20, 32)}';
  }
}
