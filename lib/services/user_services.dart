import 'dart:convert';

import 'package:qnap/constants/constants.dart';
import 'package:qnap/manager/network/base_network_manager.dart';
import 'package:qnap/models/user_model.dart';

class UserService {
  UserService._();
  static Future<AuthModel?> login(String username, String password) async {
    var manager = BaseNetworkManager(Constants.plannerBaseUrl);
    String? res = await manager.post("service/loginRequest", {"email": username, "password": password});
    if (res == null) {
      return null;
    }
    var mappedResponse = jsonDecode(res);
    if (mappedResponse["result"] == null) {
      return null;
    }
    AuthModel authModel = AuthModel.fromJson(mappedResponse["result"]);
    return authModel;
  }
}
