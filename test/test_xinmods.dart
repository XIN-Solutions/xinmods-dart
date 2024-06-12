// ignore_for_file: unnecessary_null_comparison

import 'package:flutter_test/flutter_test.dart';
import 'package:xinmods/src/xm_collection.dart';
import 'package:xinmods/src/xm_connection.dart';
import 'package:xinmods/src/xm_query_builder.dart';

void main() async {
  var conn = XmConnection(
      connectionType: XinmodsConnectionType.credentials,
      deploymentType: XinmodsDeploymentType.local,
      url: "http://localhost:8080",
      user: "admin",
      password: "admin"
  );

  //
  //  List all collections
  //
  test("list all collections", () async {
    var collections = await conn.listCollections();
    print(collections);
  });


  test("execute a query", () async {

    var queryResult = await conn.executeQuery("""
      (query 
        (type with-subtypes 'xinmods:pageinfo')
        (limit 10)
        (scopes
          (include '/content/documents')
        )
      )          
    """);

    assert(queryResult != null);
  });

  test("transform uuid to path", () async {
    var path = await conn.uuidToPath("3191b3e7-496f-4891-995c-fa3588aa5345");
    assert(path != null);
  });

  test("transform path to uuid", () async {
    var uuid = await conn.pathToUuid("/content/documents/acoustix/pages/home/page");
    assert(uuid != null);
  });

  test("list documents", () async {
    var docs = await conn.listDocuments("/content/documents/acoustix/pages");
    assert(docs != null);
  });

  test("images", () async {
    var image = await conn.getImageFromUuid("df729da5-2c8c-4167-a412-37504841b0e8");
    assert(image != null);

    image!.greyscale().crop(300, 300);

    var url = image.toUrl();
    assert(url != null);
  });

  test("document by path", () async {
    var doc = await conn.getDocumentByPath("/content/documents/acoustix/pages/home/page");
    assert(doc != null);
  });

  test("document by id", () async {
    // 3191b3e7-496f-4891-995c-fa3588aa5345
    var doc = await conn.getDocumentByUuid("3191b3e7-496f-4891-995c-fa3588aa5345");
    assert(doc != null);
  });

  test("collection: get item", () async {
    var coll = conn.getCollection("shop");
    var item = await coll.getItem("acoustix/customers/m/a/marnix@xinsolutions-co-nz");
    assert(item != null);
  });

  test("collection: delete item", () async {
    var coll = conn.getCollection("shop");
    var success = await coll.deleteItem("acoustix/customers/d", forceDelete: true);
    assert(success);
  });

  test("collection: put item", () async {
    var coll = conn.getCollection("shop");
    var success = await coll.putAndMerge("test", {
      'some': 'Content',
      'for': 10,
      'wondering': true,
    });

    assert(success);
  });

  test("query builder", () {

    var testThen = false;

    print(
      XmQuery(
        connection: conn,
        typeName: "xinmods:pageinfo",

        includes: ['/content/documents', '/content/gallery'],
        excludes: ['/content/documents/test'],
        sortBy: XmQuerySort(field: "xinmods:title", direction: XmQuerySortDirection.Ascending),
        offset: 0,
        limit: 10,
        withSubtypes: true,
      )
      .where((clause) =>
        clause.and()
          .isNull("nRatings")
          .equals("title", "Test Title")
          .contains("description", "Information")
          .ifThenElse(testThen,
            (clause) => clause.lte("age", 30),
            (clause) => clause.gte("age", 18)
          )
        .end()
      )
      .build()
    );
  });

  test("collection query", () async {
    var coll = XmCollection(connection: conn, name: "shop");

    String query =
      coll.query("acoustix/orders")
        .where((clause) => clause.equals("xinmods:type", "xs_order"))
        .build();

    var result = await conn.executeQuery(query);
    assert(result != null);
  });

}