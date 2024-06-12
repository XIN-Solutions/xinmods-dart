import 'dart:convert';

import 'xm_connection.dart';

/**
 * Creates a custom connection. This is not implemented for the basic auth one just yet.
 */
XmConnection? getCustomConnection() {
  return null;
}

/**
 * Default implementation just returns basic credentials for user
 */
Future<String?> getAuthHeader(XmConnection connection) async {
  if (connection.connectionType == XinmodsConnectionType.jwt) {
    print("[xm_auth_headers_basic] Cannot use JWT connection outside of web platforms, let's see if there are credentials.");
  }

  if (connection.user == null || connection.password == null) {
    print("[xm_auth_headers_basic] not all basic auth credentials set, will probably fail");
    throw StateError("Not all basic auth credentials set.");
  }

  String baseAuth = base64Encode("${connection.user}:${connection.password}".codeUnits);
  return "Basic $baseAuth";
}
