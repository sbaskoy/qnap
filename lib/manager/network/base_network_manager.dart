import 'dart:async';
import 'dart:developer';

import "package:http/http.dart" as http;

import 'multipart_request.dart';

class BaseNetworkManager {
  final String baseUrl;
  BaseNetworkManager(this.baseUrl);

  Uri getUri(String path, {Map<String, String>? queryParams}) {
    Uri uri = Uri.parse("$baseUrl/$path");
    if (queryParams != null) {
      uri = uri.replace(queryParameters: queryParams);
    }
    log(uri.toString());
    return uri;
  }

  Future<String?> post(String path, Map<String, String> data, {Map<String, String>? headers}) async {
    http.Response response = await http.post(getUri(path), headers: headers ?? {}, body: data);
    if (response.statusCode == 200) {
      return response.body;
    }
    return null;
  }

  Future<String?> get(String path, {Map<String, String>? queryParams, Map<String, String>? headers}) async {
    http.Response response = await http.get(getUri(path, queryParams: queryParams), headers: headers ?? {});
    if (response.statusCode == 200) {
      return response.body;
    }
    return null;
  }

  Future<String?> xWwwFormDataPost(
    String path, {
    Map<String, String>? data,
    Map<String, String>? headers,
    Map<String, String>? queryParams,
  }) async {
    var requestHeaders = {'Content-Type': 'application/x-www-form-urlencoded'};
    var request = http.Request('POST', getUri(path, queryParams: queryParams));

    request.bodyFields = data ?? {};

    requestHeaders.addAll(headers ?? {});

    request.headers.addAll(requestHeaders);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var res = await response.stream.bytesToString();
      return res;
    } else {
      print(response.reasonPhrase);
    }
    return null;
  }

  Future<String?> postMultiPartRequest(
    String path, {
    Map<String, String>? data,
    Map<String, String>? headers,
    Map<String, String>? files,
    Map<String, String>? queryParams,
     String? method,
  }) async {
    var request = await createMultipartRequest(
      path,
      data: data,
      headers: headers,
      queryParams: queryParams,
      files: files,
      method: method
    );
    http.StreamedResponse streamedResponse = await request.send();
    
    http.Response response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      return response.body;
    }
    return null;
  }

  Future<CloseableMultipartRequest> createMultipartRequest(String path,
      {Map<String, String>? data,
      Map<String, String>? headers,
      Map<String, String>? files,
      Map<String, String>? queryParams,
      String? method,
      }) async {
    var request = CloseableMultipartRequest(method ?? "POST", getUri(path, queryParams: queryParams));
    request.fields.addAll(data ?? {});
    request.headers.addAll(headers ?? {});
    if (files != null) {
      for (String key in files.keys) {
        var file = await http.MultipartFile.fromPath(key, files[key]!);
        request.files.add(file);
      }
    }
    return request;
  }
}
