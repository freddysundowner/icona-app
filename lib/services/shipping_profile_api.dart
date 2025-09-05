import 'dart:convert';

import 'package:tokshop/main.dart';

import 'client.dart';
import 'end_points.dart';

class ShipppingProfileAPI {
  static Future createShippingProfile(
      {required Map<String, dynamic> body}) async {
    var response = await DbBase().databaseRequest(
        "$shippingprofiles/${authController.currentuser!.id}",
        DbBase().postRequestType,
        body: body);
    return jsonDecode(response);
  }

  static deleteShippingProfile(id) async {
    var response = await DbBase()
        .databaseRequest("$shippingprofiles/$id", DbBase().deleteRequestType);
    return jsonDecode(response);
  }

  static updateShippingProfile(id, {required Map<String, Object> body}) async {
    var response = await DbBase().databaseRequest(
        "$shippingprofiles/$id", DbBase().putRequestType,
        body: body);
    return jsonDecode(response);
  }

  static getShippingProfilesByUserId(id) async {
    var response = await DbBase()
        .databaseRequest("$shippingprofiles/$id", DbBase().getRequestType);
    return jsonDecode(response);
  }

  static getShippingEstimate(String productId) async {
    var response = await DbBase()
        .databaseRequest(shippingprofilesestimate, DbBase().getRequestType);
    return jsonDecode(response);
  }

  static getShippingEstimateData({Map<String, dynamic>? data}) async {
    var response = await DbBase().databaseRequest(
        shippingprofilesestimate, DbBase().getRequestType,
        body: data);
    return jsonDecode(response);
  }
}
