class HomeSmartRebookItem {
  const HomeSmartRebookItem({
    required this.title,
    required this.subtitle,
    required this.priceLabel,
  });

  final String title;
  final String subtitle;
  final String priceLabel;
}

class HomeHotDealItem {
  const HomeHotDealItem({
    required this.title,
    required this.subtitle,
    required this.priceLabel,
    required this.badge,
  });

  final String title;
  final String subtitle;
  final String priceLabel;
  final String badge;
}

class HomeQuickBookItem {
  const HomeQuickBookItem({
    required this.clubSlug,
    required this.title,
    required this.subtitle,
    required this.priceLabel,
    required this.badge,
  });

  final String clubSlug;
  final String title;
  final String subtitle;
  final String priceLabel;
  final String badge;
}
