import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/booking/submission/slot/booking_submission_slot_page.dart';
import 'package:golf_kakis/features/foundation/model/booking/golf_club_model.dart';
import 'package:url_launcher/url_launcher.dart';

import 'data/local_course_display_content.dart';
import 'domain/course_details_use_case_impl.dart';
import 'view/course_details_view.dart';
import 'viewmodel/course_details_view_contract.dart';
import 'viewmodel/course_details_view_model.dart';

class CourseDetailsPage extends StatefulWidget {
  const CourseDetailsPage({
    required this.clubSlug,
    this.initialClub,
    super.key,
  });

  final String clubSlug;
  final GolfClubModel? initialClub;

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  late final CourseDetailsViewModel _viewModel;
  StreamSubscription<CourseDetailsNavEffect>? _navEffectSubscription;

  @override
  void initState() {
    super.initState();
    _viewModel = CourseDetailsViewModel(
      clubSlug: widget.clubSlug,
      initialClub: widget.initialClub,
      useCase: const CourseDetailsUseCaseImpl(),
    );
    _navEffectSubscription = _viewModel.navEffects.listen((effect) {
      if (effect is NavigateBack) {
        if (!mounted) {
          return;
        }
        Navigator.of(context).pop();
      }

      if (effect is NavigateToBookingSubmission) {
        if (!mounted) {
          return;
        }
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                BookingSubmissionSlotPage(initialClubSlug: widget.clubSlug),
          ),
        );
      }
    });
    _viewModel.onUserIntent(const OnInit());
  }

  @override
  void dispose() {
    _navEffectSubscription?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final club = _viewModel.viewState.detail.club;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Course Details'),
            leading: IconButton(
              onPressed: () => _viewModel.onUserIntent(const OnBackClick()),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: SafeArea(
            child: CourseDetailsView(
              state: _viewModel.viewState,
              onRefresh: () async => _viewModel.onUserIntent(const OnRefresh()),
              onDirectionsClick: () => _openDirections(club),
            ),
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: FilledButton.icon(
              onPressed: () => _viewModel.onUserIntent(const OnBookNowClick()),
              icon: const Icon(Icons.flash_on_outlined),
              label: const Text('Quick Book'),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openDirections(GolfClubModel club) async {
    final fallbackContent = localCourseDisplayContent[club.slug];
    final latitude = club.latitude ?? fallbackContent?.latitude;
    final longitude = club.longitude ?? fallbackContent?.longitude;

    final coordinatesUri = (latitude != null && longitude != null)
        ? Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
          )
        : null;
    final addressQuery = Uri.encodeComponent(
      club.address.trim().isEmpty ? club.name : '${club.name}, ${club.address}',
    );
    final addressUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$addressQuery',
    );

    if (coordinatesUri != null && await launchUrl(coordinatesUri)) {
      return;
    }

    await launchUrl(addressUri);
  }
}
