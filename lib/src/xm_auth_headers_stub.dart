
import 'xm_connection.dart';

/**
 * Default implementation just returns basic credentials for user
 */
Future<String?> getAuthHeader(XmConnection connection) async {
  throw UnimplementedError("Stub does not implement auth");
}

XmConnection? getCustomConnection() {
  throw UnimplementedError("Stub does not implement `getCustomConnection`");
}