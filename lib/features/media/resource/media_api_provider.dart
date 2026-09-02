import 'package:data_portal_survey/common/http/http.dart';

class MediaApiProvider {
  final ApiProvider apiProvider;
  final String basePath = 'media';

  MediaApiProvider({required this.apiProvider});

  Future<dynamic> uploadMedia(dynamic body) async {
    return await apiProvider.post('$basePath/upload', body);
  }
}
