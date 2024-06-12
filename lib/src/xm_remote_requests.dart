import "xm_auth_headers_stub.dart"
  if (dart.library.io) 'xm_auth_headers_basic.dart'
  if (dart.library.html) 'xm_auth_headers_web.dart'
;

import 'package:dio/dio.dart';

import 'xm_connection.dart';

class XmRemoteRequests {

  XmConnection connection;

  XmRemoteRequests({
    required this.connection
  });

  /**
   * Determine request headers depending on authorization type.
   */
  Future<Map<String, String>> _requestHeaders() async {

    var authHeader = await getAuthHeader(this.connection);

    // not found? try to just do normal headers.
    if (authHeader == null) {
      print("[xm_remote_requests] Could not determine Authorization header.");
      return {
        'Accept': 'application/json'
      };
    }

    return {
      'Accept': 'application/json',
      'Authorization': authHeader
    };
  }

  /**
   * Get request to xin mods api
   */
  Future<dynamic> get(String url, Map<String, dynamic> options) async {

    var requestHeaders = await this._requestHeaders();
    var fullUrl = "${this.connection.url}$url";
    var dio = Dio(BaseOptions(headers: requestHeaders));

    try {
      Response response = await dio.get(fullUrl, queryParameters: options);
      return response.data;
    }
    catch (err) {
      print("[xm_remote_requests] could not perform GET request, caused by: $err");
      return null;
    }
  }


  /**
   * Get request to xin mods api
   */
  Future<dynamic> delete(String url, Map<String, dynamic> options) async {

    var requestHeaders = await this._requestHeaders();
    var fullUrl = "${this.connection.url}$url";
    var dio = Dio(BaseOptions(headers: requestHeaders));

    try {
      Response response = await dio.delete(fullUrl, queryParameters: options);
      return response.data;
    }
    catch (err) {
      print("[xm_remote_requests] could not perform DELETE request, caused by: $err");
      return null;
    }
  }


  /**
   * POST to the API
   */
  Future<dynamic> post(String url, Map<String, dynamic> data) async {
    var requestHeaders = await this._requestHeaders();
    var fullUrl = "${this.connection.url}$url";
    var dio = Dio(BaseOptions(headers: requestHeaders));

    try {
      Response response = await dio.post(fullUrl, data: data);
      return response.data;
    }
    catch (err) {
      print("[xm_remote_requests] could not perform POST request, caused by: $err");
      return null;
    }

  }


}