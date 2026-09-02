import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/features/survey/bloc/household_survey_cubit.dart';
import 'package:data_portal_survey/features/survey/bloc/household_survey_state.dart';
import 'package:data_portal_survey/features/survey/constants/survey_theme.dart';
import 'package:data_portal_survey/features/survey/resource/household_survey_repository.dart';
import 'package:data_portal_survey/features/survey/ui/widget/household_survey_steps.dart';
import 'package:data_portal_survey/features/survey/ui/widget/household_survey_success_view.dart';
import 'package:data_portal_survey/features/survey/ui/widget/household_survey_wizard_footer.dart';
import 'package:data_portal_survey/features/survey/ui/widget/household_survey_wizard_header.dart';

@RoutePage()
class HouseholdSurveyScreen extends StatelessWidget {
  const HouseholdSurveyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = HouseholdSurveyCubit(
          surveyRepository: context.read<HouseholdSurveyRepository>(),
        );
        cubit.load();
        return cubit;
      },
      child: const _HouseholdSurveyView(),
    );
  }
}

class _HouseholdSurveyView extends StatelessWidget {
  const _HouseholdSurveyView();

  Widget _stepWidget(int step) {
    switch (step) {
      case 0:
        return const BasicInfoStep();
      case 1:
        return const HouseholdHeadStep();
      case 2:
        return const MembersStep();
      case 3:
        return const CropsStep();
      case 4:
        return const LivelihoodStep();
      case 5:
        return const DocumentsStep();
      case 6:
        return const ReviewStep();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SurveyTheme.surface,
      body: BlocBuilder<HouseholdSurveyCubit, HouseholdSurveyState>(
        builder: (context, state) {
          if (state.draft.submitted) {
            return const SafeArea(child: HouseholdSurveySuccessView());
          }

          return Column(
            children: [
              const SafeArea(bottom: false, child: HouseholdSurveyWizardHeader()),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 22, 18, 28),
                  child: _stepWidget(state.draft.step),
                ),
              ),
              const SafeArea(top: false, child: HouseholdSurveyWizardFooter()),
            ],
          );
        },
      ),
    );
  }
}
