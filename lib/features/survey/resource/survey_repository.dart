import 'dart:math';

import 'package:data_portal_survey/common/config/app_config.dart';
import 'package:data_portal_survey/common/http/api_provider.dart';
import 'package:data_portal_survey/features/survey/model/household_survey_models.dart';
import 'package:data_portal_survey/features/survey/resource/survey_api_provider.dart';
import 'package:data_portal_survey/features/survey/service/survey_draft_store.dart';

class SurveyRepository {
  SurveyRepository({required ApiProvider apiProvider}) {
    _apiProvider = SurveyApiProvider(apiProvider: apiProvider);
  }

  late final SurveyApiProvider _apiProvider;

  Future<bool> hasActiveDraft() => SurveyDraftStore.hasDraft();

  Future<List<HouseholdSurveySubmission>> getSubmissions() =>
      SurveyDraftStore.loadSubmissions();

  Future<String> submit(HouseholdSurveyDraft draft) async {
    final responseId = _generateResponseId();
    final submission = HouseholdSurveySubmission(
      responseId: responseId,
      submittedAt: DateTime.now().millisecondsSinceEpoch,
      draft: draft.copyWith(responseId: responseId, submitted: true),
    );

    if (AppConfig.baseUrl.isNotEmpty) {
      try {
        await _apiProvider.submitHousehold({
          'responseId': responseId,
          'data': draft.toJson(),
        });
      } catch (_) {
        // Fall back to local storage on API failure.
      }
    }

    await SurveyDraftStore.addSubmission(submission);
    return responseId;
  }

  String _generateResponseId() {
    final random = Random();
    final code = 1000 + random.nextInt(9000);
    return 'HH-2026-$code';
  }
}
