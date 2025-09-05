import 'dart:convert';

import 'client.dart';
import 'end_points.dart';

class GiveAwayApi {
  static getGiveAways(
      {String? name = "",
      String? page = "1",
      String? limit = "20",
      String? room}) async {
    var response = await DbBase().databaseRequest(
        '$giveaways?name=$name&page=$page&limit=$limit&room=$room',
        DbBase().getRequestType);
    return jsonDecode(response);
  }

  static saveGiveAway(Map<String, dynamic> productdata) async {
    var response = await DbBase().databaseRequest(
        giveaways, DbBase().postRequestType,
        body: productdata);
    return jsonDecode(response);
  }

  static updateGiveAway(Map<String, dynamic> productdata) async {
    var response = await DbBase().databaseRequest(
        '$giveaways/${productdata["id"]}', DbBase().putRequestType,
        body: productdata);
    return jsonDecode(response);
  }

  static updateGiveAwayImages(id, List<String> urls) async {
    var response = await DbBase().databaseRequest(
        '$giveaways/$id', DbBase().putRequestType,
        body: {"images": urls});
    return jsonDecode(response);
  }

  static getGiveAwayById(String? id) async {
    var response = await DbBase()
        .databaseRequest('$giveaways/$id', DbBase().getRequestType);
    return jsonDecode(response);
  }

  static deleteGiveAway(String string) async {
    var response = await DbBase()
        .databaseRequest('$giveaways/$string', DbBase().deleteRequestType);
    return jsonDecode(response);
  }
}
