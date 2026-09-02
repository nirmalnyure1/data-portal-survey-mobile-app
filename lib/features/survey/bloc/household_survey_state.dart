import 'package:equatable/equatable.dart';
import 'package:data_portal_survey/features/survey/model/household_survey_models.dart';

class HouseholdSurveyState extends Equatable {
  final HouseholdSurveyDraft draft;
  final Map<String, String> errors;
  final bool isSubmitting;

  const HouseholdSurveyState({
    required this.draft,
    this.errors = {},
    this.isSubmitting = false,
  });

  HouseholdSurveyState copyWith({
    HouseholdSurveyDraft? draft,
    Map<String, String>? errors,
    bool? isSubmitting,
    bool clearErrors = false,
  }) {
    return HouseholdSurveyState(
      draft: draft ?? this.draft,
      errors: clearErrors ? {} : errors ?? this.errors,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [draft, errors, isSubmitting];
}
