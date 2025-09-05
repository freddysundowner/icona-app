import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:get/get.dart';
import 'package:tokshop/models/shippingMethods.dart';

import '../models/checkout.dart';
import '../models/product.dart';
import '../pages/homescreen.dart';
import '../pages/success_page.dart';
import '../services/orders_api.dart';
import '../services/payment.dart';
import '../utils/utils.dart';
import '../widgets/loadig_page.dart';
import 'global.dart';

class CheckOutController extends GetxController
    with GetSingleTickerProviderStateMixin {
  Rxn<Product> product = Rxn();
  Rxn<Checkout> order = Rxn();
  RxInt qty = 0.obs;
  RxInt selectetedvariation = 0.obs;
  RxString selectetedvariationvalue = "".obs;
  RxDouble ordertotal = 0.0.obs;
  RxInt shipping = 0.obs;
  RxBool submitready = false.obs;
  Rxn<ShippingMethods> shippingMethd = Rxn(null);
  RxString checkoutMethod = "".obs;
  var msg = "".obs;
  RxString tax = ''.obs;
  var tabIndex = 0.obs;
  final formKey = GlobalKey<FormState>();
  Rxn<TabController> tabController = Rxn(null);

  final TextEditingController addressReceiverFieldController =
      TextEditingController();

  final TextEditingController addressLine1FieldController =
      TextEditingController();

  final TextEditingController addressLine2FieldController =
      TextEditingController();

  TextEditingController cityFieldController = TextEditingController();
  TextEditingController postalCodeFieldController = TextEditingController();
  TextEditingController phoneNumberFieldController = TextEditingController();
  TextEditingController countryFieldController = TextEditingController();
  TextEditingController countryCodeFieldController = TextEditingController();
  TextEditingController emailFieldController = TextEditingController();

  TextEditingController stateFieldController = TextEditingController();

  final TextEditingController phoneFieldController = TextEditingController();

  clearAddressTextControllers() {
    addressReceiverFieldController.clear();
    addressLine1FieldController.clear();
    addressLine2FieldController.clear();
    cityFieldController.clear();
    stateFieldController.clear();
    countryFieldController.clear();
    countryFieldController.clear();
  }

  @override
  void onInit() {
    super.onInit();
    tabController.value = TabController(
      initialIndex: tabIndex.value,
      length: 4,
      vsync: this,
    );
  }

  Future<void> checkStripeStatus(String clientSecret,
      {Function? completeOrder}) async {
    await stripe.Stripe.instance
        .retrievePaymentIntent(clientSecret)
        .then((value) async {
      if (value.status.name == "Succeeded") {
        try {
          if (completeOrder != null) {
            completeOrder();
          } else {
            // await saveOrder("processing");
          }

          return true;
        } catch (e, s) {
          printOut("Error stripe $e, $s");
        }
      } else if (value.status.name == "requires_payment_method") {
        await checkStripeStatus(clientSecret);
      } else if (value.status.name == "requires_confirmation") {
        await checkStripeStatus(clientSecret);
      } else if (value.status.name == "requires_action") {
        await checkStripeStatus(clientSecret);
      } else if (value.status.name == "processing") {
        await checkStripeStatus(clientSecret);
      }
    });
  }

  Future<void> saveOrder(payload, BuildContext context, Product product) async {
    LoadingOverlay.showLoading(context);
    final orderFuture = OrderApi.checkOut(payload);

    orderFuture.then((response) async {
      if (response["success"] == true) {
        shipping.value = 0;
        checkoutMethod.value = "";
        tabIndex.value = 0;
        shippingMethd.value = null;
        ordertotal.value = 0;
        try {
          Get.back();
          LoadingOverlay.hideLoading(context);
          Get.to(() => SuccessPage(
                title: "order_completed".tr,
                functionbtnone: () {},
                functionbtntwo: () {
                  Get.find<GlobalController>().tabPosition.value = 2;
                  Get.to(() => HomeScreen());
                },
                buttonTwotext: 'view_order'.tr,
              ));
        } finally {
          // LoadingOverlay.hideLoading(context);
        }
      } else {
        Get.showSnackbar(
          GetSnackBar(
            message: response["message"],
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
          ),
        );
        LoadingOverlay.hideLoading(context);
      }
    }).catchError((e, s) {
      print("$e, $s");
      LoadingOverlay.hideLoading(context);
    });
  }

  void getTaxEstimate(Map<String, dynamic> map) async {
    try {
      var response = await PaymentService.getTaxEstimate(map);
      if (response == null) {
        tax.value = '0';
        return;
      }
      tax.value = response['amount'].toString();
      tax.refresh();
    } catch (e, s) {
      printOut("Error stripe $e, $s");
    }
  }
}
