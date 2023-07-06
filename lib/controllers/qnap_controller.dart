import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:qnap/constants/constants.dart';
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
  bool cancelRecurcive =false;
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
    if(cancelRecurcive)return false;
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
      var name=path.basename(filePath);
      //var name = filePath.split("\\").last;
      _loading.sink.addError("$name dosyası yüklendi fakat Uploaded klasörüne taşınamadı.");
    }
  }

  destroy() {
    cancelRecurcive=true;
    cancelToken.cancel();
  }
}

class QnapController {
  final _uuid = BehaviorSubject<String>();
  final _localPath = BehaviorSubject<String>();
  final _qnapPath = BehaviorSubject<String>();
  final _qnapFilelistError = BehaviorSubject<String?>();
  final _localFileList = BehaviorSubject<List<QnapFileController>>.seeded([]);
  final _qnapFileList = BehaviorSubject<FileListResponse?>();

  Stream<String?> get uuIdStream => _uuid.stream;
  Stream<String?> get errorStream => _qnapFilelistError.stream;
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

  Future<bool> qnapFileList() async {
    try {
  if (uuId != null && qnapPath != null) {
      FileListResponse? res = await QnapServices.listFiles(uuId!, qnapPath!);
      if (res != null) {
        _qnapFileList.sink.add(res);
        return true;
      }
    }
      return false;
    }catch(ex){
      _qnapFilelistError.sink.add("Seçili qnap dosya yoluna baglanılamadı. Bu klasöre erişim yetkiniz olmayabilir. Kodunuzu kontrol ediniz");
      return false;
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
    var uploadedDirectory = Directory(path.join(localPath!,Constants.uploadedDirectoryName));

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

    var name = path.basename(sourcePath) ;//  sourcePath.split("\\").last;
    var newPath =  path.joinAll([localPath!,Constants.uploadedDirectoryName,name]); //"$localPath\\Uploaded\\$name";
    try {
      var newFile = File(newPath);
      var isExists = await newFile.exists();
      if (isExists) {
        name = "${DateTime.now().millisecondsSinceEpoch}_$name";
        newPath = path.joinAll([localPath!,Constants.uploadedDirectoryName,name]);//"$localPath\\Uploaded\\$name";
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
    var res=await qnapFileList();
    if(!res){
      return;
    }
    /// selected local path
    var localDirectory = Directory(_localPath.value);
    await createUploadedFolder();
    var stream = localDirectory.watch(events: FileSystemEvent.all);

    var files = localDirectory.listSync();
    
    files = files.whereType<File>().where((element) {
      var name=path.basename(element.path);
      return !name.startsWith(".");
    }).toList();

    _localFileList.sink.add(files.map((e) {
      return QnapFileController(sid: uuId!, descPath: qnapPath!, filePath: e.path, onSuccess: onUploadSuccess)..load();
    }).toList());

    localFileWatcher = stream.listen((event) async {
      if (!event.path.endsWith(Constants.uploadedDirectoryName)) {
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
      throw "Qnap baglantısı kurulamadı. Kullanıcı adınızı ve şifrenizi kontrol ediniz.";
    } catch (ex) {
      rethrow;
      
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
    _qnapFilelistError.sink.add(null);
    _qnapFileList.sink.add(null);
  }
}
