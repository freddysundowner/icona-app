import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/user_controller.dart';

class UserMetricsCard extends StatelessWidget {
  ThemeData theme;
  UserMetricsCard({super.key, required this.theme});

  final UserController _userController = Get.find<UserController>();
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMetricItem(
                (_userController.curentUserReview.isEmpty
                        ? 0.toDouble()
                        : _userController.curentUserReview
                                .map((e) => e.rating)
                                .toList()
                                .reduce((value, element) => value + element) /
                            _userController.curentUserReview.length)
                    .toString(),
                'rating'.tr,
                theme,
                context),
            _buildMetricItem(
                _userController.curentUserReview.value.length.toString(),
                'reviews'.tr,
                theme,
                context),
            _buildMetricItem(_userController.currentProfile.value.salescount!,
                'sold'.tr, theme, context),
            // _buildMetricItem('Avg 2 days', 'ship_time'.tr, theme),
          ],
        ),
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
