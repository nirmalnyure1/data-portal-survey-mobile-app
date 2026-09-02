import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/features/survey/bloc/household_survey_cubit.dart';
import 'package:data_portal_survey/features/survey/bloc/household_survey_state.dart';
import 'package:data_portal_survey/features/survey/constants/household_survey_strings.dart';
import 'package:data_portal_survey/features/survey/constants/survey_theme.dart';
import 'package:data_portal_survey/features/survey/model/household_survey_models.dart';

class SurveyWizardFooter extends StatelessWidget {
  const SurveyWizardFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HouseholdSurveyCubit, HouseholdSurveyState>(
      builder: (context, state) {
        final cubit = context.read<HouseholdSurveyCubit>();
        final lang = cubit.lang;
        final step = state.draft.step;
        final showBack = step > 0;
        final showNext = step < HouseholdSurveyDraft.totalSteps - 1;
        final showSubmit = step == HouseholdSurveyDraft.totalSteps - 1;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            border: const Border(top: BorderSide(color: SurveyTheme.outlineVariant)),
          ),
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
          child: Row(
            children: [
              if (showBack)
                Expanded(
                  child: _FooterButton(
                    label: HouseholdSurveyStrings.tr(lang, 'Back', 'पछाडि'),
                    ghost: true,
                    onTap: cubit.goBack,
                  ),
                ),
              if (showBack) const SizedBox(width: 10),
              if (showNext)
                Expanded(
                  flex: 2,
                  child: _FooterButton(
                    label: HouseholdSurveyStrings.tr(lang, 'Next', 'अर्को'),
                    onTap: cubit.goNext,
                  ),
                ),
              if (showSubmit)
                Expanded(
                  flex: 2,
                  child: _FooterButton(
                    label: HouseholdSurveyStrings.tr(lang, 'Submit', 'पेश गर्नुहोस्'),
                    danger: true,
                    loading: state.isSubmitting,
                    onTap: state.isSubmitting ? null : () => cubit.submit(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _FooterButton extends StatelessWidget {
  const _FooterButton({
    required this.label,
    this.onTap,
    this.ghost = false,
    this.danger = false,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool ghost;
  final bool danger;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final bg = danger
        ? SurveyTheme.secondary
        : ghost
            ? SurveyTheme.surfaceLowest
            : SurveyTheme.primary;
    final fg = ghost ? SurveyTheme.onSurface : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(SurveyTheme.radiusSm),
          border: ghost
              ? Border.all(color: SurveyTheme.outlineVariant)
              : null,
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
      ),
    );
  }
}
