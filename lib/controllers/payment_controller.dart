import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:tokshop/services/payment.dart';

import '../main.dart';
import '../models/payment_method.dart';
import '../services/client.dart';
import '../services/end_points.dart';
import '../utils/configs.dart';
import '../utils/functions.dart';
import '../widgets/loadig_page.dart';

class PaymentController extends GetxController {
  RxList<UserPaymentMethod> paymentMethods = RxList([]);
  RxBool loading = false.obs;
  Future<void> initializePaymentSheet(BuildContext context) async {
    // try {
    LoadingOverlay.showLoading(context);
    var response = await PaymentService().stripePaymentSetup();
    LoadingOverlay.hideLoading(context);
    print(response);
    final clientSecret = response['clientSecret'];
    final customer_id = response['customer_id'];
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        setupIntentClientSecret: clientSecret,
        style: ThemeMode.light,
        merchantDisplayName: 'tokshop',
      ),
    );

    // Display the Payment Sheet
    await presentPaymentSheet(customer_id);
    // } catch (e) {
    //   print(e);
    //   ScaffoldMessenger.of(Get.context!)
    //       .showSnackBar(SnackBar(content: Text('Error: $e')));
    // } finally {
    //   getPaymentMethodsByUserId(authController.usermodel.value!.id!);
    // }
  }

  Future<void> presentPaymentSheet(customer_id) async {
    try {
      await Stripe.instance.presentPaymentSheet();
      await PaymentService().savePaymentMethod(customer_id);
      getPaymentMethodsByUserId(authController.usermodel.value!.id!);

      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(content: Text('Card saved successfully!')),
      );
    } catch (e) {}
  }

  getPaymentMethodsByUserId(String userid) async {
    try {
      loading.value = true;
      var data = await PaymentService().getPaymenyMethodByUserId(userid);
      Get.back();
      loading.value = false;
      List response = data;
      paymentMethods.value =
          response.map((r) => UserPaymentMethod.toJson(r)).toList();
      authController.usermodel.value!.defaultpaymentmethod =
          paymentMethods.where((e) => e.primary == true).first;
    } catch (error) {
      loading.value = false;
      return null;
    }
  }

  payWithStripe(context, payload, Function callBack) async {
    LoadingOverlay.showLoading(context);

    var paymentIntent = await DbBase().databaseRequest(
        createIntentStripeUrl, DbBase().postRequestType,
        body: payload);

    var response = jsonDecode(paymentIntent);
    if (response["success"] == false) {
      LoadingOverlay.hideLoading(context);
      Get.showSnackbar(
        GetSnackBar(
          title: "Error",
          message: response['message'],
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      stripe.Stripe.publishableKey = stripePublishKey;
      stripe.Stripe.setReturnUrlSchemeOnAndroid = true;
      await stripe.Stripe.instance.initPaymentSheet(
          paymentSheetParameters: stripe.SetupPaymentSheetParameters(
              paymentIntentClientSecret: response["client_secret"],
              applePay: const PaymentSheetApplePay(
                merchantCountryCode: 'US',
              ),
              googlePay: PaymentSheetGooglePay(
                merchantCountryCode: 'US',
                testEnv: demo,
              ),
              style: themeController.currentThemeMode,
              merchantDisplayName: 'Pay',
              returnURL: "http://192.168.161.47:3000/return"));
      await stripe.Stripe.instance.presentPaymentSheet();
      if (response["client_secret"] != null) {
        stripe.Stripe.instance
            .retrievePaymentIntent(jsonDecode(paymentIntent)["client_secret"])
            .then((PaymentIntent value) {
          callBack(value);
          LoadingOverlay.hideLoading(context);
        });
      } else {
        Get.showSnackbar(
          GetSnackBar(
            title: "Error",
            message: response['message'],
            duration: const Duration(seconds: 3),
          ),
        );
        LoadingOverlay.hideLoading(context);
      }
    } catch (e, s) {
      LoadingOverlay.hideLoading(context);
      printOut("Error stripe $e, $s");
    }
  }
}
