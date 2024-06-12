import 'dart:convert';

import 'xm_connection.dart';
import 'xm_models.dart';
import 'xm_query_builder.dart';
import 'xm_remote_requests.dart';


class XmCollection {

  /**
   * Collection name
   */
  String name;

  /**
   * Connection
   */
  XmConnection connection;

  /**
   * Initialise data-members
   */
  XmCollection({
    required this.connection,
    required this.name
  });

  /**
   * Start collection query
   */
  XmQuery query([String? childPath]) {
    return XmQuery(
      connection: this.connection,
      typeName: "xinmods:collectionitem",
      includes: [
        "/content/collections/$name${childPath != null ? "/$childPath" : ""}"
      ]
    );
  }


  /**
   * Get an item from a collection
   */
  Future<Map<String, dynamic>?> getItem(String path) async {
    var remoteRequests = XmRemoteRequests(connection: this.connection);
    var response = await remoteRequests.get("${connection.xinApi}/collections/$name/item", {
      'path': path
    });

    if (response is! Map<String, dynamic>) {
      return null;
    }

    var map = response;
    if (map['item'] == null) {
      return null;
    }
    return map['item'] as Map<String, dynamic>;
  }

  /**
   * Delete an item from the collection
   */
  Future<bool> deleteItem(String path, {bool forceDelete = false}) async {
    var remoteRequests = XmRemoteRequests(connection: this.connection);
    var response = await remoteRequests.delete("${connection.xinApi}/collections/$name/item", {
      'path': path,
      'forceDelete': forceDelete ? 'true' : 'false'
    });

    if (response is! Map<String, dynamic>) {
      return false;
    }

    return response['success'];
  }

  /**
   * Put an item into a collection
   */
  Future<bool> putItem(String path, Object obj, {
    XmCollectionPutItemBehavior putBehavior =
    XmCollectionPutItemBehavior.merge
  }) async {
    var remoteRequests = XmRemoteRequests(connection: this.connection);

    var values = this._serialiseObject(obj);

    var response = await remoteRequests.post("${connection.xinApi}/collections/$name/item?path=${Uri.encodeQueryComponent(path)}", {
      'saveMode': putBehavior.name,
      'values': values
    });

    if (response is! Map<String, dynamic>) {
      return false;
    }

    return response['success'];
  }


  /**
   * Serialise an object to include types.
   */
  Map<String, Map<String, dynamic>> _serialiseObject(obj) {

    // obj to json, to map
    String json = jsonEncode(obj);
    Map<String, dynamic> mapObj = jsonDecode(json);

    Map<String, Map<String, dynamic>> values = {};
    // iterate over all entries in the map
    for (MapEntry<String, dynamic> entry in mapObj.entries) {
      if (entry.value is bool) {
        values[entry.key] = {
          'value': entry.value,
          'type': "Boolean"
        };
      }
      else if (entry.value is String) {
        values[entry.key] = {
          'value': entry.value,
          'type': 'String'
        };
      }
      else if (entry.value is num) {
        values[entry.key] = {
          'value': entry.value,
          'type': entry.value is int ? 'Long' : 'Double'
        };
      }
      else if (entry.value is DateTime) {
        values[entry.key] = {
          'value': (entry.value as DateTime).toIso8601String(),
          'type': 'Date'
        };
      }
      else {
        print("[xinmods-collection] Don't know how to serialize object for key: ${entry.key}");
      }
    }

    return values;
  }

  //
  // Convenience functions
  //

  Future<bool> putAndOverwrite(String path, Object obj) => putItem(path, obj, putBehavior: XmCollectionPutItemBehavior.overwrite);
  Future<bool> putAndMerge(String path, Object obj) => putItem(path, obj, putBehavior: XmCollectionPutItemBehavior.merge);
  Future<bool> putAndFailIfExists(String path, Object obj) => putItem(path, obj, putBehavior: XmCollectionPutItemBehavior.failIfExists);


}