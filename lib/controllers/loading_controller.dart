import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../widgets/centered_progress_indicator.dart';

class AppProgressState {
  static AppProgressState? _instance;
  static AppProgressState get _this {
    _instance ??= AppProgressState._init();
    return _instance!;
  }

  AppProgressState._init();

  final _loading = BehaviorSubject.seeded(false);
  static Stream<bool> get loadingStream => _this._loading.stream;

  static void change(bool val) {
    _this._loading.sink.add(val);
  }

  static void toggle() {
    _this._loading.value = !_this._loading.value;
  }
}

class AppProgressIndicator extends StatelessWidget {
  final Widget child;
  const AppProgressIndicator({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: AppProgressState.loadingStream,
      builder: (context, snapshot) {
        var isProgress = snapshot.data ?? false;
        return Stack(
          children: [
            AnimatedOpacity(
              opacity: isProgress ? 0.1 : 1,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: isProgress,
                child: child,
              ),
            ),
            if (isProgress)
              const Align(
                alignment: Alignment.center,
                child: CenteredProgressIndicator(),
              )
          ],
        );
      },
    );
  }
}
