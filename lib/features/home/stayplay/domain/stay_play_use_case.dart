import 'package:golf_kakis/features/foundation/model/stay_play_item.dart';

class StayPlayResult {
  const StayPlayResult({required this.items});

  final List<StayPlayItem> items;
}

abstract class StayPlayUseCase {
  Future<StayPlayResult> onFetchStayPlay();
}
