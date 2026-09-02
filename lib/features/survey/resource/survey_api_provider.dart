import 'package:dio/dio.dart';
import 'package:data_portal_survey/common/http/api_provider.dart';
import 'package:data_portal_survey/features/survey/core/api_unwrap.dart';
import 'package:data_portal_survey/features/survey/model/survey_form_models.dart';

class SurveyApiProvider {
  SurveyApiProvider({required this.apiProvider});

  final ApiProvider apiProvider;
  final String basePath = 'survey-forms';

  Future<List<SurveyFormSummary>> listForms() async {
    final res = await apiProvider.get(basePath);
    final data = unwrapSurveyApiData(res);
    final list = data is List ? data : (data as Map?)?['items'] as List? ?? [];
    return list
        .map((f) => SurveyFormSummary.fromJson(f as Map<String, dynamic>))
        .toList();
  }

  Future<SurveyForm> getForm(String id) async {
    final res = await apiProvider.get('$basePath/$id');
    final data = unwrapSurveyApiData(res) as Map<String, dynamic>;
    return SurveyForm.fromJson(data);
  }

  Future<Map<String, dynamic>> submitResponse(
    String formId,
    List<Map<String, dynamic>> answers, {
    String? dataEntryId,
    bool syncMatrix = true,
  }) async {
    final res = await apiProvider.post('$basePath/$formId/responses', {
      if (dataEntryId != null) 'dataEntryId': dataEntryId,
      'answers': answers,
      'syncMatrix': syncMatrix,
    });
    return unwrapSurveyApiData(res) as Map<String, dynamic>;
  }

  Future<void> bulkSubmit(
    String formId,
    List<Map<String, dynamic>> responses,
  ) async {
    await apiProvider.post('$basePath/$formId/responses/bulk', {
      'responses': responses,
    });
  }

  Future<String> uploadFile(
    String formId,
    String path,
    String filename,
  ) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(path, filename: filename),
    });
    final res = await apiProvider.postMultipart(
      '$basePath/$formId/upload',
      formData,
    );
    final data = unwrapSurveyApiData(res) as Map<String, dynamic>;
    return data['url'] as String;
  }
}
