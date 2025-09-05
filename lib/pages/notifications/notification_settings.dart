import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/user_controller.dart';

class NotificationSettingsPage extends StatelessWidget {
  NotificationSettingsPage({super.key}) {
    userController.getnotificationSettings();
  }

  UserController userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('notification_settings'.tr),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (userController.notificationsettigs["notify_on_follow"] != null)
            Obx(
              () => _buildSwitchTile(
                title: "notify_on_follow".tr,
                context: context,
                value: userController.notificationsettigs["notify_on_follow"],
                onChanged: (val) {
                  userController.notificationsettigs["notify_on_follow"] = val;
                  userController.updateNotificationSettings();
                },
              ),
            ),
          if (userController.notificationsettigs["notify_on_message"] != null)
            Obx(
              () => _buildSwitchTile(
                  context: context,
                  title: "notify_on_message".tr,
                  value:
                      userController.notificationsettigs["notify_on_message"],
                  onChanged: (val) {
                    userController.notificationsettigs["notify_on_message"] =
                        val;
                    userController.updateNotificationSettings();
                  }),
            ),
          if (userController.notificationsettigs["notify_on_order"] != null)
            Obx(
              () => _buildSwitchTile(
                  context: context,
                  title: "notify_on_order".tr,
                  value: userController.notificationsettigs["notify_on_order"],
                  onChanged: (val) {
                    userController.notificationsettigs["notify_on_order"] = val;
                    userController.updateNotificationSettings();
                  }),
            ),
          if (userController.notificationsettigs["notify_on_live"] != null)
            Obx(
              () => _buildSwitchTile(
                  context: context,
                  title: "notify_on_live".tr,
                  value: userController.notificationsettigs["notify_on_live"],
                  onChanged: (val) {
                    userController.notificationsettigs["notify_on_live"] = val;
                    userController.updateNotificationSettings();
                  }),
            ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required BuildContext context,
  }) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).primaryColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
