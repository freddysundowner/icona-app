import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/user_controller.dart';
import 'package:tokshop/main.dart';
import 'package:tokshop/pages/profile/view_profile.dart';
import 'package:tokshop/widgets/live/no_items.dart';

import '../../../controllers/wallet_controller.dart';
import '../../../models/transaction.dart';
import '../../../utils/functions.dart';

class TransactionsList extends StatelessWidget {
  TransactionsList({super.key}) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _walletController.transactionPageNumber.value = 1;
      _walletController.getUserTransactions(
          userId: FirebaseAuth.instance.currentUser!.uid);
    });
  }

  final WalletController _walletController = Get.find<WalletController>();
  final UserController userController = Get.find<UserController>();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return _walletController.transactionsLoading.isFalse
          ? _walletController.transactions.isNotEmpty
              ? Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                          shrinkWrap: true,
                          controller:
                              _walletController.transactionScrollController,
                          itemCount: _walletController.transactions.length,
                          itemBuilder: (context, index) {
                            Transaction transaction =
                                _walletController.transactions.elementAt(index);
                            return GestureDetector(
                              onTap: () {
                                if (transaction.type == "tip") {
                                  Get.to(() =>
                                      ViewProfile(user: transaction.from!.id!));
                                } else if (transaction.type == "sending") {
                                  Get.to(() =>
                                      ViewProfile(user: transaction.from!.id!));
                                } else if (transaction.type == "order") {
                                  if (transaction.orderId != "") {
                                    // Get.to(
                                    //   () => PurchaseDetails(
                                    //       Order(id: transaction.orderId)),
                                    // );
                                  }
                                } else if (transaction.type == "purchase") {
                                  if (transaction.orderId != "") {
                                    // Get.to(
                                    //   () => PurchaseDetails(
                                    //     Order(id: transaction.orderId),
                                    //   ),
                                    // );
                                  }
                                }
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 15.0),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            convertTime(
                                                transaction.date.toString()),
                                            style: TextStyle(fontSize: 10.sp),
                                          ),
                                          if (transaction.status == "Pending")
                                            const Icon(
                                              CupertinoIcons
                                                  .exclamationmark_circle,
                                              color: Colors.amber,
                                              size: 15,
                                            )
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (transaction.type == "tip" &&
                                                    authController.usermodel
                                                            .value!.id ==
                                                        transaction.from!.id)
                                                  Text(
                                                    "tip_sent_to".trParams({
                                                      "name": transaction
                                                          .to.firstName!
                                                    }),
                                                    style: TextStyle(
                                                      fontSize: 14.sp,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                if (transaction.type == "tip" &&
                                                    authController.usermodel
                                                            .value!.id !=
                                                        transaction.from!.id)
                                                  Text(
                                                    "tip_received_from"
                                                        .trParams({
                                                      "name": transaction
                                                          .from!.firstName!
                                                    }),
                                                    style: TextStyle(
                                                      fontSize: 14.sp,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                if (transaction.type != "tip")
                                                  Text(
                                                    transaction.description(),
                                                    style: TextStyle(
                                                      fontSize: 14.sp,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                if (transaction.status ==
                                                        "Pending" &&
                                                    transaction.type == "order")
                                                  Text(
                                                    "expected_on".trParams({
                                                      "date": convertTime(
                                                          transaction
                                                              .availableOn
                                                              .toString())
                                                    }),
                                                    style: TextStyle(
                                                      fontSize: 10.sp,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          if (transaction.type == "refund" &&
                                              transaction.to.id ==
                                                  authController
                                                      .currentuser?.id)
                                            Text(
                                              "-\$ ${transaction.amount.toStringAsFixed(2)}",
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 13.sp),
                                            ),
                                          if (transaction.type == "refund" &&
                                              transaction.from?.id ==
                                                  authController
                                                      .currentuser?.id)
                                            Text(
                                              "-\$ ${transaction.amount.toStringAsFixed(2)}",
                                              style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 13.sp),
                                            ),
                                          if (transaction.type == "tip" &&
                                              transaction.from?.id !=
                                                  authController
                                                      .currentuser?.id)
                                            Text(
                                              "+\$ ${transaction.amount.toStringAsFixed(2)}",
                                              style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 13.sp),
                                            ),
                                          if (transaction.type == "tip" &&
                                              transaction.from?.id ==
                                                  authController
                                                      .currentuser?.id)
                                            Text(
                                              "-\$ ${transaction.amount.toStringAsFixed(2)}",
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 13.sp),
                                            ),
                                          if (transaction.type == "order")
                                            Text(
                                              "\$ ${transaction.from?.id == authController.currentuser?.id ? "-" : "+"}${transaction.amount.toStringAsFixed(2)}",
                                              style: TextStyle(
                                                  color: transaction.from?.id ==
                                                          authController
                                                              .currentuser?.id
                                                      ? Colors.red
                                                      : Colors.green,
                                                  fontSize: 13.sp),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
                    _walletController.moreTransactionsLoading.isTrue
                        ? Center(child: CircularProgressIndicator())
                        : Container(),
                  ],
                )
              : NoItems(
                  content: Text("no_transactions".tr),
                  iconSize: 60.h,
                )
          : const Center(
              child: CircularProgressIndicator(),
            );
    });
  }
}
