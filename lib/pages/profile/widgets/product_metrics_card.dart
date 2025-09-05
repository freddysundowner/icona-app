import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tokshop/pages/chats/chat_room_page.dart';
import 'package:tokshop/widgets/show_image.dart';

import '../../../controllers/chat_controller.dart';
import '../../../controllers/user_controller.dart';
import '../../../models/product.dart';

class ProductMetricsCard extends StatelessWidget {
  ThemeData theme;
  Product product;
  ProductMetricsCard({super.key, required this.theme, required this.product});

  final UserController _userController = Get.find<UserController>();
  final ChatController _chatController = Get.find<ChatController>();

  @override
  Widget build(BuildContext context) {
    return _buildMetrics(theme, context);
  }

  Widget _buildMetrics(ThemeData theme, BuildContext context) {
    return Card(
      shadowColor: Colors.transparent,
      color: Theme.of(context)
          .colorScheme
          .onSecondaryContainer
          .withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSecondaryContainer,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Row(
                  children: [
                    ShowImage(
                      image: product.ownerId?.profilePhoto ?? '',
                      height: 30,
                      width: 30,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(product.ownerId?.firstName ?? '',
                        style: theme.textTheme.headlineSmall!.copyWith(
                          fontWeight: FontWeight.bold,
                        ))
                  ],
                ),
                Spacer(),
                InkWell(
                  splashColor: Colors.transparent,
                  onTap: () {
                    _chatController.currentChat.value = [];
                    _chatController.currentChatId.value = "";
                    _chatController
                        .getPreviousChat(_userController.currentProfile.value);
                    Get.to(ChatRoomPage(_userController.currentProfile.value));
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.onSurface,
                    ),
                    child: Icon(
                      Icons.message,
                      size: 15,
                      color: theme.colorScheme.surface,
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricItem(
                    (product.reviews!.isEmpty
                            ? 0.toDouble()
                            : product.reviews!
                                    .map((e) => e.rating)
                                    .toList()
                                    .reduce(
                                        (value, element) => value + element) /
                                product.reviews!.length)
                        .toString(),
                    'rating'.tr,
                    theme,
                    context),
                _buildMetricItem(product.reviews!.length.toString(),
                    'reviews'.tr, theme, context),
                _buildMetricItem(
                    product.salescount.toString(), 'sold'.tr, theme, context),
                // _buildMetricItem('Avg 2 days', 'ship_time'.tr, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(
      String value, String label, ThemeData theme, BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall!.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface),
        ),
        Text(
          label,
          style: theme.textTheme.titleSmall!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
