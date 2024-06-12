import 'dart:convert';

import 'xm_connection.dart';
import 'xm_models.dart';

/**
 * Xinmods Image implementation
 */
class XmImage {

  XmConnection connection;
  XmDocumentLocation info;
  Map<String, dynamic>? imageInfo;
  List<String> operations;
  String? externalSrc;

  /**
   * Initialise image
   */
  XmImage({
    required this.connection,
    required this.info,

    this.imageInfo,
    this.externalSrc
  }) : operations = [];

  /**
   * Clone the object
   */
  XmImage clone() {
    return XmImage(
      connection: connection,
      info: info,
      imageInfo: this.imageInfo,
      externalSrc: this.externalSrc
    );
  }


  XmImage reset() {
    this.operations.clear();
    return this;
  }

  XmImage greyscale() {
    this.operations.add("filter=greyscale");
    return this;
  }

  XmImage quality(double quality) {
    this.operations.add("quality=${quality.toStringAsFixed(2)}");
    return this;
  }

  XmImage scaleWidth(int width) {
    this.operations.add("scale=$width");
    return this;
  }

  XmImage scaleHeight(int height) {
    this.operations.add("scale=$height");
    return this;
  }

  /**
   * Get a focus value
   */
  XmImageFocusValue getFocusValue() {
    var focusJson = this.imageInfo?['items']?['focus'];
    if (focusJson == null) {
      return XmImageFocusValue(x: 0, y: 0);
    }

    return XmImageFocusValue.fromJson(jsonDecode(focusJson));
  }

  /**
   * Add a crop operation
   */
  XmImage crop(int width, int height) {
    var focus = this.getFocusValue();
    this.operations.add("crop=$width,$height,${focus.x.toStringAsFixed(4)},${focus.y.toStringAsFixed(4)}");
    return this;
  }


  String toUrl() {
    var now = DateTime.now();
    var lastModifiedStr = this.imageInfo?['items']?['hippogallery:original']?['lastModified'];
    var lastMod = (
      lastModifiedStr != null
        ? DateTime.parse(lastModifiedStr).millisecondsSinceEpoch
        : now.millisecondsSinceEpoch
    );

    // no operations?
    if (this.operations.isEmpty) {
      if (this.connection.cdnUrl != null) {
        return "${connection.cdnUrl}/binaries${this.info.path}?v=$lastMod";
      }
      else {
        return "${connection.url}${connection.assetPath}${this.info.path}?v=$lastMod";
      }
    }

    var path = isExternal? "external/$externalSrc" : "binaries${this.info.path}";
    var opStr = this.operations.join("/");

    if (connection.cdnUrl != null) {
      return "${connection.cdnUrl}${connection.assetModPath}/$opStr/v=$lastMod/$path";
    }

    return "${connection.url}${connection.assetModPath}/$opStr/v=$lastMod/$path";
  }

  /**
   * return true if it's an external image.
   */
  get isExternal => this.externalSrc != null;


}