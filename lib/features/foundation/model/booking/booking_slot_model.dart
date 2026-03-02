class BookingSlotModel {
  const BookingSlotModel({required this.slotList});

  final String slotList;

  factory BookingSlotModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawSlotList = json['slotList'];

    if (rawSlotList is String) {
      return BookingSlotModel(slotList: rawSlotList);
    }

    if (rawSlotList is List) {
      return BookingSlotModel(
        slotList: rawSlotList.map((slot) => slot.toString()).join(','),
      );
    }

    return const BookingSlotModel(slotList: '');
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'slotList': slotList};
  }
}
