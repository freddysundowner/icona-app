import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';

import 'client.dart';
import 'end_points.dart';

class TransactionAPI {
  getUserTransactions(
      {String? page = "1",
      String limit = "15",
      String? userId = "",
      String? status = ""}) async {
    var transactions = await DbBase().databaseRequest(
        '$userTransactions?userId=$userId&page=$page&limit=$limit&status=$status',
        DbBase().getRequestType);

    return jsonDecode(transactions);
  }

  withdrawToBank(String amount) async {
    var response = await DbBase().databaseRequest(
        "$stripePayout/${FirebaseAuth.instance.currentUser!.uid}",
        DbBase().postRequestType,
        body: {
          "amount": amount,
        });
    return jsonDecode(response);
  }

  static getUserBank(String s) async {
    var response = await DbBase().databaseRequest(
        "$user/bank/${FirebaseAuth.instance.currentUser!.uid}",
        DbBase().getRequestType);
    return jsonDecode(response);
  }

  static getConnectedStripeBanks() async {
    var response = await DbBase().databaseRequest(
      "$stripeAccounts/${FirebaseAuth.instance.currentUser!.uid}",
      DbBase().getRequestType,
    );
    return jsonDecode(response);
  }

  static deleteBank() async {
    var response = await DbBase().databaseRequest(
        "$user/bank/${FirebaseAuth.instance.currentUser!.uid}",
        DbBase().deleteRequestType);
    return jsonDecode(response);
  }

  static stripeTransactions() async {
    var response = await DbBase().databaseRequest(
        "$striperansactions/${FirebaseAuth.instance.currentUser!.uid}",
        DbBase().getRequestType);
    return jsonDecode(response);
  }
}
