import 'package:data_portal_survey/common/http/api_provider.dart';

class SurveyApiProvider {
  SurveyApiProvider({required this.apiProvider});

  final ApiProvider apiProvider;
  final String basePath = 'survey';

  Future<dynamic> submitHousehold(Map<String, dynamic> body) async {
    return apiProvider.post('$basePath/household', body);
  }
}
