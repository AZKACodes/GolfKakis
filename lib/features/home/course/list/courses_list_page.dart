import 'dart:async';

import 'package:flutter/material.dart';
import 'package:golf_kakis/features/home/course/details/course_details_page.dart';
import 'package:golf_kakis/features/home/course/list/domain/courses_list_use_case_impl.dart';

import 'view/courses_list_view.dart';
import 'viewmodel/courses_list_view_contract.dart';
import 'viewmodel/courses_list_view_model.dart';

class CoursesListPage extends StatefulWidget {
  const CoursesListPage({super.key});

  @override
  State<CoursesListPage> createState() => _CoursesListPageState();
}

class _CoursesListPageState extends State<CoursesListPage> {
  late final CoursesListViewModel _viewModel;
  StreamSubscription<CoursesListNavEffect>? _navEffectSubscription;

  @override
  void initState() {
    super.initState();

    _viewModel = CoursesListViewModel(
      useCase: CoursesListUseCaseImpl.create(),
    );
    _navEffectSubscription = _viewModel.navEffects.listen(_handleNavEffect);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _viewModel.onUserIntent(const OnInitCoursesList());
    });
  }

  @override
  void dispose() {
    _navEffectSubscription?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  void _handleNavEffect(CoursesListNavEffect effect) {
    if (!mounted) {
      return;
    }

    switch (effect) {
      case NavigateToCourseDetails():
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => CourseDetailsPage(
              clubSlug: effect.club.slug,
              initialClub: effect.club,
            ),
          ),
        );
    }
  }

  Future<void> _handleRefresh() async {
    _viewModel.onUserIntent(const OnRefreshCoursesList());
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Courses')),
          body: RefreshIndicator(
            onRefresh: _handleRefresh,
            child: CoursesListView(
              state: _viewModel.viewState,
              onUserIntent: _viewModel.onUserIntent,
            ),
          ),
        );
      },
    );
  }
}
