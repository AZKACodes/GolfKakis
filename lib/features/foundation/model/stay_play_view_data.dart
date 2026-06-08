class StayPlayViewData {
  const StayPlayViewData({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.currency,
    this.location,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String description;
  final num price;
  final String currency;
  final String? location;
  final String? imageUrl;
}
