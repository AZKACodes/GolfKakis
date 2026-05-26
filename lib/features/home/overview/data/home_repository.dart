import 'package:golf_kakis/features/foundation/model/home_announcement_item.dart';
import 'package:golf_kakis/features/foundation/model/home_hot_deal_item.dart';
import 'package:golf_kakis/features/foundation/model/home_smart_rebook_item.dart';
import 'package:golf_kakis/features/foundation/model/home_user_details_item.dart';
import 'package:golf_kakis/features/foundation/model/home_weather_summary.dart';

abstract class HomeRepository {
  Future<HomeUserDetailsItem?> onFetchUserDetails({required String accessToken});
  Future<List<HomeAnnouncementItem>> onFetchAnnouncementList();
  Future<List<HomeHotDealItem>> onFetchDealsList();
  Future<List<HomeSmartRebookItem>> onFetchSmartRebookItems();
  Future<List<HomeHotDealItem>> onFetchHotDeals();
  Future<HomeWeatherSummary?> onFetchCurrentWeather();
}
