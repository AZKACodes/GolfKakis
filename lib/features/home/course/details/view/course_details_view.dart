import 'package:flutter/material.dart';

import '../viewmodel/course_details_view_contract.dart';
import 'widgets/item/course_details_fullscreen_loading_state.dart';
import 'widgets/section/course_details_extra_info_section.dart';
import 'widgets/section/course_details_header_section.dart';
import 'widgets/section/course_details_map_section.dart';
import 'widgets/section/course_details_weather_section.dart';

class CourseDetailsView extends StatelessWidget {
  const CourseDetailsView({
    required this.state,
    required this.onRefresh,
    required this.onDirectionsTap,
    super.key,
  });

  final CourseDetailsViewState state;
  final Future<void> Function() onRefresh;
  final VoidCallback onDirectionsTap;

  @override
  Widget build(BuildContext context) {
    final detail = state.detail;
    final club = detail.club;

    if (state.isLoading) {
      return const CourseDetailsFullscreenLoadingState();
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
            child: CourseDetailsHeaderSection(
              clubName: club.name,
              address: club.address,
              distanceLabel: detail.distanceLabel,
              openSlotsLabel: detail.openSlotsLabel,
              weekdayStartingPriceLabel: detail.greenFeeLabel,
              weekendStartingPriceLabel: detail.greenFeeLabel,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CourseDetailsWeatherSection(
              weather: detail.weather,
              weatherForecast: detail.weeklyForecast,
            ),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CourseDetailsExtraInfoSection(
              courseName: club.name,
              description: detail.description,
              facilityLabels: detail.facilityLabels,
              photoUrls: detail.photoUrls,
            ),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CourseDetailsMapSection(
              courseName: club.name,
              address: club.address,
              latitude: club.latitude,
              longitude: club.longitude,
              onDirectionsTap: onDirectionsTap,
            ),
          ),
        ],
      ),
    );
  }
}
