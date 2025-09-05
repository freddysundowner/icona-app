import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/wallet_controller.dart';
import 'package:tokshop/pages/payout/widgets/transactions_list.dart';
import 'package:tokshop/widgets/bottom_sheet_dialog.dart';

import '../../utils/utils.dart';

class Transactions extends StatelessWidget {
  Transactions({super.key});
  final WalletController _walletController = Get.find<WalletController>();

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            InkWell(
              onTap: () {
                showFilterBottomSheet(
                    context,
                    Obx(
                      () => Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15)),
                            color: theme.scaffoldBackgroundColor),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 0.03.sh,
                            ),
                            Text(
                              'filter_by_status'.tr,
                              style: TextStyle(
                                  fontSize: 16.sp, fontWeight: FontWeight.w300),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 10.0, right: 10.0),
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      _walletController.getUserTransactions(
                                        status: "",
                                        userId: FirebaseAuth
                                            .instance.currentUser!.uid,
                                        page: "1",
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Radio(
                                          value: _walletController
                                                      .transactionFilter
                                                      .value ==
                                                  ""
                                              ? false
                                              : true,
                                          groupValue: false,
                                          onChanged: (v) {
                                            _walletController
                                                .getUserTransactions();
                                          },
                                        ),
                                        Text(
                                          'all'.tr,
                                          style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w300),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 0.01.sh,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      _walletController.getUserTransactions(
                                        status: "Pending",
                                        userId: FirebaseAuth
                                            .instance.currentUser!.uid,
                                        page: "1",
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Radio(
                                          activeColor: kPrimaryColor,
                                          value: _walletController
                                                      .transactionFilter
                                                      .value ==
                                                  "Pending"
                                              ? false
                                              : true,
                                          groupValue: false,
                                          onChanged: (v) {
                                            _walletController
                                                .getUserTransactions();
                                          },
                                        ),
                                        Text(
                                          'pending'.tr,
                                          style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w300),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 0.01.sh,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      _walletController.getUserTransactions(
                                        status: "Completed",
                                        userId: FirebaseAuth
                                            .instance.currentUser!.uid,
                                        page: "1",
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Radio(
                                          activeColor: kPrimaryColor,
                                          value: _walletController
                                                      .transactionFilter
                                                      .value ==
                                                  "Completed"
                                              ? false
                                              : true,
                                          groupValue: false,
                                          onChanged: (v) {
                                            _walletController
                                                .getUserTransactions();
                                          },
                                        ),
                                        Text(
                                          'completed'.tr,
                                          style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w300),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(
                    Icons.filter_list_sharp,
                  ),
                  Text(
                    'filter'.tr,
                    style:
                        TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w300),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 0.01.sh,
            ),
            Expanded(child: TransactionsList()),
          ],
        ),
      ),
    );
  }
}
