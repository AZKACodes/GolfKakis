class BookingSubmissionPlayerModel {
  const BookingSubmissionPlayerModel({
    this.name = '',
    this.phoneNumber = '',
  });

  final String name;
  final String phoneNumber;

  bool get isComplete => name.trim().isNotEmpty && phoneNumber.trim().isNotEmpty;

  BookingSubmissionPlayerModel copyWith({
    String? name,
    String? phoneNumber,
  }) {
    return BookingSubmissionPlayerModel(
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}
