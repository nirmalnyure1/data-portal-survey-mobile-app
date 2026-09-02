import 'package:data_portal_survey/common/http/http.dart';

class SupportApiProvider {
  final ApiProvider apiProvider;

  SupportApiProvider({required this.apiProvider});

  Future<dynamic> applyHelp(Map<String, dynamic> body) async {
    return await apiProvider.post('apply-help', body);
  }
}
