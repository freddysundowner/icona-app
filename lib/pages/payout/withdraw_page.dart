import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/widgets/custom_button.dart';
import 'package:tokshop/widgets/text_form_field.dart';

import '../../controllers/wallet_controller.dart';
import '../../models/bank.dart';
import '../../utils/utils.dart';

//ignore: must_be_immutable
class WithdrawPage extends StatelessWidget {
  Bank? stripeAccountModel;
  WithdrawPage({
    super.key,
    this.stripeAccountModel,
  });

  final WalletController _walletController = Get.find<WalletController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'withdraw'.tr,
          style: TextStyle(
            fontSize: 18.0.sp,
          ),
        ),
      ),
      body: SizedBox(
        width: 1.sw,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Column(children: [
                SizedBox(
                  height: 0.1.sh,
                ),
                Text(
                  'how_much_do_you_want'.tr,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                  height: 0.02.sh,
                ),
                CustomTextFormField(
                  controller: _walletController.withdrawAmountController,
                  txtType: TextInputType.number,
                  prefix: Text(currencySymbol),
                ),
                SizedBox(
                  height: 0.1.sh,
                ),
                SizedBox(
                  width: 0.9.sw,
                  child: Obx(() {
                    return _walletController.withdrawing.isFalse
                        ? CustomButton(
                            text: 'initiate_withdrawal'.tr,
                            backgroundColor: Theme.of(context).primaryColor,
                            textColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            function: () async {
                              if (_walletController
                                  .withdrawAmountController.text.isEmpty) {
                                GetSnackBar(
                                  message: 'amount_has_to_be_greater'
                                      .trParams({"amount": "0"}),
                                  duration: Duration(seconds: 3),
                                ).show();
                                return;
                              }
                              double amount = double.parse(_walletController
                                  .withdrawAmountController.text);

                              if (amount > 0) {
                                _walletController.withdraw(stripeAccountModel!);
                              } else {
                                GetSnackBar(
                                  message: 'amount_has_to_be_greater'
                                      .trParams({"amount": "0"}),
                                  duration: Duration(seconds: 3),
                                ).show();
                              }
                            })
                        : const Center(
                            child: CircularProgressIndicator(
                            color: primarycolor,
                          ));
                  }),
                )
              ])
            ],
          ),
        ),
      ),
    );
  }
}
