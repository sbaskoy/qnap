import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qnap/controllers/auth_controller.dart';
import 'package:qnap/views/home/widgets/home_view_app_bar.dart';
import 'package:qnap/views/home/widgets/qnap_login.dart';
import 'package:qnap/views/login_view.dart';
import 'package:qnap/views/synchronize/synchronize_view.dart';

import '../../controllers/qnap_controller.dart';

enum HomeViewTab { login, synchronize }

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  HomeViewTab _tab = HomeViewTab.login;
  late final QnapController _qnapController = QnapController();
  void _onLoginSuccess() {
    setState(() => _tab = HomeViewTab.synchronize);
  }

  void _exit() {
    AuthState.logout();
    Get.offAll(const LoginView());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          HomeViewAppBar(
            onPressChangeToken: () => setState(() => _tab = HomeViewTab.login),
            onPressExit: _exit,
          ),
          const Spacer(),
          _tab == HomeViewTab.login
              ? QnapLoginWidget(
                  onLoginSuccess: _onLoginSuccess,
                  qnapController: _qnapController,
                )
              : QnapSynchronizeView(
                  qnapController: _qnapController,
                ),
          const Spacer(),
        ],
      ),
    );
  }
}
