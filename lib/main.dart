import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:qnap/controllers/loading_controller.dart';
import 'package:qnap/views/login_view.dart';
import 'package:qnap/widgets/close_keyboard.dart';

void main() {
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Ajanssu qnap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return CloseKeyboardWidget(
          child: AppProgressIndicator(
            child: child ?? const SizedBox(),
          ),
        );
      },
      navigatorKey: navigatorKey,
      home: const LoginView(),
    );
  }
}
