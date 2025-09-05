import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/user_controller.dart';
import 'package:tokshop/models/user.dart';
import 'package:tokshop/pages/profile/tip/tip_payment.dart';
import 'package:tokshop/utils/helpers.dart';

import '../../../widgets/custom_button.dart';

class TipScreen extends StatelessWidget {
  UserModel user;
  TipScreen({super.key, required this.user});
  UserController userController = Get.find<UserController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('send_a_tip'.tr), // Translation with underscore key
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            Text(
              'choose_a_tip_amount'.tr,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 5.h),
            Text(
              'host_will_receive_tip'.tr,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 20.h),
            _buildTipOptions(), // Tip options
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomButton(
                  function: () {
                    Get.back();
                  },
                  text: 'cancel'.tr,
                  backgroundColor:
                      Theme.of(context).colorScheme.onSecondaryContainer,
                  textColor: Theme.of(context).colorScheme.onSurface,
                ),
                CustomButton(
                  function: () {
                    Get.to(() => TipPayment(userModel: user));
                  },
                  text: 'next'.tr,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  textColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipOptions() {
    final icons = [
      Icons.waving_hand,
      Icons.sentiment_satisfied,
      Icons.sentiment_very_satisfied,
      Icons.favorite,
      Icons.star,
      Icons.attach_money,
    ];

    return Obx(() {
      return Wrap(
        spacing: 20.w,
        runSpacing: 10.h,
        children: List.generate(userController.tipOptions.length, (index) {
          int tipAmount = userController.tipOptions[index];
          return GestureDetector(
            onTap: () {
              userController.selectedTip.value = tipAmount;
            },
            child: Container(
              width: 90.w,
              height: 90.h,
              decoration: BoxDecoration(
                color: Theme.of(Get.context!).colorScheme.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: userController.selectedTip.value == tipAmount
                      ? Theme.of(Get.context!).primaryColor
                      : Theme.of(Get.context!)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.2),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icons[index],
                    size: 28.sp,
                    color: Theme.of(Get.context!).primaryColor,
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    priceHtmlFormat(userController.tipOptions[index],
                        currency: "US\$"),
                    style: Theme.of(Get.context!).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          );
        }),
      );
    });
  }
}
