import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/give_away_controller.dart';

class GiveawayWidget extends StatelessWidget {
  GiveawayWidget({super.key});

  final GiveAwayController giveAwayController = Get.find<GiveAwayController>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            "who_can_enter".tr,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 20),

          // 🔹 Wrap each SettingToggleTile with Obx
          Obx(() => SettingToggleTile(
                title: "every_one".tr,
                subtitle: "every_one_description".tr,
                value: giveAwayController.whocanenter.value == 'everyone',
                onChanged: (val) =>
                    giveAwayController.whocanenter.value = 'everyone',
              )),

          Obx(() => SettingToggleTile(
                title: "followers".tr,
                subtitle: "followers_only_description".tr,
                value: giveAwayController.whocanenter.value == 'followers',
                onChanged: (val) =>
                    giveAwayController.whocanenter.value = 'followers',
              )),

          // Obx(() => SettingToggleTile(
          //       title: "international".tr,
          //       subtitle: "international_shipping_description".tr,
          //       value: giveAwayController.whocanenter.value == 'international',
          //       onChanged: (val) =>
          //           giveAwayController.whocanenter.value = 'international',
          //     )),
        ],
      ),
    );
  }
}

class SettingToggleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingToggleTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          // Toggle
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: Colors.green,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey[700],
          ),
        ],
      ),
    );
  }
}
