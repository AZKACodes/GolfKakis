import 'package:golf_kakis/features/home/course/details/data/course_details_repository.dart';
import 'package:golf_kakis/features/foundation/model/golf_club_model.dart';
import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_contract.dart';

abstract class CourseDetailsViewContract {
  CourseDetailsViewState get viewState;
  Stream<CourseDetailsNavEffect> get navEffects;
  void onUserIntent(CourseDetailsUserIntent intent);
}

class CourseDetailsViewState extends ViewState {
  const CourseDetailsViewState({
    required this.detail,
    required this.isLoading,
    required this.isUsingFallback,
    this.errorSnackbarMessageModel = SnackbarMessageModel.emptyValue,
  }) : super();

  factory CourseDetailsViewState.initial(GolfClubModel club) {
    return CourseDetailsViewState(
      detail: CourseDetailsData(
        club: club,
        distanceLabel: '',
        openSlotsLabel: '',
        greenFeeLabel: '',
        peakLabel: '',
        description: '',
        bestForLabel: '',
        facilityLabels: const <String>[],
        photoUrls: const <String>[],
        weather: null,
        weeklyForecast: const <CourseWeatherForecastItem>[],
        nextSlotLabel: '',
        bookingDateLabel: '',
      ),
      isLoading: false,
      isUsingFallback: false,
    );
  }

  final CourseDetailsData detail;
  final bool isLoading;
  final bool isUsingFallback;
  final SnackbarMessageModel errorSnackbarMessageModel;

  String? get errorMessage => errorSnackbarMessageModel.hasMessage
      ? errorSnackbarMessageModel.message
      : null;

  CourseDetailsViewState copyWith({
    CourseDetailsData? detail,
    bool? isLoading,
    bool? isUsingFallback,
    SnackbarMessageModel? errorSnackbarMessageModel,
    bool clearErrorMessage = false,
  }) {
    return CourseDetailsViewState(
      detail: detail ?? this.detail,
      isLoading: isLoading ?? this.isLoading,
      isUsingFallback: isUsingFallback ?? this.isUsingFallback,
      errorSnackbarMessageModel: clearErrorMessage
          ? SnackbarMessageModel.emptyValue
          : errorSnackbarMessageModel ?? this.errorSnackbarMessageModel,
    );
  }
}

sealed class CourseDetailsUserIntent extends UserIntent {
  const CourseDetailsUserIntent() : super();
}

class OnInit extends CourseDetailsUserIntent {
  const OnInit();
}

class OnRefresh extends CourseDetailsUserIntent {
  const OnRefresh();
}

class OnBackClick extends CourseDetailsUserIntent {
  const OnBackClick();
}

class OnBookNowClick extends CourseDetailsUserIntent {
  const OnBookNowClick();
}

class OnQuickBookClick extends CourseDetailsUserIntent {
  const OnQuickBookClick();
}

sealed class CourseDetailsNavEffect extends NavEffect {
  const CourseDetailsNavEffect() : super();
}

class NavigateBack extends CourseDetailsNavEffect {
  const NavigateBack();
}

class NavigateToBookingSubmission extends CourseDetailsNavEffect {
  const NavigateToBookingSubmission();
}
