import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';

import '../utils/utils.dart';
import 'client.dart';
import 'end_points.dart';

class OrderApi {
  static generateLabel(Map<String, dynamic> body) async {
    var response = await DbBase()
        .databaseRequest(buylabel, DbBase().postRequestType, body: body);
    return jsonDecode(response);
  }

  static getOrders(
      {String? userId = "",
      String? tokshow = "",
      String? customer = "",
      String orderId = "",
      String status = ""}) async {
    var respose = await DbBase().databaseRequest(
        "$orders?userId=$userId&orderId=$orderId&customer=$customer&status=$status&tokshow=$tokshow",
        DbBase().getRequestType);
    return jsonDecode(respose);
  }

  static getOrderById(String orderId) async {
    var order = await DbBase()
        .databaseRequest('$orders/$orderId', DbBase().getRequestType);
    return jsonDecode(order);
  }

  static checkOut(Map<String, dynamic> order) async {
    var response = await DbBase().databaseRequest(
        "$orders/${FirebaseAuth.instance.currentUser!.uid}",
        DbBase().postRequestType,
        body: order);

    return jsonDecode(response);
  }

  Future updateOrder(Map<String, dynamic> body, String id) async {
    try {
      var orderResponse = await DbBase()
          .databaseRequest("$orders/$id", DbBase().putRequestType, body: body);
      printOut("orderResponse $orderResponse");
    } catch (e) {
      printOut("Error updateOrder  $e");
    }
  }

  static submitDispute(Map<String, dynamic> data) async {
    var response = await DbBase().databaseRequest(
        "$dispute/${data['orderId']}", DbBase().postRequestType,
        body: data);
    return jsonDecode(response);
  }

  static getOrderDispute(String s) async {
    var response =
        await DbBase().databaseRequest("$dispute/$s", DbBase().getRequestType);
    return jsonDecode(response);
  }

  static submitDisputeResponse(String s, Map<String, dynamic> data) async {
    var response = await DbBase()
        .databaseRequest("$dispute/$s", DbBase().putRequestType, body: data);
    return jsonDecode(response);
  }
}
