import 'xm_connection.dart';

class XmQueryResult {

  bool success;
  String message;
  List<XmQueryResultUuid> uuids;
  int totalSize;
  List<Map<String, dynamic>> documents;

  XmQueryResult({
    required this.success,
    required this.message,
    required this.uuids,
    required this.totalSize,
    required this.documents
  });

  XmQueryResult.fromJson(Map<String, dynamic> json, {required bool sanitise})
  :
    success = json['success'] ?? false,
    message = json['message'] ?? '',
    uuids = _toUuidStructure(json['uuids']),
    documents = <Map<String, dynamic>>[
      if (sanitise)
        ...[for (var el in json['documents']) XmQueryResult.sanitise(el)]
      else
        ...json['documents']
    ],
    totalSize = json['totalSize'] ?? 0
  ;


  /**
   * Strip all namespace information off of the map keys
   */
  static Map<String, dynamic> sanitise(Map<String, dynamic> input) {
    Map<String, dynamic> output = {};

    for (var entry in input.entries) {
      var niceKey = entry.key.contains(":") ? entry.key.split(":")[1] : entry.key;

      if (entry.value is Map) {
        output[niceKey] = sanitise(entry.value);
      }
      else {
        output[niceKey] = entry.value;
      }
    }

    return output;
  }

  static List<XmQueryResultUuid> _toUuidStructure(List<dynamic> json) {
    var uuids = <XmQueryResultUuid>[];
    for (var jsonEl in json) {
      Map<String, dynamic> map = jsonEl as Map<String, dynamic>;
      uuids.add(XmQueryResultUuid.fromJson(map));
    }
    return uuids;
  }

}

class XmQueryResultUuid {
  String uuid;
  String path;
  String url;
  String type;

  XmQueryResultUuid({
    required this.uuid,
    required this.path,
    required this.url,
    required this.type
  });

  XmQueryResultUuid.fromJson(Map<String, dynamic> json)
  :
    uuid = json['uuid'] ?? "",
    path = json['path'] ?? "",
    url = json['url'] ?? "",
    type = json['type'] ?? ""
  ;

}

class XmDocumentLocation {
  bool success;
  String message;
  String path;
  String type;
  String uuid;

  XmDocumentLocation({
    required this.success,
    required this.message,
    required this.path,
    required this.type,
    required this.uuid
  });

  XmDocumentLocation.fromJson(Map<String, dynamic> json)
  :
    success = json['success'],
    message = json['message'],
    path = json['path'],
    type = json['type'],
    uuid = json['uuid']
  ;
}


class XmDocumentList {
  bool success;
  String message;
  String uuid;
  String path;
  String name;
  String label;

  List<XmFolderListItem> folders;
  List<XmDocumentListItem> documents;

  XmDocumentList.fromJson(Map<String, dynamic> json)
  :
    success = json['success'] ?? false,
    message = json['message'] ?? '',
    uuid = json['uuid'] ?? '',
    path = json['path'] ?? '',
    name = json['name'] ?? '',
    label = json['label'] ?? '',
    folders = toFolderLocationList(json['folders']),
    documents = toDocumentLocationList(json['documents'])
  ;

  static List<XmFolderListItem> toFolderLocationList(List<dynamic> list) {
    return (
      list
        .map((el) => el as Map<String, dynamic>)
        .map((el) => XmFolderListItem.fromJson(el))
        .toList()
    );
  }

  static List<XmDocumentListItem> toDocumentLocationList(List<dynamic> list) {
    return (
      list
        .map((el) => el as Map<String, dynamic>)
        .map((el) => XmDocumentListItem.fromJson(el))
        .toList()
    );
  }

}

class XmFolderListItem {

  String uuid;
  String path;
  String name;
  String label;

  XmFolderListItem.fromJson(Map<String, dynamic> json)
  :
    uuid = json['uuid'],
    path = json['path'],
    name = json['name'],
    label = json['label']
  ;
}


class XmDocumentListItem {

  String uuid;
  String path;
  String name;
  Map<String, dynamic> document;

  XmDocumentListItem.fromJson(Map<String, dynamic> json)
  :
    uuid = json['uuid'],
    path = json['path'],
    name = json['name'],
    document = json['document'] as Map<String, dynamic>
  ;
}


class XmFacetResponse {
  bool success;
  String message;
  XmFacetItem facet;

  XmFacetResponse({
    required this.success,
    required this.message,
    required this.facet
  });

}

class XmFacetItem {
  XmConnection connection;
  String sourceFacet;
  String facetPath;
  String displayName;
  int totalCount;
  Map<String, dynamic> childFacets;
  List<Map<String, dynamic>> results;

  XmFacetItem({
    required this.connection,
    required this.sourceFacet,
    required this.facetPath,
    required this.displayName,
    required this.totalCount,
    required this.childFacets,
    required this.results
  });

}


/**
 * Options for use with `getFacetAtPath`
 */
class XmGetFacetAtPathOptions {

  bool namespace;
  List<String> fetch;
  int limit;
  int offset;
  bool sorted;

  XmGetFacetAtPathOptions({
    this.namespace = false,
    this.fetch = const <String>[],
    this.limit = 0,
    this.offset = 50,
    this.sorted = false
  });
}

enum XmCollectionPutItemBehavior {
  merge,
  overwrite,
  failIfExists
  ;
}

class XmImageFocusValue {
  double x;
  double y;

  XmImageFocusValue({required this.x, required this.y});

  XmImageFocusValue.fromJson(Map<String, dynamic> json)
  :
    x = json['x'],
    y = json['y']
  ;
}