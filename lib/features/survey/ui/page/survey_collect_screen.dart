import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/features/survey/bloc/survey_collect_cubit.dart';
import 'package:data_portal_survey/features/survey/bloc/survey_collect_state.dart';
import 'package:data_portal_survey/features/survey/constants/survey_theme.dart';
import 'package:data_portal_survey/features/survey/resource/survey_repository.dart';
import 'package:data_portal_survey/features/survey/ui/widget/survey_section_view.dart';
import 'package:data_portal_survey/features/survey/ui/widget/survey_success_view.dart';
import 'package:data_portal_survey/features/survey/ui/widget/survey_wizard_footer.dart';
import 'package:data_portal_survey/features/survey/ui/widget/survey_wizard_header.dart';

@RoutePage()
class SurveyCollectScreen extends StatelessWidget {
  const SurveyCollectScreen({super.key, required this.formId});

  final String formId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = SurveyCollectCubit(
          formId: formId,
          surveyRepository: context.read<SurveyRepository>(),
        );
        cubit.load();
        return cubit;
      },
      child: const _SurveyCollectView(),
    );
  }
}

class _SurveyCollectView extends StatelessWidget {
  const _SurveyCollectView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SurveyTheme.surface,
      body: BlocBuilder<SurveyCollectCubit, SurveyCollectState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.loadError != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.loadError!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<SurveyCollectCubit>().load(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state.submitted) {
            return const SafeArea(child: SurveySuccessView());
          }

          final section = state.currentSection;
          if (section == null) {
            return const Center(child: Text('This form has no sections.'));
          }

          return Column(
            children: [
              const SafeArea(bottom: false, child: SurveyWizardHeader()),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.title.resolve(state.locale),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: SurveyTheme.onSurface,
                        ),
                      ),
                      if (section.description != null &&
                          section.description!.resolve(state.locale).isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          section.description!.resolve(state.locale),
                          style: const TextStyle(
                            fontSize: 13.5,
                            height: 1.4,
                            color: SurveyTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      SurveySectionView(section: section),
                    ],
                  ),
                ),
              ),
              const SafeArea(top: false, child: SurveyWizardFooter()),
            ],
          );
        },
      ),
    );
  }
}
