import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tokshop/widgets/slogan_icon_card.dart';

import '../controllers/payment_controller.dart';
import '../main.dart';
import '../pages/payments/add_payment_method.dart';
import '../pages/profile/address_details_form.dart';
import 'content_card_two.dart';

void showCustomBottomSheet(BuildContext context, title) {
  final PaymentController paymentController = Get.find<PaymentController>();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                "payments_shipping_desc".trParams({'app_name': 'app_name'.tr}),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            SizedBox(height: 20),
            Obx(() => userController.gettingAddress.isTrue
                ? Center(child: CircularProgressIndicator())
                : authController.usermodel.value!.address != null
                    ? ContentCardTwo(
                        title: 'delivery_method'.tr,
                        icon: Icons.local_shipping,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .onSecondary
                            .withOpacity(0.1),
                        iconColor: Theme.of(context).colorScheme.onSurface,
                        content:
                            '${authController.usermodel.value!.address?.name}\n${authController.usermodel.value!.address?.addrress1}\n${authController.usermodel.value!.address?.city}\n${authController.usermodel.value!.address?.country}',
                        onEdit: () {
                          Get.back();
                          Get.to(() => AddressDetailsForm(
                                showsave: true,
                                addressToEdit:
                                    authController.usermodel.value!.address,
                              ));
                        },
                      )
                    : InkWell(
                        onTap: () {
                          Get.back();
                          Get.to(() => AddressDetailsForm(
                                showsave: true,
                              ));
                        },
                        child: SloganIconCard(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .onSecondary
                              .withOpacity(0.1),
                          rightIconStyle:
                              Theme.of(context).colorScheme.onSurface,
                          slogan: 'delivery_method_subtext'.tr,
                          title: 'delivery_method'.tr,
                          leftIcon: Icons.delivery_dining_outlined,
                          rightIcon: Icons.arrow_forward_ios_outlined,
                        ),
                      )),
            SizedBox(height: 16),

            // Payment Method
            Obx(() => paymentController.loading.isTrue
                ? Center(child: CircularProgressIndicator())
                : paymentController.paymentMethods.isNotEmpty
                    ? ContentCardTwo(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .onSecondary
                            .withOpacity(0.1),
                        iconColor: Theme.of(context).colorScheme.onSurface,
                        title: 'payment_method'.tr,
                        icon: Icons.account_balance_wallet,
                        content:
                            "${paymentController.paymentMethods.first.name} - ${paymentController.paymentMethods.first.last4} - ${paymentController.paymentMethods.first.expiraydate}",
                        onEdit: () {
                          Get.to(() => AddPaymetMethods());
                        },
                      )
                    : InkWell(
                        onTap: () {
                          Get.to(() => AddPaymetMethods());
                        },
                        child: SloganIconCard(
                          slogan: 'payment_info'.tr,
                          title: 'payment_method'.tr,
                          leftIcon: Icons.payment,
                          rightIcon: Icons.arrow_forward_ios_outlined,
                        ),
                      )),
            SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}
