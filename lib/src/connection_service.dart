import 'package:xinmods/xinmods.dart';

import "xm_auth_headers_stub.dart"
  if (dart.library.io) './xm_auth_headers_basic.dart'
  if (dart.library.html) './xm_auth_headers_web.dart'
;

import 'package:flutter/foundation.dart';

XmConnection getXmConnection() {

  if (kIsWeb) {
    var conn = getCustomConnection();

    if (conn != null) {
      return conn;
    }
  }

  // fallback connection (useful for when running a Linux app locally)
  return XmConnection(
    connectionType: XinmodsConnectionType.credentials,
    deploymentType: XinmodsDeploymentType.local,
    url: "http://localhost:8080",
    user: "admin",
    password: "admin"
  );
}

