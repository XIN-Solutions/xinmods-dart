/*
  __  ___                           _        ____                            _   _
  \ \/ (_)_ __  _ __ ___   ___   __| |___   / ___|___  _ __  _ __   ___  ___| |_(_) ___  _ __
   \  /| | '_ \| '_ ` _ \ / _ \ / _` / __| | |   / _ \| '_ \| '_ \ / _ \/ __| __| |/ _ \| '_ \
   /  \| | | | | | | | | | (_) | (_| \__ \ | |__| (_) | | | | | | |  __/ (__| |_| | (_) | | | |
  /_/\_\_|_| |_|_| |_| |_|\___/ \__,_|___/  \____\___/|_| |_|_| |_|\___|\___|\__|_|\___/|_| |_|


  Purpose:

    To connect to a xinmods endpoint

*/


import 'xm_collection.dart';
import 'xm_image.dart';
import 'xm_models.dart';
import 'xm_remote_requests.dart';

class XmConnection {

  /**
   * Type of connection
   */
  XinmodsConnectionType connectionType;

  /**
   * Type of deployment
   */
  XinmodsDeploymentType deploymentType;

  /**
   * The url
   */
  String url;

  /**
   * Potential credentials
   */
  String? user;
  String? password;

  String? cdnUrl;

  /**
   * Initialise data-members
   */
  XmConnection({
    required this.connectionType,
    required this.deploymentType,
    required this.url,

    this.user,
    this.password,

    this.cdnUrl
  });

  get hippoApi => this.deploymentType == XinmodsDeploymentType.local ? "/site/api" : "/api";
  get xinApi => this.deploymentType == XinmodsDeploymentType.local ? "/site/custom-api" : "/api/xin";
  get assetPath => this.deploymentType == XinmodsDeploymentType.local ? "/site/binaries" : "/binaries";
  get assetModPath => this.deploymentType == XinmodsDeploymentType.local ? "/site/assetmod": "/assetmod";


  /**
   * List collections
   */
  Future<List<String>> listCollections() async {
    // get remote requests instance
    var remoteRequests = XmRemoteRequests(connection: this);

    // get the collections
    var response = await remoteRequests.get("$xinApi/collections/list", {});
    var successful = response?['success'] ?? false;
    if (!successful) {
      return [];
    }

    return (response?['collections'] as List).map((it) => it as String).toList();
  }

  /**
   * Get a collection instance
   */
  XmCollection getCollection(String name) {
    return XmCollection(
      connection: this,
      name: name
    );
  }

  /**
   * Execute a query and return the results
   */
  Future<XmQueryResult?> executeQuery(String query, {
    bool documents = true,
    bool namespace = false,
    List<String> fetch = const <String>[]
  }) async {

    var remoteRequests = XmRemoteRequests(connection: this);

    // get the response
    var response = await remoteRequests.get("$xinApi/content/query", {
      'query': query,
      'fetch': fetch
    });

    var successful = response?['success'] ?? false;
    if (!successful) {
      return null;
    }

    var queryResult = XmQueryResult.fromJson(response!, sanitise: !namespace);
    return queryResult;
  }

  /**
   * Get documents
   * LEGACY endpoint, might not need to implement.
   */
  Future<dynamic> getDocuments() {
    // <hippoApi>/documents
    throw UnimplementedError("getDocuments is not implemented yet");
  }

  /**
   * Get facet information at a particular path
   */
  Future<dynamic> getFacetAtPath(String facetPath, {String? childPath, XmGetFacetAtPathOptions? options}) {
    // <xinapi>/facets/get
    throw UnimplementedError("getFacetAtPath is not implemented yet");
  }

  Future<XmImage?> getImageFromLink(Map<String, dynamic> imageLink) async {
    throw UnimplementedError("getImageFromLink is not implemented yet");
  }


  /**
   * Get an image by its uuid
   */
  Future<XmImage?> getImageFromUuid(String uuid) async {
    var imagePath = await this.uuidToPath(uuid);
    if (imagePath == null) {
      return null;
    }

    var imageInfo = await this.getDocumentByUuid(uuid);

    return XmImage(
      connection: this,
      info: imagePath,
      imageInfo: imageInfo
    );
  }

  /**
   * Get the document by uuid
   */
  Future<Map<String, dynamic>?> getDocumentByUuid(String uuid, {bool namespace = false, List<String> fetch = const <String>[]}) async {
    var remoteRequests = XmRemoteRequests(connection: this);
    var response = await remoteRequests.get("$xinApi/content/document-with-uuid", {
      "uuid": uuid,
      "fetch": fetch
    });

    if (response == null) {
      return null;
    }

    var doc = response['document'] as Map<String, dynamic>;
    return doc;
  }

  /**
   * Get a document by path
   */
  Future<Map<String, dynamic>?> getDocumentByPath(String path, {bool namespace = false, List<String> fetch = const <String>[]}) async {
    var remoteRequests = XmRemoteRequests(connection: this);
    var response = await remoteRequests.get("$xinApi/content/document-at-path", {
      "path": path,
      "fetch": fetch
    });

    if (response == null) {
      return null;
    }

    var doc = response['document'] as Map<String, dynamic>;
    return doc;
  }

  /**
   * List all documents at a path
   */
  Future<XmDocumentList?> listDocuments(String path, {bool namespace = false, List<String> fetch = const <String>[]}) async {
    var remoteRequests = XmRemoteRequests(connection: this);
    var response = await remoteRequests.get("$xinApi/content/documents-list", {
      'path': path,
      'fetch': fetch
    });

    if (response is Map<String, dynamic>) {
      return XmDocumentList.fromJson(response);
    }

    return null;
  }

  /**
   * Translate a UUID to a path
   */
  Future<XmDocumentLocation?> uuidToPath(String uuid) async {
    var remoteRequests = XmRemoteRequests(connection: this);
    var response = await remoteRequests.get("$xinApi/content/uuid-to-path", {
      'uuid': uuid
    });

    if (response is! Map<String, dynamic>) {
      return null;
    }

    if (response['success'] == false) {
      return null;
    }

    return XmDocumentLocation.fromJson(response);
  }

  /**
   * Translate a path to a uuid
   */
  Future<XmDocumentLocation?> pathToUuid(String path) async {
    var remoteRequests = XmRemoteRequests(connection: this);
    var response = await remoteRequests.get("$xinApi/content/path-to-uuid", {
      'path': path
    });

    if (response is! Map<String, dynamic>) {
      return null;
    }

    if (response['success'] == false) {
      return null;
    }

    return XmDocumentLocation.fromJson(response);
  }


}

/**
 * Informs the structure of the api endpoint
 */
enum XinmodsDeploymentType {
  local,
  deployed;
}

/**
 * How we will acquire
 */
enum XinmodsConnectionType {
  jwt,
  credentials;
}