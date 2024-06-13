import 'dart:convert';
import 'dart:html' as html;

import 'xm_connection.dart';


/**
 * Stores connection information found in session storage
 */
var _connInfoMap = <String, String>{};

/**
 * Get a custom connection. This connection will be based off of information
 * specified in the session storage (populated in index.html through ?xmconn= details).
 * It will create an XmConnection object if sufficient information is available to tell us
 * where to get the token, and whether it's a local or remote deployment.
 *
 * ?xmconn=(url http://localhost:8080)(deployment local)
 */
XmConnection? getCustomConnection() {

  // make sure we've populated the _connInfoMap if possible.
  if (_connInfoMap.isEmpty) {
    _extractConnectionParameters();
  }

  // does the connection map have enough information?
  if (_connInfoMap case {
    'url': String url,
    'deployment': String deploymentType,
  }) {

    // prepare xm connection object
    return XmConnection(

      url: url,

      // a local or a remote deployment ?
      deploymentType:
        XinmodsDeploymentType.values.firstWhere(
          (e) => e.name.toLowerCase() == deploymentType.toLowerCase(),
          orElse: () => XinmodsDeploymentType.local
        ),

      // we should be connecting through jwt
      connectionType: XinmodsConnectionType.jwt

    );
  }

  return null;

}

/**
 * This function is called on the first time a connection is to be made.
 * If we are on the web, there's a possibility we have been given ?xmconn
 * details in the shape of ?xmconn=(key value)(key2 value2)
 *
 * Let's parse those and save them in a map that can be used to determine how
 * to get the token for our requests.
 */
void _extractConnectionParameters() {

  String? xmConnInfo = html.window.localStorage['xmConnection'];
  if (xmConnInfo == null) {
    return;
  }

  // get rid of first (
  if (xmConnInfo[0] == "(") {
    xmConnInfo = xmConnInfo.substring(1);
  }
  // get rid of last )
  if (xmConnInfo.endsWith(")")) {
    xmConnInfo = xmConnInfo.substring(0, xmConnInfo.length - 1);
  }

  // split at )( and interpret each element
  List<String> bits = xmConnInfo.split(")(");
  for (String bitElement in bits) {
    var firstSpaceIdx = bitElement.indexOf(" ");
    if (firstSpaceIdx == -1) {
      continue;
    }
    // split at first space
    var key = bitElement.substring(0, firstSpaceIdx);
    var value = bitElement.substring(firstSpaceIdx + 1);

    // store both sides as part of the connection info map
    _connInfoMap[key] = value;
  }

}

/**
 * Get the JWT token from the server
 */
Future<String?> _requestToken(XmConnection connection) async {

  var origin = html.window.location.origin;
  var url = "${connection.url}/cms/ws/jwt?source=$origin";
  var jwtResponse = await html.HttpRequest.getString(url, withCredentials: true);
  var jwt = jsonDecode(jwtResponse);
  if (jwt is String) {
    return jwt;
  }

  print("[xm-remote-request] could not retrieve JWT: $jwtResponse");
  return null;
}


/**
 * Default implementation just returns basic credentials for user
 */
Future<String?> getAuthHeader(XmConnection connection) async {
  if (connection.connectionType == XinmodsConnectionType.credentials) {

    if (connection.user == null || connection.password == null) {
      print("[xm_auth_headers_web] not all basic auth credentials set, will probably fail");
      throw StateError("Not all basic auth credentials set.");
    }

    String baseAuth = base64Encode("${connection.user}:${connection.password}".codeUnits);
    return "Basic $baseAuth";
  }

  var jwt = await _requestToken(connection);
  if (jwt == null) {
    throw StateError("Could not authenticate.");
  }
  return "Bearer $jwt";
}