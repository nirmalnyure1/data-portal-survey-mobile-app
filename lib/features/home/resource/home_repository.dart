import 'package:data_portal_survey/common/http/http.dart';
import 'package:data_portal_survey/common/storage/secure_storage.dart';
import 'package:data_portal_survey/features/home/resource/home_api_provider.dart';

class HomeRepository {
  final ApiProvider apiProvider;
  final SecureStorage secureStorage;

  late HomeApiProvider homeApiProvider;

  HomeRepository({required this.apiProvider, required this.secureStorage}) {
    homeApiProvider = HomeApiProvider(apiProvider: apiProvider);
  }
}
