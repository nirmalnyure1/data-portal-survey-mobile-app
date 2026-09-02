import 'package:equatable/equatable.dart';
import 'package:data_portal_survey/features/survey/model/survey_form_models.dart';

class SurveyListState extends Equatable {
  final bool isLoading;
  final List<SurveyFormSummary> forms;
  final Set<String> draftFormIds;
  final String? error;

  const SurveyListState({
    this.isLoading = true,
    this.forms = const [],
    this.draftFormIds = const {},
    this.error,
  });

  SurveyListState copyWith({
    bool? isLoading,
    List<SurveyFormSummary>? forms,
    Set<String>? draftFormIds,
    String? error,
    bool clearError = false,
  }) {
    return SurveyListState(
      isLoading: isLoading ?? this.isLoading,
      forms: forms ?? this.forms,
      draftFormIds: draftFormIds ?? this.draftFormIds,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [isLoading, forms, draftFormIds, error];
}
