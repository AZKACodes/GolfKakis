import 'package:golf_kakis/features/foundation/model/stay_play_item.dart';

abstract class StayPlayRepository {
  Future<List<StayPlayItem>> onFetchStayPlay();
}
