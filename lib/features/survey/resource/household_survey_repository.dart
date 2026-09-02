import 'dart:math';

import 'package:data_portal_survey/common/config/app_config.dart';
import 'package:data_portal_survey/common/http/api_provider.dart';
import 'package:data_portal_survey/features/survey/model/household_survey_models.dart';
import 'package:data_portal_survey/features/survey/service/household_survey_draft_store.dart';

class HouseholdSurveyRepository {
  HouseholdSurveyRepository({required ApiProvider apiProvider})
      : _apiProvider = apiProvider;

  final ApiProvider _apiProvider;

  Future<bool> hasActiveDraft() => HouseholdSurveyDraftStore.hasDraft();

  Future<List<HouseholdSurveySubmission>> getSubmissions() =>
      HouseholdSurveyDraftStore.loadSubmissions();

  Future<String> submit(HouseholdSurveyDraft draft) async {
    final responseId = _generateResponseId();
    final submission = HouseholdSurveySubmission(
      responseId: responseId,
      submittedAt: DateTime.now().millisecondsSinceEpoch,
      draft: draft.copyWith(responseId: responseId, submitted: true),
    );

    if (AppConfig.baseUrl.isNotEmpty) {
      try {
        await _apiProvider.post('survey/household', {
          'responseId': responseId,
          'data': draft.toJson(),
        });
      } catch (_) {}
    }

    await HouseholdSurveyDraftStore.addSubmission(submission);
    return responseId;
  }

  String _generateResponseId() {
    final code = 1000 + Random().nextInt(9000);
    return 'HH-2026-$code';
  }
}
