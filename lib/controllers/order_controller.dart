import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tokshop/models/Review.dart';
import 'package:tokshop/models/dispute.dart';
import 'package:tokshop/pages/activities/dispute_progress.dart';

import '../models/order.dart';
import '../services/orders_api.dart';
import '../utils/functions.dart';
import '../widgets/loadig_page.dart';

class OrderController extends GetxController {
  var currentOrder = Order().obs;
  var dispute = Dispute().obs;
  var currentOrderLoading = false.obs;
  var ordersLoading = false.obs;
  var tabIndex = 0.obs;
  final userOrdersScrollController = ScrollController();
  var loadingReview = false.obs;
  RxList<Order> purchases = RxList([]);
  RxList<Order> orders = RxList([]);
  var tabs = [
    'all'.tr,
    'in_progress'.tr,
    'ready_to_ship'.tr,
    'shipped'.tr,
    'cancelled'.tr,
    'disputed'.tr,
    'refunded'.tr
  ];
  Rxn<Review> curentProductUserReview = Rxn(null);
  TextEditingController review = TextEditingController();
  var userOrdersPageNumber = 1.obs;

  var ratingvalue = 0.obs;
  var ratingError = "".obs;
  var loadingMoreUserOrders = false.obs;

  final selectedReason = RxString("wrong_item_received");

  var isSubmitting = false.obs;
  final detailsController = TextEditingController();

  final reasons = [
    {
      "value": "item_not_received",
      "label": "item_not_received".tr,
    },
    {
      "value": "wrong_item_received",
      "label": "wrong_item_received".tr,
    },
    {
      "value": "item_damaged",
      "label": "item_damaged".tr,
    },
    {'value': "seller_unresponsive", 'label': "seller_unresponsive".tr}
  ];

  Future<void> submitDispute(Order order) async {
    if (selectedReason.isEmpty) {
      Get.snackbar("error".tr, "please_select_reason".tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }

    isSubmitting.value = true;

    var data = {
      "orderId": order.id,
      "userId": order.customer?.id,
      "reason": selectedReason.value,
      "details": detailsController.text,
    };
    var response = await OrderApi.submitDispute(data);

    if (response != null) {
      Order order = Order.fromJson(response);
      int orderIndex =
          purchases.indexWhere((element) => element.id == order.id);
      purchases[orderIndex] = order;
    }

    isSubmitting.value = false;
    Get.back(); // Close page
    Get.back(); // Close page
    Get.to(() => DisputeProgressPage(order: order));
  }

  String getReasonLabel(String? value, List<Map<String, String>> reasons) {
    final reason = reasons.firstWhere(
      (r) => r['value'] == value,
      orElse: () => {"label": ""},
    );
    return reason['label'] ?? "";
  }

  loadMoreOrders() async {
    try {
      loadingMoreUserOrders.value = true;
      var orders = await OrderApi.getOrders(
        userId: FirebaseAuth.instance.currentUser!.uid,
      );

      if (orders != null) {
        orders.addAll(orders.map((e) => Order.fromJson(e)).toList());
      }

      loadingMoreUserOrders.value = false;
    } catch (e, s) {
      loadingMoreUserOrders.value = false;
    }
  }

  void orderScrollControllerListener() {
    userOrdersScrollController.addListener(() {
      if (userOrdersScrollController.position.atEdge) {
        bool isTop = userOrdersScrollController.position.pixels == 0;
        if (isTop) {
          printOut('At the top');
        } else {
          userOrdersPageNumber.value = userOrdersPageNumber.value + 1;
          loadMoreOrders();
        }
      }
    });
  }

  getOrder(Order order) async {
    if (order.id != null) {
      currentOrderLoading.value = true;
      var response = await OrderApi.getOrderById(order.id!);
      currentOrder.value = Order.fromJson(response);
      currentOrder.refresh();
      currentOrderLoading.value = false;
    }
  }

  getOrders(
      {String? userId = "",
      String orderId = "",
      String tokshow = "",
      String customer = "",
      String status = ""}) async {
    try {
      ordersLoading.value = true;
      var response = await OrderApi.getOrders(
          userId: userId,
          orderId: orderId,
          customer: customer,
          status: status,
          tokshow: tokshow);
      List list = response["orders"];
      if (customer.isNotEmpty) {
        purchases.value = list.map((e) => Order.fromJson(e)).toList();
        purchases.refresh();
      } else {
        orders.value = list.map((e) => Order.fromJson(e)).toList();
        orders.refresh();
      }
      ordersLoading.value = false;
    } catch (e, s) {
      ordersLoading.value = false;
    }
  }

  void generateLabel(Map<String, dynamic> data, BuildContext context) async {
    try {
      LoadingOverlay.showLoading(context);
      await OrderApi.generateLabel(data);
      await getOrder(Order(id: data["order"]));
      LoadingOverlay.hideLoading(context);
    } catch (e, s) {
      printOut("Error printing label $e $s");
    }
  }

  Future<void> updateStatus(
      String status, Order order, BuildContext context) async {
    try {
      LoadingOverlay.showLoading(context);
      OrderApi().updateOrder({"status": status}, order.id!).then((value) async {
        await getOrder(order);
        Get.back();
        LoadingOverlay.hideLoading(context);
        Get.dialog(
          AlertDialog(
            content: Text('order_status_updated'.tr),
            actions: [
              TextButton(
                child: Text('ok'.tr),
                onPressed: () {
                  Get.back();
                },
              )
            ],
          ),
        );
      });
    } catch (e, s) {
      LoadingOverlay.hideLoading(context);
    }
  }

  void getOrderDispute(Order? order) async {
    LoadingOverlay.showLoading(Get.context!);
    var response = await OrderApi.getOrderDispute(order!.id!);
    LoadingOverlay.hideLoading(Get.context!);
    if (response != null) {
      dispute.value = Dispute.fromJson(response);
      dispute.refresh();
    }
  }

  submitDisputeResponse(String s, Map<String, dynamic> data) async {
    LoadingOverlay.showLoading(Get.context!);
    var response = await OrderApi.submitDisputeResponse(s, data);
    LoadingOverlay.hideLoading(Get.context!);
    if (response != null) {
      dispute.value = Dispute.fromJson(response);
      dispute.refresh();
    }
  }
}
