import 'dart:convert';

import 'package:tokshop/main.dart';

import '../utils/functions.dart';
import 'client.dart';
import 'end_points.dart';

class PaymentService {
  stripePaymentSetup() async {
    var response = await DbBase().databaseRequest(
        stripesetup, DbBase().postRequestType,
        body: {"email": authController.usermodel.value?.email});
    return jsonDecode(response);
  }

  savePaymentMethod(customerId) async {
    var response = await DbBase().databaseRequest(
        stripesavepaymentmethod, DbBase().postRequestType, body: {
      "customer_id": customerId,
      "userid": authController.usermodel.value?.id
    });
    return jsonDecode(response);
  }

  Future getPaymenyMethodByUserId(String id) async {
    try {
      var updated = await DbBase()
          .databaseRequest(paymentmethods + id, DbBase().getRequestType);

      return jsonDecode(updated);
    } catch (e, s) {
      printOut("Error updating user $e $s");
    }
  }

  static getTaxEstimate(Map<String, dynamic> map) async {
    var response = await DbBase()
        .databaseRequest(taxestimate, DbBase().postRequestType, body: map);
    return jsonDecode(response);
  }
}
