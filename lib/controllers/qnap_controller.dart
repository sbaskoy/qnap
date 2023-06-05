import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:qnap/controllers/loading_controller.dart';
import 'package:qnap/services/qnap_services.dart';
import 'package:rxdart/subjects.dart';

import '../models/file_list_response.dart';

class QnapFileController {
  final String sid;
  final String descPath;
  final String filePath;
  final Function(String path) onSuccess;
  QnapFileController({required this.sid, required this.descPath, required this.filePath, required this.onSuccess});

  final _loading = BehaviorSubject.seeded(false);

  Stream<bool> get loading => _loading.stream;
  CancelToken cancelToken = CancelToken();
  Future<bool> loadQnap() async {
    var res = await QnapServices.upload(
      sid: sid,
      descPath: descPath,
      filePath: filePath,
      cancelToken: cancelToken,
    );
    if (res) {
      return true;
    }
    print("File can not uploaded -> $filePath");
    return await loadQnap();
  }

  void load() async {
    _loading.sink.add(true);
    var isLoadedQnap = await loadQnap();
    print("File uploaded -> $filePath");
    try {
      if (isLoadedQnap) {
        _loading.sink.add(false);
        onSuccess(filePath);
        return;
      }
      throw "failed file";
    } catch (ex) {
      var name = filePath.split("\\").last;
      _loading.sink.addError("$name dosyası yüklendi fakat Uploaded klasörüne taşınamadı.");
    }
  }

  destroy() {
    cancelToken.cancel();
  }
}

class QnapController {
  final _uuid = BehaviorSubject<String>();
  final _localPath = BehaviorSubject<String>();
  final _qnapPath = BehaviorSubject<String>();
  final _localFileList = BehaviorSubject<List<QnapFileController>>.seeded([]);
  final _qnapFileList = BehaviorSubject<FileListResponse?>();

  Stream<String?> get uuIdStream => _uuid.stream;
  Stream<List<QnapFileController>> get localFileListStream => _localFileList.stream;
  Stream<FileListResponse?> get qnapFileListStream => _qnapFileList.stream;

  String? get uuId => _uuid.valueOrNull;
  String? get qnapPath => _qnapPath.valueOrNull;
  String? get localPath => _localPath.valueOrNull;

  List<QnapFileController>? get localFileList => _localFileList.valueOrNull;

  Function(String path) get localPathChange => _localPath.sink.add;
  Function(String path) get qnapPathChange => _qnapPath.sink.add;

  Timer? qnapFileListTimer;
  StreamSubscription<FileSystemEvent>? localFileWatcher;

  void qnapFileList() async {
    if (uuId != null && qnapPath != null) {
      FileListResponse? res = await QnapServices.listFiles(uuId!, qnapPath!);
      if (res != null) {
        _qnapFileList.sink.add(res);
      }
    }
  }

  void uploadFile(String filePath) async {
    if (uuId != null && qnapPath != null) {
      try {
        AppProgressState.change(true);

        var res = await QnapServices.upload(
          sid: uuId!,
          filePath: filePath,
          descPath: qnapPath!,
        );
        log("Load file res -> $res");
      } catch (ex) {
        Get.snackbar("HATA", "Dosya yüklenirken hata oluştu $ex");
      } finally {
        AppProgressState.change(false);
      }
    }
  }

  Future<void> createUploadedFolder() async {
    /// uploaded file
    var uploadedDirectory = Directory("$localPath\\Uploaded");

    var isExistsUploadedDirectory = await uploadedDirectory.exists();

    /// if not exists upload folder create folder
    if (!isExistsUploadedDirectory) {
      await uploadedDirectory.create();
    }
  }

  Future<File?> moveFile(String sourcePath) async {
    var sourceFile = File(sourcePath);
    var isExistsSource = await sourceFile.exists();
    if (!isExistsSource) return null;

    await createUploadedFolder();

    var name = sourcePath.split("\\").last;
    var newPath = "$localPath\\Uploaded\\$name";
    try {
      var newFile = File(newPath);
      var isExists = await newFile.exists();
      if (isExists) {
        name = "${DateTime.now().millisecondsSinceEpoch}_$name";
        newPath = "$localPath\\Uploaded\\$name";
      }

      // prefer using rename as it is probably faster
      return await sourceFile.rename(newPath);
    } on FileSystemException {
      var exists = await sourceFile.exists();
      if (exists) {
        // if rename fails, copy the source file and then delete it
        final newFile = await sourceFile.copy(newPath);
        await sourceFile.delete();
        return newFile;
      }
    } catch (ex) {
      print("File path -> $sourcePath");
      print("ex -> $ex");
      return null;
    }
    return null;
  }

  /// if completed file upload remove file same path
  void onUploadSuccess(String path) async {
    await moveFile(
      path,
    );
    var files = _localFileList.valueOrNull ?? [];
    files.removeWhere((element) => element.filePath == path);
    _localFileList.sink.add(files);
  }

  /// add new file controller to local file list
  void pushNewLocalFileItem(QnapFileController item) {
    var files = _localFileList.valueOrNull ?? [];
    if (!files.any((element) => element.filePath == item.filePath)) {
      files.add(item);
      _localFileList.sink.add(files);
      item.load();
    }
  }

  void synchronize() async {
    /// selected local path
    var localDirectory = Directory(_localPath.value);
    await createUploadedFolder();
    var stream = localDirectory.watch(events: FileSystemEvent.all);

    var files = localDirectory.listSync();
    _localFileList.sink.add(files.whereType<File>().map((e) {
      return QnapFileController(sid: uuId!, descPath: qnapPath!, filePath: e.path, onSuccess: onUploadSuccess)..load();
    }).toList());

    localFileWatcher = stream.listen((event) async {
      if (!event.path.endsWith("Uploaded")) {
        // if created new file
        if (event.type == FileSystemEvent.create) {
          var item =
              QnapFileController(descPath: qnapPath!, filePath: event.path, sid: uuId!, onSuccess: onUploadSuccess);
          pushNewLocalFileItem(item);
        }
      }
    });

    qnapFileListTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      qnapFileList();
    });
  }

  Future<void> loginQnap() async {
    try {
      AppProgressState.change(true);
      String? id = await QnapServices.login();
      if (id != null) {
        _uuid.sink.add(id);
        return;
      }
      throw "error";
    } catch (ex) {
      log("Qnap login error $ex");
    } finally {
      AppProgressState.change(false);
    }
  }

  void dispose() {
    localFileWatcher?.cancel();
    qnapFileListTimer?.cancel();
    for (var element in _localFileList.value) {
      element.destroy();
    }
    _localFileList.sink.add([]);
    _qnapFileList.sink.add(null);
  }
}
