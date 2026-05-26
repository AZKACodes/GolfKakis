import 'package:golf_kakis/features/foundation/model/response/login_methods_response.dart';

abstract class ProfileLoginUseCase {
  Future<LoginMethodsResponse> onFetchLoginMethods({
    required String phoneNumber,
  });
}
