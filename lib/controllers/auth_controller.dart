import 'package:get/get.dart';
import 'package:qnap/controllers/loading_controller.dart';
import 'package:qnap/models/user_model.dart';
import 'package:qnap/services/user_services.dart';
import 'package:qnap/views/home/home_view.dart';
import 'package:rxdart/subjects.dart';

class AuthState {
  static AuthState? _instance;
  static AuthState get _authPrivateInstance {
    _instance ??= AuthState._init();
    return _instance!;
  }

  AuthState._init();

  final _user = BehaviorSubject<AuthModel?>();
  static Stream<AuthModel?> get authUserStream => _authPrivateInstance._user.stream;
  static String? get token => _authPrivateInstance._user.valueOrNull?.token ?? "";

  static void login(String username, String password) async {
    try {
      AppProgressState.change(true);
      AuthModel? user = await UserService.login(username, password);
      if (user != null) {
        _authPrivateInstance._user.sink.add(user);
        Get.offAll(
          const HomeView(),
          transition: Transition.rightToLeft,
        );
        return;
      }
      throw "error";
    } catch (ex) {
      Get.showSnackbar(const GetSnackBar(
        message: "Kullanıcı adı veya şifre hatalı",
      ));
    } finally {
      AppProgressState.change(false);
    }
  }

  static void logout() {
    _authPrivateInstance._user.sink.add(null);
  }
}
