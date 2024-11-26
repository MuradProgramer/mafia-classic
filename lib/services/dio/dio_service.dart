import 'dart:io';

import 'package:dio/io.dart';
import 'package:dio/dio.dart';

class DioService {
  final Dio dio;

  DioService()
      : dio = Dio(BaseOptions(
          baseUrl:  "https://192.168.1.3:7141/api/",
          headers: {
            'Content-Type': 'application/json',
            //'Accept': 'application/json', // Добавляем, если сервер всегда возвращает JSON
          },
        )) {
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );
  }
}