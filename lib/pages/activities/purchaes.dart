import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/order_controller.dart';
import 'package:tokshop/pages/activities/purchase_details.dart';
import 'package:tokshop/widgets/live/no_items.dart';

import '../../models/order.dart';
import 'widgets/order_card.dart';

class PurchasesScreen extends StatelessWidget {
  PurchasesScreen({super.key}) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var status = "";
      if (orderController.tabIndex.value == 1) {
        status = "processing";
      } else if (orderController.tabIndex.value == 5) {
        status = "disputed";
      } else if (orderController.tabIndex.value == 2) {
        status = "ready_to_ship";
      } else if (orderController.tabIndex.value == 3) {
        status = "shipped";
      } else if (orderController.tabIndex.value == 4) {
        status = "cancelled";
      } else if (orderController.tabIndex.value == 6) {
        status = "refunded";
      }
      orderController.getOrders(
          customer: FirebaseAuth.instance.currentUser!.uid, status: status);
    });
  }
  OrderController orderController = Get.put(OrderController());

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Obx(
              () => Wrap(
                spacing: 0,
                children: List.generate(
                  orderController.tabs.length,
                  (index) => InkWell(
                    splashColor: Colors.transparent,
                    onTap: () {
                      orderController.tabIndex.value = index;
                      var status = "";
                      if (index == 0) {
                        status = "";
                      } else if (index == 1) {
                        status = "processing";
                      } else if (index == 2) {
                        status = "ready_to_ship";
                      } else if (index == 5) {
                        status = "disputed";
                      } else if (index == 3) {
                        status = "shipped";
                      } else if (index == 4) {
                        status = "cancelled";
                      } else if (index == 6) {
                        status = "refunded";
                      }

                      orderController.getOrders(
                          customer: FirebaseAuth.instance.currentUser!.uid,
                          status: status);
                    },
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: orderController.tabIndex.value == index
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        orderController.tabs[index] == "in_progress"
                            ? "processing".tr
                            : orderController.tabs[index].tr,
                        style: orderController.tabIndex.value == index
                            ? Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: Theme.of(context).colorScheme.surface,
                                fontSize: 13)
                            : Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontSize: 13),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              return orderController.ordersLoading.isFalse
                  ? orderController.purchases.isNotEmpty
                      ? ListView.builder(
                          controller:
                              orderController.userOrdersScrollController,
                          itemCount: orderController.purchases.length,
                          itemBuilder: (context, index) {
                            Order purchase = orderController.purchases[index];
                            return InkWell(
                              onTap: () {
                                Get.to(PurchaseDetailsPage(
                                  order: purchase,
                                ));
                              },
                              child: OrderCard(
                                order: purchase,
                                theme: theme,
                              ),
                            );
                          })
                      : Center(child: NoItems(content: Text("no_purchases".tr)))
                  : const Center(
                      child: CircularProgressIndicator(),
                    );
            }),
          )
        ],
      ),
    );
  }
}
