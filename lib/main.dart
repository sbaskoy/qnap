import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:qnap/controllers/loading_controller.dart';
import 'package:qnap/views/login_view.dart';
import 'package:qnap/widgets/close_keyboard.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  await windowManager.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    //var screenSize = await windowManager.getSize();
    await windowManager.setSize(const Size(1000, 800), animate: true);
  
    await windowManager.setMinimumSize(const Size(1000, 800));
  }
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
