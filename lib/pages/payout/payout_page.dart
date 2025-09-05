import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:tokshop/main.dart';
import 'package:tokshop/pages/payout/stripe_setup.dart';
import 'package:tokshop/pages/payout/stripe_transations_page.dart';
import 'package:tokshop/pages/payout/transations_page.dart';
import 'package:tokshop/pages/payout/withdraw_page.dart';
import 'package:tokshop/widgets/bottom_sheet_dialog.dart';
import 'package:tokshop/widgets/slogan_icon_card.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/wallet_controller.dart';
import '../../utils/helpers.dart';
import '../../widgets/content_card_two.dart';

class PayoutPage extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final WalletController _walletController = Get.put(WalletController());

  PayoutPage({super.key}) {
    _walletController.getConnectedStripeBanks();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(
            'payouts'.tr,
            style: TextStyle(
              fontSize: 18.0.sp,
            ),
          ),
          leading: InkWell(
            child: Icon(Icons.clear),
            onTap: () => Get.back(),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await _walletController.getUserTransactions();
            _walletController.getUserTransactions();
          },
          child: Column(
            children: [
              TabBar(
                isScrollable: true,
                indicatorColor: theme.colorScheme.primary,
                labelColor: theme.textTheme.bodyLarge!.color,
                unselectedLabelColor: theme.textTheme.bodyMedium!.color,
                labelPadding: EdgeInsets.symmetric(horizontal: 10),
                padding: EdgeInsets.zero,
                onTap: (i) {
                  if (i == 0) {
                    _walletController.stripeTransactions();
                  }
                },
                tabAlignment: TabAlignment.start,
                labelStyle: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                tabs: [Tab(text: 'payouts'.tr), Tab(text: 'transactions'.tr)],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          child: ContentCardTwo(
                            title:
                                "${"balance".tr} ${priceHtmlFormat(userController.currentProfile.value.wallet?.toStringAsFixed(2))}",
                            content:
                                "${"pending".tr} ${priceHtmlFormat(userController.currentProfile.value.walletPending?.toStringAsFixed(2))}",
                            // sloganStyler:
                            //     TextStyle(color: theme.colorScheme.primary),
                            icon: Icons.monetization_on,
                            rightWidget: Text(
                              "withdraw".tr,
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                              ),
                            ),

                            onEdit: () {
                              showFilterBottomSheet(
                                  context,
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 15),
                                        child: Text(
                                          'select_payout_method'.tr,
                                          style: theme.textTheme.headlineSmall,
                                        ),
                                      ),
                                      Divider(),
                                      Obx(() => _walletController
                                              .loadingbanks.isTrue
                                          ? Center(
                                              child:
                                                  CircularProgressIndicator())
                                          : SloganIconCard(
                                              title: authController
                                                          .currentuser?.bank !=
                                                      null
                                                  ? "Bank: ${authController.currentuser?.bank!.name}"
                                                  : "connect_bank_account".tr,
                                              titleStyle:
                                                  theme.textTheme.titleMedium,
                                              rightIcon:
                                                  Icons.arrow_forward_ios,
                                              backgroundColor:
                                                  Colors.transparent,
                                              slogan: authController
                                                          .currentuser?.bank !=
                                                      null
                                                  ? "XXXXX-${authController.currentuser?.bank!.accountNumber?.substring(authController.currentuser!.bank!.accountNumber!.length - 4).toUpperCase()}"
                                                  : "add_your_bank_account".tr,
                                              function: () {
                                                Get.back();
                                                if (authController
                                                        .currentuser?.bank ==
                                                    null) {
                                                  Get.to(() =>
                                                      ConnectBankAccount());
                                                  return;
                                                }
                                                showFilterBottomSheet(
                                                    context,
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Container(
                                                          margin: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      15),
                                                          child: Text(
                                                            "XXXXX--${authController.currentuser?.bank?.accountNumber?.substring(authController.currentuser!.bank!.accountNumber!.length - 4).toUpperCase()}",
                                                            style: theme
                                                                .textTheme
                                                                .headlineSmall,
                                                          ),
                                                        ),
                                                        Divider(),
                                                        SloganIconCard(
                                                          title: "withdraw".tr,
                                                          titleStyle: theme
                                                              .textTheme
                                                              .titleMedium,
                                                          rightIcon: Icons
                                                              .arrow_forward_ios,
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          function: () {
                                                            Get.back();
                                                            Get.to(() =>
                                                                WithdrawPage(
                                                                  stripeAccountModel:
                                                                      authController
                                                                          .currentuser
                                                                          ?.bank,
                                                                ));
                                                          },
                                                        ),
                                                        SloganIconCard(
                                                          title: "remove".tr,
                                                          titleStyle: theme
                                                              .textTheme
                                                              .titleMedium,
                                                          rightIcon:
                                                              Icons.delete,
                                                          rightIconStyle:
                                                              Colors.red,
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          function: () {
                                                            Get.back();
                                                            _walletController
                                                                .deleteBank();
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                    initialChildSize: 0.25);
                                              },
                                            )),
                                    ],
                                  ),
                                  initialChildSize: 0.25);
                            },
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Expanded(
                            child: Column(
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                children: [
                                  Text(
                                    "history".tr,
                                    style: TextStyle(fontSize: 21),
                                  ),
                                  // Spacer(),
                                  // Text(
                                  //   "view_all".tr,
                                  //   style: TextStyle(
                                  //       fontSize: 13.sp,
                                  //       color: theme.colorScheme.primary),
                                  // ),
                                ],
                              ),
                            ),
                            Divider(
                              color: theme.dividerColor,
                            ),
                            Expanded(child: StripeTransactionsList()),
                          ],
                        )),
                      ],
                    ),
                    Transactions(),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> checkStripeStatus(
      BuildContext context, String clientSecret, String amount) async {
    await Stripe.instance
        .retrievePaymentIntent(clientSecret)
        .then((value) async {
      if (value.status.name == "Succeeded") {
        // await updateWallet(amount.toString());
        return true;
      } else if (value.status.name == "requires_payment_method") {
        await checkStripeStatus(context, clientSecret, amount);
      } else if (value.status.name == "requires_confirmation") {
        await checkStripeStatus(context, clientSecret, amount);
      } else if (value.status.name == "requires_action") {
        await checkStripeStatus(context, clientSecret, amount);
      } else if (value.status.name == "processing") {
        await checkStripeStatus(context, clientSecret, amount);
      }
    });
  }
}
