import 'dart:io';

import 'package:dio/dio.dart';

BaseOptions baseOptions = BaseOptions(
//  baseUrl: Constants.BASE_URL,
  headers: {HttpHeaders.acceptHeader: "*"},
  connectTimeout: 5000,
  receiveTimeout: 5000,
  contentType: "accept: application/json",
  responseType: ResponseType.plain,
);

final Dio dio = Dio(baseOptions);

class Http {
  Future<Response> get(url, {query, options, cancelToken}) async {
    try {
      Response response;

      response = await dio.get(url,
          queryParameters: query, options: options, cancelToken: cancelToken);

      return response;
    } on DioError catch (e) {
      print('---------\r\n$e\r\n---------');
      return null;
    }
  }

  Future<Response> post(url, {data, options, cancelToken}) async {
    try {
      Response response;

      response = await dio.post(url,
          queryParameters: data, options: options, cancelToken: cancelToken);

      return response;
    } on DioError catch (e) {
      print('---------\r\n$e\r\n---------');
      return null;
    }
  }
}
