import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tokshop/main.dart';
import 'package:tokshop/models/bank.dart';
import 'package:tokshop/pages/success_page.dart';
import 'package:tokshop/utils/helpers.dart';

import '../models/stripetransaction.dart';
import '../models/transaction.dart';
import '../services/transaction_api.dart';
import '../utils/utils.dart';

class WalletController extends GetxController {
  var transactionsLoading = false.obs;
  final transactionScrollController = ScrollController();
  var consumables = <String>[].obs;
  var moreTransactionsLoading = false.obs;
  var purchasePending = false.obs;
  var transactionFilter = "".obs;
  var previousPurchaseId = "".obs;
  var totalpages = 1.obs;
  var transactionPageNumber = 1.obs;
  var creatingStripeAccount = false.obs;
  var gettingStripeAccount = false.obs;
  var userStripeAccountId = "".obs;

  var stripeTransactionloading = false.obs;
  var loadingbanks = false.obs;
  var paymentMethodPicked = "".obs;
  RxList<Transaction> transactions = <Transaction>[].obs;
  RxList<StripeTransaction> stripeTransaction = <StripeTransaction>[].obs;
  var withdrawing = false.obs;
  var withdrawAmountController = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    transactionScrollController.addListener(() {
      if (totalpages.value == transactionPageNumber.value) {
        return;
      }
      if (transactionScrollController.position.atEdge) {
        bool isTop = transactionScrollController.position.pixels == 0;
        if (isTop) {
          printOut('At the top');
        } else {
          printOut('At the bottom');
          transactionPageNumber.value = transactionPageNumber.value + 1;
          getMoreTransactions();
        }
      }
    });
  }

  withdraw(Bank stripeAccountModel) async {
    try {
      withdrawing.value = true;
      int amount = int.parse(withdrawAmountController.text);

      if (amount <= authController.usermodel.value!.wallet!.toInt()) {
        var payout = await TransactionAPI().withdrawToBank(
          withdrawAmountController.text,
        );

        if (payout["error"] == null) {
          try {
            authController.usermodel.value!.wallet =
                authController.usermodel.value!.wallet! - amount;
            Get.back();
            Get.to(() => SuccessPage(
                title: "withdrawn_bank_description".trParams({
                  'amount': priceHtmlFormat(amount),
                  "bank_name": stripeAccountModel.name!
                }),
                functionbtnone: () {},
                functionbtntwo: () {}));
          } catch (e, s) {
            print(s);
          }
        } else {
          GetSnackBar(
            message: payout["error"],
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ).show();
        }
      } else {
        GetSnackBar(
          message: "${'insufficient_balance_to_withdraw'.trParams({
                'amount':
                    priceHtmlFormat(int.parse(withdrawAmountController.text))
              })} ",
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
        ).show();
      }
    } catch (e) {
      Get.back();
    } finally {
      withdrawing.value = false;
      withdrawAmountController.clear();
      stripeTransactions();
    }
  }

  getUserTransactions(
      {String? page = "1",
      String limit = "15",
      String? userId = "",
      String? status = ""}) async {
    try {
      transactionsLoading.value = true;

      var response = await TransactionAPI().getUserTransactions(
        page: page,
        limit: limit,
        userId: userId,
        status: status,
      );

      List transactionsres = response['data'];
      if (transactionPageNumber.value > 1) {
        transactions.addAll(
            transactionsres.map((e) => Transaction.fromJson(e)).toList());
      } else {
        transactions.value =
            transactionsres.map((e) => Transaction.fromJson(e)).toList();
      }
      totalpages.value = response['totalPages'];

      transactionsLoading.value = false;
    } catch (e, s) {
      transactionsLoading.value = false;
      printOut("Error getting user transactions $e $s");
    }
  }

  getMoreTransactions() async {
    try {
      moreTransactionsLoading.value = true;

      getUserTransactions(
        page: transactionPageNumber.value.toString(),
        limit: "15",
        userId: FirebaseAuth.instance.currentUser!.uid,
      );
      moreTransactionsLoading.value = false;
    } catch (e, s) {
      transactionsLoading.value = false;
      printOut("Error getting more user transactions $e $s");
    }
  }

  getConnectedStripeBanks() async {
    try {
      loadingbanks.value = true;
      var response = await TransactionAPI.getConnectedStripeBanks();
      loadingbanks.value = false;
      List list = response ?? [];
      authController.currentuser!.bank = Bank.fromJson(list[0]);
    } catch (error) {
      print(error);
      return null;
    }
    return null;
  }

  void getUserBank(String s) async {
    try {
      var response = await TransactionAPI.getUserBank(s);
      authController.currentuser?.bank = Bank.fromJson(response);
    } catch (e) {
      print(e);
    }
  }

  void deleteBank() async {
    try {
      var response = await TransactionAPI.deleteBank();
      authController.currentuser?.bank = null;
    } catch (e) {
      print(e);
    }
  }

  void stripeTransactions() async {
    try {
      stripeTransactionloading.value = true;
      var response = await TransactionAPI.stripeTransactions();
      stripeTransactionloading.value = false;
      List list = response['data'] ?? [];
      stripeTransaction.value =
          list.map((e) => StripeTransaction.fromJson(e)).toList();
    } catch (e) {
      print(e);
    }
  }
}
