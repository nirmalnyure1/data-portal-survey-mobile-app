import 'package:data_portal_survey/common/http/api_provider.dart';
import 'package:data_portal_survey/features/survey/core/payload.dart';
import 'package:data_portal_survey/features/survey/model/survey_form_models.dart';
import 'package:data_portal_survey/features/survey/resource/survey_api_provider.dart';
import 'package:data_portal_survey/features/survey/service/survey_draft_store.dart';

class SurveyRepository {
  SurveyRepository({required ApiProvider apiProvider})
      : _api = SurveyApiProvider(apiProvider: apiProvider);

  final SurveyApiProvider _api;

  Future<List<SurveyFormSummary>> listForms() => _api.listForms();

  Future<SurveyForm> getForm(String id) => _api.getForm(id);

  Future<bool> hasActiveDraft(String formId) => SurveyDraftStore.hasDraft(formId);

  Future<Map<String, dynamic>> submit({
    required SurveyForm form,
    required Map<String, String> answers,
    String? dataEntryId,
  }) async {
    final payload = buildSubmitPayload(form.sections, answers);
    return _api.submitResponse(
      form.id,
      payload,
      dataEntryId: dataEntryId,
    );
  }

  Future<String> uploadFile({
    required String formId,
    required String path,
    required String filename,
  }) =>
      _api.uploadFile(formId, path, filename);

  Future<void> flushPendingSubmissions() async {
    final pending = await SurveyDraftStore.loadPendingSubmissions();
    if (pending.isEmpty) return;

    final remaining = <Map<String, dynamic>>[];
    for (final item in pending) {
      try {
        final formId = item['formId'] as String;
        final answers = (item['answers'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        await _api.submitResponse(formId, answers);
      } catch (_) {
        remaining.add(item);
      }
    }
    await SurveyDraftStore.setPendingSubmissions(remaining);
  }

  Future<void> queueOfflineSubmission({
    required String formId,
    required List<Map<String, dynamic>> answers,
  }) async {
    await SurveyDraftStore.addPendingSubmission({
      'formId': formId,
      'answers': answers,
      'queuedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }
}
