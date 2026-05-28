import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:golf_kakis/features/booking/submission/slot/booking_submission_slot_page.dart';
import 'package:golf_kakis/features/foundation/model/golf_club_model.dart';
import 'package:url_launcher/url_launcher.dart';

import 'data/local_course_display_content.dart';
import 'domain/course_details_use_case_impl.dart';
import 'view/course_details_view.dart';
import 'view/widgets/section/course_details_bottom_bar_section.dart';
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
            builder: (_) => BookingSubmissionSlotPage(
              initialClubSlug: widget.clubSlug,
              initialClub: _viewModel.viewState.detail.club,
            ),
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
          extendBody: true,
          body: CourseDetailsView(
            state: _viewModel.viewState,
            onRefresh: () async => _viewModel.onUserIntent(const OnRefresh()),
            onBackTap: () => _viewModel.onUserIntent(const OnBackClick()),
            onDirectionsTap: () => _openDirections(club),
          ),
          bottomNavigationBar: CourseDetailsBottomBarSection(
            onBookNowTap: () => _viewModel.onUserIntent(const OnBookNowClick()),
            onCallTap: _showContactNumberUnavailable,
            onDirectionsTap: () => _openDirections(club),
          ),
        );
      },
    );
  }

  void _showContactNumberUnavailable() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Golf club contact number will be available soon.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _openDirections(GolfClubModel club) async {
    final fallbackContent = localCourseDisplayContent[club.slug];
    final latitude = club.latitude ?? fallbackContent?.latitude;
    final longitude = club.longitude ?? fallbackContent?.longitude;
    final addressQuery = Uri.encodeComponent(
      club.address.trim().isEmpty ? club.name : '${club.name}, ${club.address}',
    );
    final candidateUris = <Uri>[
      if (latitude != null && longitude != null)
        ..._navigationUris(
          latitude: latitude,
          longitude: longitude,
          addressQuery: addressQuery,
        ),
      Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$addressQuery',
      ),
    ];

    for (final uri in candidateUris) {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        return;
      }
    }
  }

  List<Uri> _navigationUris({
    required double latitude,
    required double longitude,
    required String addressQuery,
  }) {
    final coordinatesQuery = '$latitude,$longitude';

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return <Uri>[
          Uri.parse('geo:0,0?q=$coordinatesQuery($addressQuery)'),
          Uri.parse('google.navigation:q=$coordinatesQuery'),
          Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=$coordinatesQuery',
          ),
        ];
      case TargetPlatform.iOS:
        return <Uri>[
          Uri.parse(
            'http://maps.apple.com/?ll=$coordinatesQuery&q=$addressQuery',
          ),
          Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=$coordinatesQuery',
          ),
        ];
      default:
        return <Uri>[
          Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=$coordinatesQuery',
          ),
        ];
    }
  }
}
