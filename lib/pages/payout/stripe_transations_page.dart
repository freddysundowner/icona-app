import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tokshop/controllers/wallet_controller.dart';
import 'package:tokshop/models/stripetransaction.dart';

import '../../widgets/live/no_items.dart';

class StripeTransactionsList extends StatelessWidget {
  StripeTransactionsList({super.key}) {
    _walletController.stripeTransactions();
  }
  final WalletController _walletController = Get.find<WalletController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Expanded(child: Obx(() {
              return _walletController.stripeTransactionloading.isFalse
                  ? _walletController.stripeTransaction.isNotEmpty
                      ? Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  controller: _walletController
                                      .transactionScrollController,
                                  itemCount: _walletController
                                      .stripeTransaction.length,
                                  itemBuilder: (context, index) {
                                    StripeTransaction transaction =
                                        _walletController.stripeTransaction
                                            .elementAt(index);
                                    return GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 15.0),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.0)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    DateFormat(
                                                            "dd-MM-yyyy hh:mm a")
                                                        .format(DateTime
                                                            .fromMillisecondsSinceEpoch(
                                                                transaction
                                                                        .created! *
                                                                    1000)),
                                                    style: TextStyle(
                                                        fontSize: 10.sp),
                                                  ),
                                                  if (transaction.status ==
                                                      "Pending")
                                                    Icon(
                                                      CupertinoIcons
                                                          .exclamationmark_circle,
                                                      size: 15,
                                                      color: Colors.amber,
                                                    ),
                                                  if (transaction.status ==
                                                      "paid")
                                                    Icon(
                                                      CupertinoIcons
                                                          .exclamationmark_circle,
                                                      size: 15,
                                                      color: Colors.green,
                                                    )
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      'Payout to ${transaction.bank} - ${transaction.last4}',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 14.sp,
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Text(
                                                    "\$ ${transaction.status == 'paid' ? "-" : "+"}${transaction.amount}",
                                                    style: TextStyle(
                                                        color: transaction
                                                                    .status ==
                                                                'paid'
                                                            ? Colors.red
                                                            : Colors.green,
                                                        fontSize: 18.sp),
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
            })),
          ],
        ),
      ),
    );
  }
}
