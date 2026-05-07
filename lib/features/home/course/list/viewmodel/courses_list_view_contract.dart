import 'package:golf_kakis/features/foundation/default_values.dart';
import 'package:golf_kakis/features/foundation/model/booking/golf_club_model.dart';
import 'package:golf_kakis/features/foundation/model/home/courses_list_item_view_data.dart';
import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_contract.dart';

abstract class CoursesListViewContract {
  CoursesListViewState get viewState;
  Stream<CoursesListNavEffect> get navEffects;
  void onUserIntent(CoursesListUserIntent intent);
}

// ------ View State ------

sealed class CoursesListViewState implements ViewState {
  const CoursesListViewState();
}

class CoursesListDataLoaded extends CoursesListViewState {
  const CoursesListDataLoaded({
    this.courses = const <CoursesListItemViewData>[],
    this.searchQuery = emptyString,
    this.isLocationSortActive = false,
    this.isLoading = emptyBool,
    this.errorSnackbarMessageModel = SnackbarMessageModel.emptyValue,
  }) : super();

  static const initial = CoursesListDataLoaded(isLoading: true);

  final List<CoursesListItemViewData> courses;
  final String searchQuery;
  final bool isLocationSortActive;
  final bool isLoading;
  final SnackbarMessageModel errorSnackbarMessageModel;

  String? get errorMessage => errorSnackbarMessageModel.hasMessage
      ? errorSnackbarMessageModel.message
      : null;

  CoursesListDataLoaded copyWith({
    List<CoursesListItemViewData>? courses,
    String? searchQuery,
    bool? isLocationSortActive,
    bool? isLoading,
    SnackbarMessageModel? errorSnackbarMessageModel,
    bool clearErrorMessage = false,
  }) {
    return CoursesListDataLoaded(
      courses: courses ?? this.courses,
      searchQuery: searchQuery ?? this.searchQuery,
      isLocationSortActive: isLocationSortActive ?? this.isLocationSortActive,
      isLoading: isLoading ?? this.isLoading,
      errorSnackbarMessageModel: clearErrorMessage
          ? SnackbarMessageModel.emptyValue
          : (errorSnackbarMessageModel ?? this.errorSnackbarMessageModel),
    );
  }
}

// ------ UserIntent ------

sealed class CoursesListUserIntent implements UserIntent {
  const CoursesListUserIntent();
}

class OnInitCoursesList extends CoursesListUserIntent {
  const OnInitCoursesList();
}

class OnRefreshCoursesList extends CoursesListUserIntent {
  const OnRefreshCoursesList();
}

class OnSearchCoursesQueryChanged extends CoursesListUserIntent {
  const OnSearchCoursesQueryChanged(this.query);

  final String query;
}

class OnSortCoursesByLocationClick extends CoursesListUserIntent {
  const OnSortCoursesByLocationClick();
}

class OnCourseDetailsClick extends CoursesListUserIntent {
  const OnCourseDetailsClick(this.courseSlug);

  final String courseSlug;
}

// ------ NavEffect ------

sealed class CoursesListNavEffect implements NavEffect {
  const CoursesListNavEffect();
}

class NavigateToCourseDetails extends CoursesListNavEffect {
  const NavigateToCourseDetails(this.club);

  final GolfClubModel club;
}
