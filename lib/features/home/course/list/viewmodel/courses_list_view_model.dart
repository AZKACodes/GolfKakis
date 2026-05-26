import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:golf_kakis/features/foundation/model/golf_club_model.dart';
import 'package:golf_kakis/features/foundation/model/courses_list_item_view_data.dart';
import 'package:golf_kakis/features/foundation/model/snackbar_message_model.dart';
import 'package:golf_kakis/features/foundation/util/string_util.dart';
import 'package:golf_kakis/features/foundation/viewmodel/mvi_view_model.dart';

import '../domain/courses_list_use_case.dart';
import 'courses_list_view_contract.dart';

class CoursesListViewModel
    extends
        MviViewModel<
          CoursesListUserIntent,
          CoursesListViewState,
          CoursesListNavEffect
        >
    implements CoursesListViewContract {
  CoursesListViewModel({required CoursesListUseCase useCase})
    : _useCase = useCase;

  final CoursesListUseCase _useCase;
  Map<String, GolfClubModel> _clubLookupBySlug = const <String, GolfClubModel>{};
  List<CoursesListItemViewData> _allCourses = const <CoursesListItemViewData>[];
  Position? _currentPosition;

  @override
  CoursesListViewState createInitialState() => CoursesListDataLoaded.initial;

  @override
  FutureOr<void> handleIntent(CoursesListUserIntent intent) {
    switch (intent) {
      case OnInitCoursesList():
        return _loadCourses();
      case OnRefreshCoursesList():
        return _loadCourses();
      case OnSearchCoursesQueryChanged():
        return _applySearch(intent.query);
      case OnSortCoursesByLocationClick():
        return _sortCoursesByCurrentLocation();
      case OnCourseDetailsClick():
        final club = _clubLookupBySlug[intent.courseSlug];
        if (club != null) {
          sendNavEffect(() => NavigateToCourseDetails(club));
        }
    }
  }

  CoursesListDataLoaded get _currentDataState {
    return switch (currentState) {
      CoursesListDataLoaded() => currentState as CoursesListDataLoaded,
    };
  }

  Future<void> _loadCourses() async {
    emitViewState(
      (_) =>
          _currentDataState.copyWith(isLoading: true, clearErrorMessage: true),
    );

    try {
      final result = await _useCase.onFetchCourseList();
      _clubLookupBySlug = <String, GolfClubModel>{
        for (final club in result.clubs) club.slug: club,
      };
      _allCourses = result.clubs.map(_mapCourse).toList();
      emitViewState(
        (_) => _currentDataState.copyWith(
          courses: _presentCourses(
            query: _currentDataState.searchQuery,
            isLocationSortActive: _currentDataState.isLocationSortActive,
          ),
          isLoading: false,
          clearErrorMessage: true,
        ),
      );
    } catch (_) {
      emitViewState(
        (_) => _currentDataState.copyWith(
          isLoading: false,
          errorSnackbarMessageModel: const SnackbarMessageModel(
            message:
                'Unable to load golf clubs. Pull to refresh and try again.',
          ),
        ),
      );
    }
  }

  Future<void> _applySearch(String query) async {
    emitViewState(
      (_) => _currentDataState.copyWith(
        searchQuery: query,
        courses: _presentCourses(
          query: query,
          isLocationSortActive: _currentDataState.isLocationSortActive,
        ),
      ),
    );
  }

  Future<void> _sortCoursesByCurrentLocation() async {
    if (_currentDataState.isLocationSortActive) {
      emitViewState(
        (_) => _currentDataState.copyWith(
          isLocationSortActive: false,
          courses: _presentCourses(
            query: _currentDataState.searchQuery,
            isLocationSortActive: false,
          ),
        ),
      );
      return;
    }

    final position = await _resolveCurrentPosition();
    if (position == null) {
      return;
    }

    _currentPosition = position;
    emitViewState(
      (_) => _currentDataState.copyWith(
        isLocationSortActive: true,
        courses: _presentCourses(
          query: _currentDataState.searchQuery,
          isLocationSortActive: true,
        ),
      ),
    );
  }

  List<CoursesListItemViewData> _presentCourses({
    required String query,
    required bool isLocationSortActive,
  }) {
    final filtered = _filterCourses(source: _allCourses, query: query);
    if (!isLocationSortActive || _currentPosition == null) {
      return filtered;
    }

    final sortable = filtered.map((course) {
      final club = _clubLookupBySlug[course.slug];
      final distanceMeters = club == null || club.latitude == null || club.longitude == null
          ? null
          : Geolocator.distanceBetween(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              club.latitude!,
              club.longitude!,
            );
      return (course: course, distanceMeters: distanceMeters);
    }).toList();

    sortable.sort((left, right) {
      final leftDistance = left.distanceMeters;
      final rightDistance = right.distanceMeters;
      if (leftDistance == null && rightDistance == null) {
        return left.course.name.compareTo(right.course.name);
      }
      if (leftDistance == null) {
        return 1;
      }
      if (rightDistance == null) {
        return -1;
      }
      return leftDistance.compareTo(rightDistance);
    });

    return sortable
        .map(
          (entry) => CoursesListItemViewData(
            slug: entry.course.slug,
            name: entry.course.name,
            address: entry.course.address,
            holesLabel: entry.course.holesLabel,
            facilities: entry.course.facilities,
            isEnabled: entry.course.isEnabled,
            distanceLabel: _formatDistance(entry.distanceMeters),
          ),
        )
        .toList();
  }

  List<CoursesListItemViewData> _filterCourses({
    required List<CoursesListItemViewData> source,
    required String query,
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return source;
    }

    return source.where((course) {
      return course.name.toLowerCase().contains(normalizedQuery) ||
          course.address.toLowerCase().contains(normalizedQuery) ||
          course.facilities.any(
            (facility) =>
                facility.title.toLowerCase().contains(normalizedQuery) ||
                facility.facilityType.toLowerCase().contains(normalizedQuery),
          );
    }).toList();
  }

  CoursesListItemViewData _mapCourse(GolfClubModel club) {
    return CoursesListItemViewData(
      slug: club.slug,
      name: club.name,
      address: club.address,
      holesLabel: '${club.noOfHoles} holes',
      facilities: _mapFacilities(club),
      isEnabled: club.isEnabled,
    );
  }

  Future<Position?> _resolveCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      return Geolocator.getCurrentPosition();
    } on MissingPluginException {
      return null;
    } catch (_) {
      return null;
    }
  }

  String? _formatDistance(double? distanceMeters) {
    if (distanceMeters == null) {
      return null;
    }

    final distanceKm = distanceMeters / 1000;
    if (distanceKm < 10) {
      return '${distanceKm.toStringAsFixed(1)} km away';
    }
    return '${distanceKm.toStringAsFixed(0)} km away';
  }

  List<CoursesListFacilityItemViewData> _mapFacilities(GolfClubModel club) {
    if (club.facilities.isNotEmpty) {
      return club.facilities
          .map(
            (facility) => CoursesListFacilityItemViewData(
              facilityType: facility.facilityType,
              title: facility.title.isNotEmpty
                  ? facility.title
                  : StringUtil.formatSentenceLabel(
                      facility.facilityType,
                      fallback: 'Facility',
                    ),
            ),
          )
          .toList();
    }

    final fallback = <CoursesListFacilityItemViewData>[
      CoursesListFacilityItemViewData(
        facilityType:
            club.supportsNineHoles || club.supportedNines.isNotEmpty
            ? 'supports_nine_holes'
            : 'routing_18_holes',
        title: club.supportsNineHoles || club.supportedNines.isNotEmpty
            ? 'Supports 9 holes'
            : '18-hole routing',
      ),
      CoursesListFacilityItemViewData(
        facilityType: club.paymentMethods.isEmpty
            ? 'payment_at_club'
            : club.paymentMethods.first,
        title: club.paymentMethods.isEmpty
            ? 'Payment at club'
            : StringUtil.formatSentenceLabel(
                club.paymentMethods.first,
                fallback: 'Payment at club',
              ),
      ),
      if (club.buggyPolicy.trim().isNotEmpty)
        CoursesListFacilityItemViewData(
          facilityType: club.buggyPolicy,
          title: StringUtil.formatSentenceLabel(
            club.buggyPolicy,
            fallback: 'Buggy policy',
          ),
        ),
    ];

    return fallback;
  }
}
