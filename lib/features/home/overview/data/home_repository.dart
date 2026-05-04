import 'package:golf_kakis/features/foundation/model/home/home_hot_deal_item.dart';
import 'package:golf_kakis/features/foundation/model/home/home_quick_book_item.dart';
import 'package:golf_kakis/features/foundation/model/home/home_smart_rebook_item.dart';
import 'package:golf_kakis/features/foundation/model/home/home_weather_summary.dart';

abstract class HomeRepository {
  Future<String> onFetchWelcomeMessage();
  Future<List<HomeSmartRebookItem>> onFetchSmartRebookItems();
  Future<List<HomeHotDealItem>> onFetchHotDeals();
  Future<List<HomeQuickBookItem>> onFetchQuickBookItems();
  Future<HomeWeatherSummary?> onFetchCurrentWeather();
}
