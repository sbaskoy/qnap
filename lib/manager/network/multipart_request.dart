import 'dart:async';
import 'dart:io';

import 'package:http/io_client.dart';
import "package:http/http.dart" as http;



class UserCancelledException implements Exception {
  const UserCancelledException();
}

class CloseableMultipartRequest extends http.MultipartRequest {
  IOClient client = IOClient(HttpClient());

  CloseableMultipartRequest(String method, Uri uri) : super(method, uri);

  void close() {
    client.close();
  }



  @override
  Future<http.StreamedResponse> send() async {
    try {
   

      var response = await client.send(this);
      var stream = onDone(response.stream, client.close);
      return http.StreamedResponse(
        http.ByteStream(stream),
        response.statusCode,
        contentLength: response.contentLength,
        request: response.request,
        headers: response.headers,
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase,
      );
    } catch (_) {
      client.close();
      rethrow;
    }
  }

  Stream<T> onDone<T>(Stream<T> stream, void Function() onDone) => stream.transform(
        StreamTransformer.fromHandlers(
          handleDone: (sink) {
            sink.close();
            onDone();
          },
        ),
      );
}
