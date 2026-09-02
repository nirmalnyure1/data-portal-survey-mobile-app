import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/features/survey/bloc/household_survey_cubit.dart';
import 'package:data_portal_survey/features/survey/constants/survey_strings.dart';
import 'package:data_portal_survey/features/survey/constants/survey_theme.dart';

class HouseholdSurveySuccessView extends StatelessWidget {
  const HouseholdSurveySuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HouseholdSurveyCubit>();
    final lang = cubit.lang;
    final responseId = cubit.state.draft.responseId ?? '';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: SurveyTheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 34),
            ),
            const SizedBox(height: 12),
            Text(
              SurveyStrings.tr(lang, 'Survey submitted', 'सर्वेक्षण पेश गरियो'),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: SurveyTheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              SurveyStrings.tr(
                lang,
                'Thank you. Your response has been recorded successfully.',
                'धन्यवाद। तपाईंको प्रतिक्रिया सफलतापूर्वक रेकर्ड गरिएको छ।',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                color: SurveyTheme.onSurfaceVariant,
              ),
            ),
            if (responseId.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: SurveyTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(SurveyTheme.radius),
                ),
                child: Text(
                  responseId,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.04,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: cubit.restart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SurveyTheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SurveyTheme.radiusSm),
                  ),
                ),
                child: Text(
                  SurveyStrings.tr(lang, 'Start new survey', 'नयाँ सर्वेक्षण सुरु गर्नुहोस्'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
