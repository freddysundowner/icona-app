import 'dart:convert';

import 'package:tokshop/main.dart';

import 'client.dart';
import 'end_points.dart';

class ProductPI {
  static updateProduct(
      Map<String, dynamic> productdata, String productid) async {
    var response = await DbBase().databaseRequest(
        updateproduct + productid, DbBase().putRequestType,
        body: productdata);
    return jsonDecode(response);
  }

  getProductById(String productId) async {
    var productres = await DbBase()
        .databaseRequest(updateproduct + productId, DbBase().getRequestType);
    return jsonDecode(productres);
  }

  static String getPathForProductImage(String id, int index) {
    String path = "products/images/$id";
    return "${path}_$index";
  }

  static saveProduct(Map<String, dynamic> productdata) async {
    var response = await DbBase().databaseRequest(
        product + authController.usermodel.value!.id!, DbBase().postRequestType,
        body: productdata);
    return jsonDecode(response);
  }

  static getAllroducts(String page,
      {String title = "",
      String userid = "",
      String roomid = "",
      String saletype = "",
      String category = "",
      String status = "",
      String limit = "15",
      bool featured = false}) async {
    var respinse = await DbBase().databaseRequest(
        '$product?userid=$userid&roomid=$roomid&saletype=$saletype&category=$category&page=$page&limit=$limit${title == "" ? "" : "&title=$title"}&featured=$featured&status=$status',
        DbBase().getRequestType);
    return jsonDecode(respinse);
  }

  static updateProductsImages(String productId, List<dynamic> imgUrl) async {
    var respinse = await DbBase().databaseRequest(
        updateproductimages + productId, DbBase().putRequestType,
        body: {"images": imgUrl});
    return jsonDecode(respinse);
  }

  static followCagory(String userid, String id) async {
    var respinse = await DbBase().databaseRequest(
        followcategory + id, DbBase().putRequestType,
        body: {'userid': userid});
    return jsonDecode(respinse);
  }

  static unfollowCagory(String userid, String id) async {
    var respinse = await DbBase().databaseRequest(
        unfollowcategory + id, DbBase().putRequestType,
        body: {'userid': userid});
    return jsonDecode(respinse);
  }

  static getCategories(
      {String? page, String? title, String? limit, String? type}) async {
    var categories = await DbBase().databaseRequest(
        '$category?page=$page&title=$title&limit=$limit&type=$type',
        DbBase().getRequestType);
    return jsonDecode(categories);
  }

  static updateManyProducts(
      List<String?> list, Map<String, dynamic> payload) async {
    print({"ids": list, 'payload': payload});
    var reviews = await DbBase().databaseRequest(
        updatemany, DbBase().putRequestType,
        body: {"ids": list, 'payload': payload});
    return jsonDecode(reviews);
  }

  static deleteProductAution(String roomid, String productid) {}

  // static importShopify() async {
  //   var response = await DbBase().databaseRequest(
  //     importshopify,
  //     DbBase().postRequestType,
  //     body: {'userid': authController.usermodel.value!.id},
  //   );
  //   return jsonDecode(response);
  // }

  static importWcPproducts() async {
    var response = await DbBase().databaseRequest(
      importwc,
      DbBase().postRequestType,
      body: {'userid': authController.usermodel.value!.id},
    );
    return jsonDecode(response);
  }

  static deleteProduct(List<String?> products) async {
    var response = await DbBase().databaseRequest(
      "${product}deletemany",
      DbBase().deleteRequestType,
      body: {"ids": products},
    );
    return jsonDecode(response);
  }
}
