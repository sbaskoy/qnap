import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class IpModel {
  final String name;
  final String ip;
  final int port;

  IpModel(this.name, this.ip, this.port);
}

class IpFailedModel {
  final IpModel ip;
  final String date;
  final String? error;

  IpFailedModel(this.ip, this.date, this.error);
}

class CheckerModel {
  final bool isSuccess;
  final String? error;

  CheckerModel(this.isSuccess, this.error);
}

final defaultUrls = [
  IpModel("Planner", "85.105.75.139", 1881),
  IpModel("Google 1", "8.8.8.8", 53),
  IpModel("Google 2", "8.8.4.4", 53),
];

class ConnectivityState {
  static ConnectivityState? _instance;
  static ConnectivityState get _this {
    _instance ??= ConnectivityState._init();
    return _instance!;
  }

  static Timer? timer;
  ConnectivityState._init() {
    log("Starting connectivity listener", name: "ConnectivityState");

    timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      listen();
    });
  }
  final _isConnected = BehaviorSubject<bool>.seeded(true);
  final _selectedIp = BehaviorSubject<IpModel>.seeded(defaultUrls.first);
  final _failedPings = BehaviorSubject<List<IpFailedModel>>.seeded([]);

  static bool get isConnected => _this._isConnected.valueOrNull ?? false;
  static IpModel get selectedIp => _this._selectedIp.value;

  static Stream<bool> get connected => _this._isConnected.stream;
  static Stream<List<IpFailedModel>> get failedPingsStream => _this._failedPings.stream;
  static Stream<IpModel> get selectedIpStream => _this._selectedIp.stream;

  static void refresh() async {
    // AppProgressState.change(true);
    var check = await hasConnection();
    _this._isConnected.sink.add(check);
    // AppProgressState.change(false);
  }

  static Future<bool> hasConnection() async {
    var res = await checkNetwork();
    return res.isSuccess;
  }

  static Future<CheckerModel> checkNetwork() async {
    try {
      var socket = await Socket.connect(selectedIp.ip, selectedIp.port, timeout: const Duration(seconds: 3));
      socket.destroy();
      return CheckerModel(true, null);
    } catch (e) {
      return CheckerModel(false, e.toString());
    }
  }

  static void listen() async {
    var response = await checkNetwork();
    if (isConnected != response.isSuccess) {
      if (response.isSuccess) {
        _this._isConnected.sink.add(true);
        _this._failedPings.sink.add([]);
      } else {
        _this._isConnected.sink.add(false);
      }
    }
    if (!response.isSuccess) {
      var failedPings = _this._failedPings.valueOrNull ?? [];
      failedPings.add(IpFailedModel(selectedIp, DateTime.now().toIso8601String(), response.error));
      _this._failedPings.sink.add(failedPings);
    }
  }

  static dispose() {
    timer?.cancel();
  }
}

class ConnectivityChecker extends StatelessWidget {
  final Widget child;
  const ConnectivityChecker({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        stream: ConnectivityState.connected,
        builder: (_, snapshot) {
          var connected = snapshot.data ?? false;
          return Stack(
            children: [
              AnimatedOpacity(
                opacity: connected ? 1 : 0.1,
                duration: const Duration(milliseconds: 100),
                child: IgnorePointer(
                  ignoring: connected == false,
                  child: child,
                ),
              ),
              if (connected == false)
                const Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "İnternet baglatınız kontrol ediniz",
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        "İnternet baglatınız kontrol ediniz",
                      ),
                      SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                ),
            ],
          );
        });
  }
}
