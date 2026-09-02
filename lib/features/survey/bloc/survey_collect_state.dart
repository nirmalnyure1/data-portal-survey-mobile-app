import 'package:equatable/equatable.dart';
import 'package:data_portal_survey/features/survey/model/survey_form_models.dart';

class SurveyCollectState extends Equatable {
  final SurveyForm? form;
  final bool isLoading;
  final String? loadError;
  final String locale;
  final Map<String, String> answers;
  final Map<String, int> repeatCounts;
  final Map<String, int> repeatActive;
  final Map<String, int> groupRepeatCounts;
  final Map<String, int> groupRepeatActive;
  final Map<String, String> fieldErrors;
  final int step;
  final bool isSubmitting;
  final bool submitted;
  final String? responseId;
  final int? draftSavedAt;
  final String? submitError;

  const SurveyCollectState({
    this.form,
    this.isLoading = true,
    this.loadError,
    this.locale = 'en',
    this.answers = const {},
    this.repeatCounts = const {},
    this.repeatActive = const {},
    this.groupRepeatCounts = const {},
    this.groupRepeatActive = const {},
    this.fieldErrors = const {},
    this.step = 0,
    this.isSubmitting = false,
    this.submitted = false,
    this.responseId,
    this.draftSavedAt,
    this.submitError,
  });

  List<SurveySection> get sections => form?.sections ?? const [];

  SurveySection? get currentSection =>
      sections.isEmpty || step >= sections.length ? null : sections[step];

  bool get isLast => sections.isEmpty || step >= sections.length - 1;

  double get progress =>
      sections.isEmpty ? 0 : (step + 1) / sections.length;

  SurveyCollectState copyWith({
    SurveyForm? form,
    bool? isLoading,
    String? loadError,
    String? locale,
    Map<String, String>? answers,
    Map<String, int>? repeatCounts,
    Map<String, int>? repeatActive,
    Map<String, int>? groupRepeatCounts,
    Map<String, int>? groupRepeatActive,
    Map<String, String>? fieldErrors,
    int? step,
    bool? isSubmitting,
    bool? submitted,
    String? responseId,
    int? draftSavedAt,
    String? submitError,
    bool clearLoadError = false,
    bool clearFieldErrors = false,
    bool clearSubmitError = false,
    bool clearResponseId = false,
  }) {
    return SurveyCollectState(
      form: form ?? this.form,
      isLoading: isLoading ?? this.isLoading,
      loadError: clearLoadError ? null : loadError ?? this.loadError,
      locale: locale ?? this.locale,
      answers: answers ?? this.answers,
      repeatCounts: repeatCounts ?? this.repeatCounts,
      repeatActive: repeatActive ?? this.repeatActive,
      groupRepeatCounts: groupRepeatCounts ?? this.groupRepeatCounts,
      groupRepeatActive: groupRepeatActive ?? this.groupRepeatActive,
      fieldErrors: clearFieldErrors ? {} : fieldErrors ?? this.fieldErrors,
      step: step ?? this.step,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitted: submitted ?? this.submitted,
      responseId: clearResponseId ? null : responseId ?? this.responseId,
      draftSavedAt: draftSavedAt ?? this.draftSavedAt,
      submitError: clearSubmitError ? null : submitError ?? this.submitError,
    );
  }

  @override
  List<Object?> get props => [
        form?.id,
        isLoading,
        loadError,
        locale,
        answers,
        repeatCounts,
        repeatActive,
        groupRepeatCounts,
        groupRepeatActive,
        fieldErrors,
        step,
        isSubmitting,
        submitted,
        responseId,
        draftSavedAt,
        submitError,
      ];
}
