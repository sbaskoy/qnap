import 'dart:convert';
import 'dart:io';

import 'package:qnap/constants/constants.dart';
import 'package:qnap/manager/network/base_network_manager.dart';
import 'package:qnap/models/qnap_file.dart';
import 'package:xml/xml.dart' as xml;
import 'package:dio/dio.dart';
import '../models/file_list_response.dart';
import '../utils/qnap.dart';
import 'package:path/path.dart' as path;

import '../utils/settings.dart';


class QnapServices {
  QnapServices._();
  static final _manager = BaseNetworkManager(Constants.qnapBaseUrl);
  static Future<String?> login() async {
    var setting =await loadSetting();
    String? res = await _manager.get(
      "authLogin.cgi",
      queryParams: {"user": setting.qnapUserName, "pwd": ezEncode(setting.qnapPassword)},
    );
    if (res != null) {
      final responseDocument = xml.XmlDocument.parse(res);
      xml.XmlElement? root = responseDocument.findElements("QDocRoot").firstOrNull;
      String? authSid = root?.findElements("authSid").firstOrNull?.innerText;
      if (authSid != null) {
        return authSid;
      }
    }
    return null;
  }

  static Future<List<QnapFile>?> listDirectory(String authSid, String path) async {
    String? res = await _manager.get(
      "filemanager/utilRequest.cgi",
      queryParams: {
        "func": "get_tree",
        "sid": authSid,
        "node": path,
        "is_iso": "0",
        "limit": "100",
        "sort": "nartual",
        "start": "0",
      },
    );
    if (res != null) {
      var map = jsonDecode(res);
      if (map is List) {
        return map.map((e) => QnapFile.fromJson(e)).toList();
      }
    }
    return null;
  }

  static Future<FileListResponse?> listFiles(String authSid, String path) async {
    String? res = await _manager.get(
      "filemanager/utilRequest.cgi?func=get_list&sid=$authSid&path=$path&dir=ASC&sort=nartual&start=0&limit=100",
      // queryParams: {
      //   "func": "get_list",
      //   "sid": authSid,
      //   "path": path,
      //   "dir": "ASC",
      //   "sort": "nartual",
      //   "start": "0",
      //   "limit": "100"
      // },
    );
    if (res != null) {
      var map = jsonDecode(res);
      if(map['status'] != null){
        throw "Error";
      }
      return FileListResponse.fromJson(map);
    }
    return null;
  }

  static Future<String?> closeChunkedLoad(
      {required String authSid, required String qnapPath, required String fileName, required String uploadId}) async {
    var res = await _manager.postMultiPartRequest("filemanager/utilRequest.cgi", data: {
      "func": "upload_close_session",
      "sid": authSid,
      "dest_path": "",
      "session_id": uploadId,
      "filename": fileName,
      "err_code": "-1",
    });
    return res;
  }

  static Future<String?> uploadStartSession({required String authSid}) async {
    var res = await _manager.postMultiPartRequest("filemanager/utilRequest.cgi", data: {
      "func": "upload_start_session",
      "sid": authSid,
    });
    if (res != null) {
      var responseMap = jsonDecode(res);
      return responseMap["session_id"];
    }
    return null;
  }

  static Future<String?> startChunkedUpload(String authSid, String path) async {
    String? res = await _manager.xWwwFormDataPost("filemanager/utilRequest.cgi", data: {
      "func": "start_chunked_upload",
      "sid": authSid,
      "upload_root_dir": path,
    }, headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    });
    if (res != null) {
      var responseMap = jsonDecode(res);
      return responseMap["upload_id"];
    }
    return null;
  }

  static Future<String?> chunkedUpload({
    // login key
    required String authSid,

    /// qnap load directory path
    required String qnapPath,

    /// uploaded file path
    required String filePath,

    /// upload Id
    required String uploadId,

    /// file name
    required String fileName,

    /// total file size
    required String fileSize,

    /// chunk start size
    required String offset,

    ///
  }) async {
    String? res = await _manager.postMultiPartRequest("filemanager/utilRequest.cgi", queryParams: {
      "func": "changed_upload",
      "sid": authSid,
      "desc_path": qnapPath,
      "mode": "2",
      "dup": "Copy",
      "upload_root_dir": qnapPath,
      "upload_id": uploadId,
      "filesize": fileSize,
      "upload_name": fileName,
      "offset": offset,
      "multipart": "0",
    }, data: {
      "fileName": fileName,
    }, files: {
      "file": filePath
    });
    return res;
  }

  static Future<String?> startUploadProgress({
    required String authSid,
    required String path,
  }) async {
    String? res = await _manager.postMultiPartRequest("filemanager/utilRequest.cgi", data: {
      "average_speed": "0",
      "speed": "0",
      "copying": "1",
      "end_time": "-1",
      "end_time_str": "--",
      "start_time": DateTime.now().microsecondsSinceEpoch.toString(),
      "func": "upload_progress",
      "sid": authSid,
      "upload_root_dir": path,
    }, headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    });
    if (res != null) {
      var responseMap = jsonDecode(res);
      return responseMap["upload_id"];
    }
    return null;
  }

  static Future<String?> uploadCloseSession({
    required String authSid,
    required String fileName,
    required String descName,
    required String sessionId,
  }) async {
    var res = await _manager.postMultiPartRequest("filemanager/utilRequest.cgi", data: {
      "func": "upload_close_session",
      "filename": fileName,
      "desc_path": "",
      "session_id": sessionId,
      "sid": authSid,
      "err_code": "-1"
    });
    if (res != null) {
      var responseMap = jsonDecode(res);
      return responseMap["session_id"];
    }
    return null;
  }

  static Future<bool> upload({
    required String sid,
    required String descPath,
    required String filePath,
    CancelToken? cancelToken,
  }) async {
    try {
      final dio = Dio();
      String fileName = path.basename(filePath); //filePath.split('\\').last;
      var arr = fileName.split(".");
      var name = arr.sublist(0, arr.length - 1).join("_");

      var newName = "${name}_${DateTime.now().microsecondsSinceEpoch}.${arr.last}";
      var progress='$descPath/$newName'.replaceAll("/", "-");
      var url = _manager.getUri("filemanager/utilRequest.cgi?func=upload&type=standard&sid=$sid&dest_path=$descPath&overwrite=0&progress=$progress", 
      // queryParams: {
      //   "func": "upload",
      //   "type": "standard",
      //   "sid": sid,
      //   "dest_path": descPath,
      //   "overwrite": "0",
      //   "progress": '$descPath/$newName'.replaceAll("/", "-")
      // },
      );
      FormData data = FormData.fromMap({});

      data.files.add(MapEntry(
          "file",
          MultipartFile.fromBytes(
            File(filePath).readAsBytesSync(),
            filename: newName,
          )));
      var res = await dio.post(
        url.toString(),
        data: data,
        options: Options(contentType: "multipart/form-data"),
        cancelToken: cancelToken,
      );

      if (res.data["status"] == 1) {
        return res.data["name"] == newName;
      }
      return false;
    } catch (ex) {
      return false;
    }
  }
}
