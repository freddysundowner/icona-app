import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/auth_controller.dart';
import 'package:tokshop/controllers/payment_controller.dart';
import 'package:tokshop/controllers/user_controller.dart';

import '../../widgets/slogan_icon_card.dart';

//ignore: must_be_immutable
class AddPaymetMethods extends StatelessWidget {
  AddPaymetMethods({super.key});
  UserController userController = Get.find<UserController>();
  final AuthController authController = Get.find<AuthController>();
  final PaymentController paymentController = Get.find<PaymentController>();

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text('add_payment_method'.tr),
        leading: InkWell(
          child: Icon(Icons.arrow_back_ios),
          onTap: () => Get.back(),
        ),
      ),
      body: Obx(
        () => authController.deletingStripeBankAccounts.isTrue
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SloganIconCard(
                      title: "Credit or Debit Card",
                      backgroundColor: Colors.transparent,
                      borderColor:
                          Theme.of(context).colorScheme.onSecondaryContainer,
                      leftIcon: Icons.payment,
                      rightIcon: Icons.arrow_forward_ios_outlined,
                      function: () {
                        paymentController.initializePaymentSheet(context);
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    // SloganIconCard(
                    //   title: "Google Pay",
                    //   backgroundColor: Colors.transparent,
                    //   borderColor:
                    //       Theme.of(context).colorScheme.onSecondaryContainer,
                    //   leftIconSvg: SvgPicture.asset(
                    //     "assets/icons/gpay.svg",
                    //     width: 30,
                    //   ),
                    //   rightIcon: Icons.arrow_forward_ios_outlined,
                    // ),
                    // SizedBox(
                    //   height: 20,
                    // ),
                    // SloganIconCard(
                    //   title: "Paypal",
                    //   backgroundColor: Colors.transparent,
                    //   borderColor:
                    //       Theme.of(context).colorScheme.onSecondaryContainer,
                    //   leftIconSvg: SvgPicture.asset(
                    //     "assets/icons/paypal.svg",
                    //     width: 20,
                    //   ),
                    //   rightIcon: Icons.arrow_forward_ios_outlined,
                    //   function: () {},
                    // ),
                  ],
                ),
              ),
      ),
    );
  }
}
