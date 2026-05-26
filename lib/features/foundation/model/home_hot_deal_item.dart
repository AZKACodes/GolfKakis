class HomeHotDealItem {
  const HomeHotDealItem({
    required this.dealId,
    required this.slotId,
    required this.title,
    required this.description,
    required this.price,
    required this.discountedPrice,
    required this.currency,
    required this.golfClubSlug,
    required this.slotDate,
    required this.slotTime,
    required this.noOfHoles,
    this.imageUrl,
  });

  final String dealId;
  final String slotId;
  final String title;
  final String description;
  final num price;
  final num discountedPrice;
  final String currency;
  final String golfClubSlug;
  final String slotDate;
  final String slotTime;
  final int noOfHoles;
  final String? imageUrl;
}
