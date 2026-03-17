import 'package:golf_kakis/features/foundation/enums/booking/time_period.dart';

enum TeeTimeSlot {
  seven00Am('07:00 AM', TimePeriod.am),
  seven15Am('07:15 AM', TimePeriod.am),
  seven30Am('07:30 AM', TimePeriod.am),
  seven45Am('07:45 AM', TimePeriod.am),
  eight00Am('08:00 AM', TimePeriod.am),
  eight15Am('08:15 AM', TimePeriod.am),
  eight30Am('08:30 AM', TimePeriod.am),
  eight45Am('08:45 AM', TimePeriod.am),
  nine00Am('09:00 AM', TimePeriod.am),
  nine15Am('09:15 AM', TimePeriod.am),
  nine30Am('09:30 AM', TimePeriod.am),
  nine45Am('09:45 AM', TimePeriod.am),
  ten00Am('10:00 AM', TimePeriod.am),
  ten15Am('10:15 AM', TimePeriod.am),
  ten30Am('10:30 AM', TimePeriod.am),
  ten45Am('10:45 AM', TimePeriod.am),
  eleven00Am('11:00 AM', TimePeriod.am),
  eleven15Am('11:15 AM', TimePeriod.am),
  eleven30Am('11:30 AM', TimePeriod.am),
  eleven45Am('11:45 AM', TimePeriod.am),
  twelve00Pm('12:00 PM', TimePeriod.pm),
  twelve15Pm('12:15 PM', TimePeriod.pm),
  twelve30Pm('12:30 PM', TimePeriod.pm),
  twelve45Pm('12:45 PM', TimePeriod.pm),
  one00Pm('01:00 PM', TimePeriod.pm),
  one15Pm('01:15 PM', TimePeriod.pm),
  one30Pm('01:30 PM', TimePeriod.pm),
  one45Pm('01:45 PM', TimePeriod.pm),
  two00Pm('02:00 PM', TimePeriod.pm),
  two15Pm('02:15 PM', TimePeriod.pm),
  two30Pm('02:30 PM', TimePeriod.pm),
  two45Pm('02:45 PM', TimePeriod.pm),
  three00Pm('03:00 PM', TimePeriod.pm),
  three15Pm('03:15 PM', TimePeriod.pm),
  three30Pm('03:30 PM', TimePeriod.pm),
  three45Pm('03:45 PM', TimePeriod.pm),
  four00Pm('04:00 PM', TimePeriod.pm),
  four15Pm('04:15 PM', TimePeriod.pm),
  four30Pm('04:30 PM', TimePeriod.pm),
  four45Pm('04:45 PM', TimePeriod.pm),
  five00Pm('05:00 PM', TimePeriod.pm),
  five15Pm('05:15 PM', TimePeriod.pm),
  five30Pm('05:30 PM', TimePeriod.pm);

  const TeeTimeSlot(this.label, this.period);

  final String label;
  final TimePeriod period;

  String get playerRange => isExtendedPlayerSlot ? '1-6' : '1-4';

  bool get isExtendedPlayerSlot {
    return switch (this) {
      TeeTimeSlot.two00Pm ||
      TeeTimeSlot.two15Pm ||
      TeeTimeSlot.two30Pm ||
      TeeTimeSlot.two45Pm ||
      TeeTimeSlot.three00Pm => true,
      _ => false,
    };
  }

  static TeeTimeSlot? fromLabel(String label) {
    for (final slot in TeeTimeSlot.values) {
      if (slot.label == label) {
        return slot;
      }
    }

    return null;
  }
}
