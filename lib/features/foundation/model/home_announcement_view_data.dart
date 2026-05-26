class HomeAnnouncementViewData {
  const HomeAnnouncementViewData({
    required this.announcementId,
    required this.announcementType,
    required this.title,
    required this.subtitle,
    this.imageUrl,
  });

  final String announcementId;
  final String announcementType;
  final String title;
  final String subtitle;
  final String? imageUrl;
}
