import 'package:get/get.dart';
import 'package:tokshop/models/order.dart';
import 'package:tokshop/models/user.dart';

import '../main.dart';
import 'tokshow.dart';

class Transaction {
  Transaction(
      {required this.date,
      required this.id,
      this.order,
      this.availableOn,
      this.from,
      required this.to,
      required this.reason,
      required this.amount,
      required this.type,
      required this.deducting,
      required this.shopId,
      required this.orderId,
      required this.status,
      required this.stripeBankAccount});

  int date;
  String id;
  UserModel? from;
  UserModel to;
  String reason;
  int? availableOn;
  double amount;
  String type;
  bool deducting;
  String shopId;
  Order? order;
  String orderId;
  String status;
  String stripeBankAccount;

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        date: json["date"],
        id: json["_id"],
        from: UserModel.fromJson(json["from"] ?? {}),
        to: UserModel.fromJson(json["to"]),
        availableOn: json["availableOn"] ?? 0,
        reason: json["reason"],
        amount: isInteger(json["amount"]) == true
            ? json["amount"].toDouble()
            : json["amount"],
        type: json["type"],
        deducting: json["deducting"],
        shopId: json["shopId"] ?? "",
        orderId: json["orderId"] ?? "",
        status: json["status"] ?? "Completed",
        stripeBankAccount: json["stripeBankAccount"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "_id": id,
        "from": from,
        "to": to,
        "reason": reason,
        "amount": amount,
        "type": type,
        "deducting": deducting,
        "shopId": shopId,
        "orderId": orderId,
        "stripeBankAccount": stripeBankAccount
      };
  description() {
    if (type == "tip") {
      if (from?.id == authController.currentuser?.id) {
        return 'tip_sent_reason'.trParams({"name": to.firstName!});
      } else {
        return 'tip_received_reason'.trParams({"name": to.firstName!});
      }
    }
    if (type == "order") {
      if (from?.id == authController.currentuser?.id) {
        return "product_bought".tr;
      } else {
        return "product_purchase".tr;
      }
    }
    if (type == "refund") {
      return reason;
    }
    return "";
  }
}
