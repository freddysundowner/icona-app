import 'dart:convert';

import 'package:tokshop/services/client.dart';
import 'package:tokshop/services/end_points.dart';
import 'package:tokshop/utils/functions.dart';

class AuctinAPI {
  Future createAuction(Map<String, dynamic> body) async {
    try {
      var auctionresponse = await DbBase()
          .databaseRequest(auction, DbBase().postRequestType, body: body);
      var decodedResponse = jsonDecode(auctionresponse);
      return decodedResponse;
    } catch (e, s) {
      printOut("$e $s");
    }
  }

  bid(payload, id) async {
    try {
      var auctionresponse = await DbBase().databaseRequest(
          "$auctionbid/$id", DbBase().putRequestType,
          body: payload);
      var decodedResponse = jsonDecode(auctionresponse);
      return decodedResponse;
    } catch (e, s) {
      printOut("$e $s");
    }
  }

  getAllAuctions({String? roomId, String? status = ""}) async {
    try {
      var auctionresponse = await DbBase().databaseRequest(
          "$auction?tokshow=$roomId&status=$status", DbBase().getRequestType);
      var decodedResponse = jsonDecode(auctionresponse);
      return decodedResponse;
    } catch (e, s) {
      printOut("$e $s");
    }
  }
}
