import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/user_controller.dart';
import 'package:tokshop/models/user.dart';
import 'package:tokshop/utils/helpers.dart';

import '../../../controllers/payment_controller.dart';
import '../../../main.dart';
import '../../../widgets/custom_button.dart';
import '../../payments/add_payment_method.dart';

class TipPayment extends StatelessWidget {
  UserModel userModel;
  TipPayment({super.key, required this.userModel}) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      paymentController
          .getPaymentMethodsByUserId(authController.usermodel.value!.id!);
    });
  }
  final PaymentController paymentController = Get.find<PaymentController>();
  final UserController userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('send_a_tip'.tr), // Translated title
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            _buildDetailRow(
                'tip_amount',
                priceHtmlFormat(userController.selectedTip.value.toString(),
                    currency: "US\$")),
            Divider(),
            SizedBox(height: 10.h),
            _buildEditableRow('payment'),
            Divider(),
            SizedBox(height: 10.h),
            _buildDetailRow(
                'subtotal',
                priceHtmlFormat(userController.selectedTip.value.toString(),
                    currency: "US\$")),
            SizedBox(height: 10.h),
            Divider(),
            SizedBox(height: 10.h),
            _buildInfoRow(
                'payment_processing_fee',
                priceHtmlFormat(tip_processing.toString(), currency: "US\$"),
                'fee_info'),
            SizedBox(height: 20.h),
            _buildTotalRow(),
            Spacer(),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String titleKey, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          titleKey.tr,
          style: Theme.of(Get.context!).textTheme.titleMedium,
        ),
        Text(
          value,
          style: Theme.of(Get.context!).textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget _buildEditableRow(String titleKey) {
    return Obx(
      () => InkWell(
        splashColor: Colors.transparent,
        onTap: paymentController.paymentMethods.isNotEmpty
            ? null
            : () {
                Get.to(() => AddPaymetMethods());
              },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              titleKey.tr,
              style: Theme.of(Get.context!).textTheme.titleMedium,
            ),
            Row(
              children: [
                if (paymentController.paymentMethods.isNotEmpty)
                  Text(
                    "${paymentController.paymentMethods.first.name} - ${paymentController.paymentMethods.first.last4} - ${paymentController.paymentMethods.first.expiraydate}",
                    style: Theme.of(Get.context!).textTheme.bodyMedium,
                  ),
                Icon(Icons.edit, size: 16.sp),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String titleKey, String value, String infoKey) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  titleKey.tr,
                  style: Theme.of(Get.context!).textTheme.titleMedium,
                ),
                SizedBox(width: 5.w),
                Icon(
                  Icons.info_outline,
                  size: 16.sp,
                  color: Theme.of(Get.context!).colorScheme.onSurface,
                ),
              ],
            ),
            Text(
              value,
              style: Theme.of(Get.context!).textTheme.titleMedium,
            ),
          ],
        ),
        SizedBox(height: 5.h),
        Text(
          infoKey.tr,
          style: Theme.of(Get.context!).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildTotalRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'total'.tr,
              style: Theme.of(Get.context!).textTheme.headlineMedium,
            ),
            Text(
              priceHtmlFormat(
                  (tip_processing + userController.selectedTip.value)
                      .toString(),
                  currency: "US\$"),
              style: Theme.of(Get.context!).textTheme.headlineMedium,
            ),
          ],
        ),
        SizedBox(height: 5.h),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomButton(
          function: () {
            Get.back();
          },
          text: 'cancel'.tr,
          backgroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
          textColor: Theme.of(context).colorScheme.onSurface,
        ),
        CustomButton(
          function: () async {
            if (paymentController.paymentMethods.isEmpty) {
              SnackBar(
                content: Text("Please select a payment method first!"),
              );
            } else {
              await userController.saveUserTipTransaction({
                "amount": userController.selectedTip.value.toString(),
                'from': FirebaseAuth.instance.currentUser!.uid,
                'to': userModel.id,
                'note': "tip",
              }, context, user: userModel.firstName!);
            }
          },
          text: 'next'.tr,
          backgroundColor: Theme.of(context).colorScheme.primary,
          textColor: Theme.of(context).colorScheme.onPrimary,
        ),
      ],
    );
  }
}
