abstract class BookingSubmissionViewContract {
  BookingSubmissionViewState get viewState;
  Stream<BookingSubmissionNavEffect> get navEffects;
  void onUserIntent(BookingSubmissionUserIntent intent);
}

class BookingSubmissionViewState {
  const BookingSubmissionViewState();

  static const initial = BookingSubmissionViewState();
}

sealed class BookingSubmissionUserIntent {
  const BookingSubmissionUserIntent();
}

class BookingSubmissionBackTappedIntent extends BookingSubmissionUserIntent {
  const BookingSubmissionBackTappedIntent();
}

sealed class BookingSubmissionNavEffect {
  const BookingSubmissionNavEffect();
}

class BookingSubmissionPopNavEffect extends BookingSubmissionNavEffect {
  const BookingSubmissionPopNavEffect();
}
