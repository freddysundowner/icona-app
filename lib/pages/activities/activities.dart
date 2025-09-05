import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tokshop/main.dart';
import 'package:tokshop/pages/activities/purchaes.dart';

import '../../controllers/order_controller.dart';
import '../../controllers/user_controller.dart';
import '../../widgets/custom_button.dart';
import '../chats/messages.dart';
import 'favorite_products.dart';
import 'friends.dart';
import 'orders.dart';

class Activities extends StatelessWidget {
  Activities({super.key});
  final UserController userController = Get.find<UserController>();
  final OrderController orderController = Get.find<OrderController>();

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    // ✅ Check seller approval
    bool isSellerApproved = authController.currentuser?.seller ?? false;

    // ✅ Build tabs dynamically
    final tabs = <Tab>[
      Tab(text: 'purchases'.tr),
      if (isSellerApproved) Tab(text: 'orders'.tr),
      Tab(text: 'messages'.tr),
      Tab(text: 'saved'.tr),
    ];

    final views = <Widget>[
      PurchasesScreen(),
      if (isSellerApproved) OrdersScreen(),
      AllChatsPage(showHeader: false),
      FavoriteProducts(),
    ];

    return DefaultTabController(
      length: tabs.length,
      initialIndex: userController.activityTabIndex.value < tabs.length
          ? userController.activityTabIndex.value
          : 0, // ✅ Prevent crash if index > length
      child: Scaffold(
        body: Column(
          children: [
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "activities".tr,
                  style: theme.textTheme.headlineSmall,
                ),
                SizedBox(
                  width: 30,
                ),
                Container(
                  margin: EdgeInsets.only(right: 10),
                  child: CustomButton(
                      text: "friends".tr,
                      iconData: Icons.people,
                      backgroundColor: theme.colorScheme.surface,
                      borderColor: theme.dividerColor,
                      iconColor: theme.colorScheme.onSurface,
                      width: 120,
                      function: () {
                        print("open friends");
                        Get.to(() => Friends(from: "activities"));
                      }),
                ),
              ],
            ),
            TabBar(
              isScrollable: true,
              indicatorColor: theme.colorScheme.primary,
              labelColor: theme.textTheme.bodyLarge!.color,
              unselectedLabelColor: theme.textTheme.bodyMedium!.color,
              labelPadding: EdgeInsets.symmetric(horizontal: 10),
              padding: EdgeInsets.zero,
              tabAlignment: TabAlignment.start,
              onTap: (i) {
                userController.activityTabIndex.value = i;

                // ✅ Only call order API if seller tab exists
                if (isSellerApproved && i == 1) {
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
                    userId: FirebaseAuth.instance.currentUser!.uid,
                    status: status,
                  );
                } else if (i == 0) {
                  // Purchases tab
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
                    customer: FirebaseAuth.instance.currentUser!.uid,
                    status: status,
                  );
                }
              },
              labelStyle: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
              tabs: tabs,
            ),
            Expanded(
              child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: TabBarView(children: views)),
            ),
          ],
        ),
      ),
    );
  }
}
