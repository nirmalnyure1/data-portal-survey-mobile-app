import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/features/survey/bloc/household_survey_cubit.dart';
import 'package:data_portal_survey/features/survey/bloc/household_survey_state.dart';
import 'package:data_portal_survey/features/survey/constants/household_survey_strings.dart';
import 'package:data_portal_survey/features/survey/constants/survey_theme.dart';
import 'package:data_portal_survey/features/survey/model/household_survey_models.dart';
import 'package:data_portal_survey/features/survey/ui/widget/survey_form_widgets.dart';

class SurveyWizardHeader extends StatelessWidget {
  const SurveyWizardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HouseholdSurveyCubit, HouseholdSurveyState>(
      builder: (context, state) {
        final cubit = context.read<HouseholdSurveyCubit>();
        final lang = cubit.lang;
        final step = state.draft.step;
        final titles = HouseholdSurveyStrings.stepTitles(lang);
        final progress = ((step + 1) / HouseholdSurveyDraft.totalSteps) * 100;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            border: const Border(bottom: BorderSide(color: SurveyTheme.outlineVariant)),
          ),
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          HouseholdSurveyStrings.tr(
                            lang,
                            'Household Survey',
                            'घरधुरी सर्वेक्षण',
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: SurveyTheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${HouseholdSurveyStrings.tr(lang, 'Step', 'चरण')} ${step + 1} ${HouseholdSurveyStrings.tr(lang, 'of', 'मध्ये')} ${HouseholdSurveyDraft.totalSteps} — ${titles[step]}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: SurveyTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (state.draft.draftSavedAt != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.check, size: 14, color: Color(0xFF2E7D32)),
                          const SizedBox(width: 4),
                          Text(
                            HouseholdSurveyStrings.tr(lang, 'Draft saved', 'ड्राफ्ट सुरक्षित'),
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: SurveyTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: SurveyTheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Row(
                      children: [
                        SurveyLangPill(
                          label: 'EN',
                          selected: lang == SurveyLang.en,
                          onTap: () => cubit.setLang(SurveyLang.en),
                        ),
                        SurveyLangPill(
                          label: 'NE',
                          selected: lang == SurveyLang.ne,
                          onTap: () => cubit.setLang(SurveyLang.ne),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: progress / 100,
                  minHeight: 4,
                  backgroundColor: SurveyTheme.outlineVariant,
                  color: SurveyTheme.primary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
