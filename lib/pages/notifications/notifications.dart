import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/pages/activities/orders.dart';
import 'package:tokshop/pages/profile/view_profile.dart';
import 'package:tokshop/widgets/live/no_items.dart';

import '../../controllers/notifications_controller.dart';
import '../../controllers/room_controller.dart';
import '../../controllers/user_controller.dart';
import '../../models/notifications_model.dart';
import '../../models/tokshow.dart';
import '../../services/notifications_api.dart';
import '../../utils/utils.dart';

class Notifications extends StatelessWidget {
  final NotificationsController notificationsController =
      Get.find<NotificationsController>();
  final UserController userController = Get.find<UserController>();
  final TokShowController tokshowcontroller = Get.find<TokShowController>();

  Notifications({super.key}) {
    notificationsController.getUserNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          child: Icon(
            Icons.clear,
            color: theme.colorScheme.onSurface,
          ),
          onTap: () => Get.back(),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "notifications".tr,
              style: theme.textTheme.headlineSmall,
            ),
            InkWell(
              child: Text(
                'clear'.tr,
                style: theme.textTheme.labelSmall!
                    .copyWith(color: theme.colorScheme.error),
              ),
              onTap: () async {
                await showConfirmationDialog(
                  context,
                  "clear_all_notifications".tr,
                  function: () {
                    NotificationsAPI.deleteAllActivity(
                        {"userId": FirebaseAuth.instance.currentUser!.uid});
                    notificationsController.allNotifications.clear();
                    notificationsController.allNotifications.refresh();
                    Get.back();
                  },
                  positiveResponse: "yes".tr,
                  negativeResponse: "no".tr,
                );
              },
            ),
          ],
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: theme.appBarTheme.elevation,
        iconTheme: theme.appBarTheme.iconTheme,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await notificationsController.getUserNotifications();
        },
        child: Obx(() {
          if (notificationsController.allNotificationsLoading.isTrue) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            );
          }

          if (notificationsController.allNotifications.isEmpty) {
            return NoItems();
          }

          return ListView.builder(
            controller: notificationsController.notificationsScrollController,
            itemCount: notificationsController.allNotifications.length,
            itemBuilder: (context, index) {
              final NotificationModel activityModel =
                  NotificationModel.fromJson(
                      notificationsController.allNotifications[index]);

              return InkWell(
                splashColor: Colors.transparent,
                onTap: () {
                  switch (activityModel.type) {
                    case "ProfileScreen":
                      userController.getUserProfile(activityModel.actionkey!);
                      Get.to(() => ViewProfile(
                            user: activityModel.from!,
                          ));
                      break;
                    case "RoomScreen":
                      tokshowcontroller.currentRoom.value = Tokshow();
                      tokshowcontroller.joinRoom(activityModel.actionkey!);
                      break;
                    case "OrderScreen":
                      userController.getUserOrders();
                      Get.to(() => OrdersScreen());
                      break;
                    default:
                      break;
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      if (activityModel.imageurl != null)
                        CircleAvatar(
                          radius: 20,
                          backgroundImage:
                              NetworkImage(activityModel.imageurl!),
                        ),
                      SizedBox(width: 0.04.sw),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  activityModel.name!,
                                  style: theme.textTheme.bodyMedium!.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                Text(
                                  activityModel.getTime()!,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                            SizedBox(height: 0.01.sh),
                            Text(
                              activityModel.message!,
                              style: theme.textTheme.bodySmall,
                            ),
                            Divider(
                              color: theme.dividerColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
