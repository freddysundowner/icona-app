import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tokshop/controllers/order_controller.dart';
import 'package:tokshop/widgets/live/no_items.dart';

import '../../models/order.dart';
import '../../utils/helpers.dart';
import 'order_details_page.dart';

class OrdersScreen extends StatelessWidget {
  OrdersScreen({super.key}) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var status = "";
      if (orderController.tabIndex.value == 1) {
        status = "processing";
      } else if (orderController.tabIndex.value == 2) {
        status = "ready_to_ship";
      } else if (orderController.tabIndex.value == 3) {
        status = "shipped";
      } else if (orderController.tabIndex.value == 4) {
        status = "cancelled";
      }
      orderController.getOrders(
          userId: FirebaseAuth.instance.currentUser!.uid, status: status);
    });
  }
  OrderController orderController = Get.put(OrderController());

  @override
  Widget build(BuildContext context) {
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
                      if (index == 0) {
                        orderController.getOrders(
                            userId: FirebaseAuth.instance.currentUser!.uid);
                      } else if (index == 1) {
                        orderController.getOrders(
                            userId: FirebaseAuth.instance.currentUser!.uid,
                            status: 'processing');
                      } else if (index == 2) {
                        orderController.getOrders(
                            userId: FirebaseAuth.instance.currentUser!.uid,
                            status: 'ready_to_ship');
                      } else if (index == 3) {
                        orderController.getOrders(
                            userId: FirebaseAuth.instance.currentUser!.uid,
                            status: 'shipped');
                      } else if (index == 4) {
                        orderController.getOrders(
                            userId: FirebaseAuth.instance.currentUser!.uid,
                            status: 'cancelled');
                      }
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
                        orderController.tabs[index] == "In Progress"
                            ? "need_label".tr
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
            child: Obx(() => orderController.orders.isEmpty
                ? Center(child: NoItems(content: Text("no_orders".tr)))
                : ListView.builder(
                    itemCount: orderController.orders.length,
                    itemBuilder: (context, index) {
                      Order shipment = orderController.orders[index];
                      var date = DateFormat("MMM d").format(
                          DateTime.fromMillisecondsSinceEpoch(shipment.date!));
                      return ListTile(
                        leading: buildAvatar(
                            shipment.customer!.profilePhoto!.isEmpty
                                ? shipment.customer!.firstName
                                : shipment.customer!.profilePhoto),
                        title: Text(
                          shipment.customer?.firstName ?? "",
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shipment.customer!.userName!.isNotEmpty
                                  ? shipment.customer!.userName!
                                  : shipment.customer!.firstName!,
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface),
                            ),
                            if (shipment.ordertype != "giveaway")
                              Text(
                                "$date • ${shipment.items?.length} item(s) • \$${shipment.getOrderTotal()}",
                                style: const TextStyle(color: Colors.grey),
                              ),
                            if (shipment.ordertype == "giveaway")
                              Text(
                                "$date • ${shipment.giveaway?.quantity ?? 1} item(s) • \$${shipment.getOrderTotal()}",
                                style: const TextStyle(color: Colors.grey),
                              ),
                            if (shipment.status == "processing")
                              Text(
                                "ship_by".trParams({"date": "tommorrow"}),
                                style:
                                    TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            if (shipment.status == "disputed")
                              Text(
                                "order_disputed".tr,
                                style:
                                    TextStyle(color: Colors.red, fontSize: 12),
                              ),
                          ],
                        ),
                        trailing: _order_status(shipment),
                        onTap: () {
                          Get.to(() => ShipmentDetailsPage(order: shipment));
                        },
                      );
                    },
                  )),
          )
        ],
      ),
    );
  }

  _order_status(Order shipment) {
    if (shipment.status == "cancelled") {
      return Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          shipment.status ?? "",
          style: TextStyle(color: Colors.white, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (shipment.status == "shipped") {
      return Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          shipment.status ?? "",
          style: TextStyle(color: Colors.white, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      );
    }
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: shipment.status == "disputed" ? Colors.red : Colors.grey[800],
        borderRadius: BorderRadius.circular(6),
      ),
      child: shipment.status == "disputed"
          ? Text(
              "disputed".tr,
              style: TextStyle(color: Colors.white, fontSize: 12),
              textAlign: TextAlign.center,
            )
          : shipment.need_label == true
              ? Text(
                  "need_label".tr,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                  textAlign: TextAlign.center,
                )
              : Text(
                  "ready_to_ship".tr,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
    );
  }
}
