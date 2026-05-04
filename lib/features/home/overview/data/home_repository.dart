import 'package:golf_kakis/features/foundation/model/home/home_advertisement_item.dart';
import 'package:golf_kakis/features/foundation/model/home/home_hot_deal_item.dart';
import 'package:golf_kakis/features/foundation/model/home/home_smart_rebook_item.dart';
import 'package:golf_kakis/features/foundation/model/home/home_user_details_item.dart';
import 'package:golf_kakis/features/foundation/model/home/home_weather_summary.dart';

abstract class HomeRepository {
  Future<HomeUserDetailsItem?> onFetchUserDetails({required String accessToken});
  Future<List<HomeAdvertisementItem>> onFetchAdvertisementList();
  Future<List<HomeHotDealItem>> onFetchDealsList();
  Future<List<HomeSmartRebookItem>> onFetchSmartRebookItems();
  Future<List<HomeHotDealItem>> onFetchHotDeals();
  Future<HomeWeatherSummary?> onFetchCurrentWeather();
}
