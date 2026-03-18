import '../../../foundation/network/network.dart';
import '../../api/home_api_service.dart';
import 'home_overview_models.dart';

abstract class HomeRepository {
  Future<String> fetchWelcomeMessage();
  Future<List<HomeSmartRebookItem>> fetchSmartRebookItems();
  Future<List<HomeHotDealItem>> fetchHotDeals();
}

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({ApiClient? apiClient, HomeApiService? apiService});

  @override
  Future<String> fetchWelcomeMessage() async {
    return 'Welcome to GolfKakis';
  }

  @override
  Future<List<HomeSmartRebookItem>> fetchSmartRebookItems() async {
    // Fallback-first for the current demo. The endpoint contract is ready above.
    return _fallbackSmartRebookItems;
  }

  @override
  Future<List<HomeHotDealItem>> fetchHotDeals() async {
    // Fallback-first for the current demo. The endpoint contract is ready above.
    return _fallbackHotDealItems;
  }
}

const List<HomeSmartRebookItem> _fallbackSmartRebookItems = [
  HomeSmartRebookItem(
    title: 'Saujana G&CC',
    subtitle: 'Last played Tue, 07:20 AM',
    priceLabel: 'From MYR 52',
  ),
  HomeSmartRebookItem(
    title: 'Kinrara Golf Club',
    subtitle: 'Last played Sat, 07:30 AM',
    priceLabel: 'From MYR 39',
  ),
  HomeSmartRebookItem(
    title: 'Kota Permai',
    subtitle: 'Last played Fri, 08:10 AM',
    priceLabel: 'From MYR 47',
  ),
];

const List<HomeHotDealItem> _fallbackHotDealItems = [
  HomeHotDealItem(
    title: 'Sunrise Tee Time',
    subtitle: 'Green Valley Golf Club',
    priceLabel: 'MYR 49',
    badge: 'Hot',
  ),
  HomeHotDealItem(
    title: 'Weekend Pair Deal',
    subtitle: '2 players at Harbor Links',
    priceLabel: 'MYR 89',
    badge: 'Top',
  ),
];
