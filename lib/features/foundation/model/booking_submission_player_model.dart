class BookingSubmissionPlayerModel {
  const BookingSubmissionPlayerModel({
    this.name = '',
    this.phoneNumber = '',
    this.category = 'normal',
    this.isHost = false,
  });

  final String name;
  final String phoneNumber;
  final String category;
  final bool isHost;

  bool get isComplete =>
      name.trim().isNotEmpty && phoneNumber.trim().isNotEmpty;

  BookingSubmissionPlayerModel copyWith({
    String? name,
    String? phoneNumber,
    String? category,
    bool? isHost,
  }) {
    return BookingSubmissionPlayerModel(
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      category: category ?? this.category,
      isHost: isHost ?? this.isHost,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'phoneNumber': phoneNumber,
      'category': category,
      'isHost': isHost,
    };
  }
}
