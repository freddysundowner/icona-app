import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/room_controller.dart';
import 'package:tokshop/controllers/socket_controller.dart';
import 'package:tokshop/models/auction.dart';
import 'package:tokshop/models/product.dart';
import 'package:tokshop/models/user.dart';
import 'package:tokshop/services/auction_api.dart';

import '../main.dart';
import '../pages/inventory/widgets/choose_seconds.dart';
import '../pages/live/live_tokshows.dart';
import '../services/room_api.dart';
import '../utils/helpers.dart';
import '../utils/utils.dart';
import '../widgets/custom_button.dart';
import '../widgets/live/bottom_sheet_options.dart';
import '../widgets/loadig_page.dart';
import '../widgets/text_form_field.dart';

class AuctionController extends GetxController {
  var prebidding = false.obs;
  var autobid = false.obs;
  var increaseduration = 7.obs;
  RxBool bidding = false.obs;
  RxBool loading = false.obs;
  RxBool showbubble = false.obs;
  var suddentAuction = false.obs;
  TextEditingController startBidPrice = TextEditingController();
  TextEditingController maxbidcontroller = TextEditingController();
  TextEditingController custombidprice = TextEditingController();
  TextEditingController increasebidBy = TextEditingController();
  TextEditingController selectedSecondsController = TextEditingController();

  var winningCurrentPrice = 0.0.obs;
  RxList<Auction> auctions = RxList([]);
  RxList<Auction> pendingauctions = RxList([]);
  RxList<String> auctionseconds =
      RxList(['2', "3", "5", "10", "15", "20", "30"]);
  RxInt selectedSeconds = 30.obs;
  Timer? timer;
  final formatedTimeString = "00:00".obs;

  var dragPosition = 3.0.obs; // Observable drag position
  final maxDrag = 140.0; // Maximum drag position

  void updateDragPosition(double delta) {
    dragPosition.value = (dragPosition.value + delta).clamp(0.0, maxDrag);
  }

  void handleDragEnd(Auction auction, BuildContext context) {
    if ((authController.usermodel.value!.address == null ||
            authController.usermodel.value!.defaultpaymentmethod == null) &&
        checkOwner() == false) {
      showAlert(context);
      return;
    }
    if (dragPosition.value > 50) {
      dragPosition.value = 0.0;
      bid(auction.newbaseprice ?? 0, auction);
    } // Immediately reset to the original position
  }

  int getHighestBid(Auction? auction) {
    if (auction!.bids!.isEmpty) return 0;
    List allbids = [];
    for (var element in auction.bids!) {
      allbids.add(element.amount);
    }
    if (allbids.isEmpty) return 0;
    return allbids.reduce((curr, next) => curr > next ? curr : next);
  }

  checkActionTimeRemaining(Auction auction) {
    if (auction.startedTime! == 0) return 0;
    var timedifference = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(auction.startedTime!))
        .inSeconds;
    return auction.duration - timedifference;
  }

  void startTimerWithEndTime() {
    timer?.cancel();
    const oneSec = Duration(seconds: 1);

    timer = Timer.periodic(oneSec, (Timer t) {
      final auction = tokShowController.currentRoom.value?.activeauction;
      if (auction == null || auction.endTime == null) {
        t.cancel();
        return;
      }

      final remaining = auction.endTime!.difference(DateTime.now()).inSeconds;

      if (remaining <= 0) {
        formatedTimeString.value = formatedTime(timeInSecond: 0);
        auction.ended = true;
        t.cancel();
      } else {
        formatedTimeString.value = formatedTime(timeInSecond: remaining);
        formatedTimeString.refresh();
      }
      print("formatedTimeString ${formatedTimeString.value}");
    });
  }

  bool isAuctionActive(Auction? auction) {
    if (auction == null) return false;
    if (auction.endTime == null) return false;

    final remaining = auction.endTime!.difference(DateTime.now()).inSeconds;
    // also respect the `ended` flag
    return remaining > 0 && auction.ended == false;
  }
  // void startTimer(int duration) {
  //   TokShowController tokShowController = Get.find<TokShowController>();
  //   const oneSec = Duration(seconds: 1);
  //   timer = Timer.periodic(
  //     oneSec,
  //     (Timer timer) {
  //       if (duration <= 0) {
  //         formatedTimeString.value = formatedTime(timeInSecond: 0);
  //         tokShowController.currentRoom.value!.activeauction!.ended = true;
  //         timer.cancel();
  //       } else {
  //         formatedTimeString.value = formatedTime(timeInSecond: duration--);
  //         formatedTimeString.refresh();
  //       }
  //     },
  //   );
  // }

  formatedTime({required int timeInSecond}) {
    int sec = timeInSecond % 60;
    int min = (timeInSecond / 60).floor();
    String minute = min.toString().length <= 1 ? "0$min" : "$min";
    String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
    return "$minute : $second";
  }

  void removeAuction(Auction auction) async {
    int i = Get.find<AuctionController>()
        .auctions
        .indexWhere((au) => au.id == auction.id);
    Get.find<AuctionController>().auctions.removeAt(i);
    Get.find<AuctionController>().auctions.refresh();
    await RoomAPI.deleteAuction(auction.id);
  }

  void createAution(Product product, BuildContext context) {
    Get.find<TokShowController>().errorroomtitle.value = "";
    startBidPrice.text = product.price!.toString();
    if (product.auction != null) {
      increasebidBy.text = product.auction!.increaseBidBy.toString();
      selectedSecondsController.text = "${product.auction!.duration}s";
      suddentAuction.value = product.auction!.sudden!;
      selectedSeconds.value = product.auction!.duration;
    }
    showModalBottomSheet(
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        context: Get.context!,
        builder: (context) => Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(Get.context!).viewInsets.bottom),
              child: SingleChildScrollView(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        children: [
                          Text(
                            'auction_settings'.tr,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          Spacer(),
                          InkWell(
                            onTap: () => Get.back(),
                            child: Icon(
                              Icons.clear,
                              size: 20,
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextFormField(
                              hint: "starting_price".tr,
                              controller: startBidPrice,
                              minLines: 1,
                              txtType: TextInputType
                                  .number, // Use TextInputType.txtType
                              prefix: Container(
                                  margin: EdgeInsets.only(right: 10),
                                  child: Text(
                                    currencySymbol,
                                    style: TextStyle(color: Colors.white),
                                  )),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: CustomTextFormField(
                              hint: "time_limit".tr,
                              controller: selectedSecondsController,
                              suffixIcon: Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.grey,
                              ),
                              readOnly: true,
                              onTap: () {
                                ChooseSeconds(context);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text("counter_bid_time".tr,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontSize: 14.sp)),
                      Text(
                        "counter_bid_time_description".tr,
                        style: TextStyle(fontSize: 11.sp),
                      ),
                      SizedBox(
                        height: 70,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [5, 7, 10]
                              .map((e) => InkWell(
                                    splashColor: Colors.transparent,
                                    onTap: () {
                                      increaseduration.value = e;
                                    },
                                    child: Obx(
                                      () => Container(
                                        height: 10,
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 20, horizontal: 5),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 1),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color:
                                                    increaseduration.value == e
                                                        ? Theme.of(context)
                                                            .colorScheme
                                                            .primary
                                                        : Theme.of(context)
                                                            .dividerColor,
                                                width: 1),
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: Center(
                                          child: Text(
                                            "$e ${e == 1 ? "min" : "s"}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("sudden_death".tr,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(fontSize: 16.sp)),
                                Text(
                                  "sudden_death_desc".tr,
                                  style: TextStyle(fontSize: 11.sp),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Obx(
                            () => Switch(
                                value: suddentAuction.value,
                                onChanged: (v) {
                                  suddentAuction.value = !suddentAuction.value;
                                }),
                          ),
                          Divider(),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Obx(
                        () => Get.find<TokShowController>()
                                .errorroomtitle
                                .value
                                .isEmpty
                            ? Container()
                            : Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    Get.find<TokShowController>()
                                        .errorroomtitle
                                        .value,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Center(
                        child: CustomButton(
                          width: MediaQuery.of(context).size.width * 0.8,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          text: 'start_auction'.tr,
                          textColor: Theme.of(context).colorScheme.surface,
                          function: () {
                            if (product.quantity == 0) {
                              Get.snackbar(
                                  "sorry".tr, "product_is_out_of_stock".tr,
                                  backgroundColor: Colors.red);
                              return;
                            }
                            if (selectedSeconds.value == 0) {
                              Get.snackbar(
                                  "sorry".tr, "duration_is_required".tr,
                                  backgroundColor: Colors.red);
                              return;
                            }
                            if (startBidPrice.text.isNotEmpty) {
                              startAuction(product.auction, product);
                            } else {
                              Get.find<TokShowController>()
                                  .errorroomtitle
                                  .value = 'start_bid_price_is_required'.tr;
                            }
                          },
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ));
  }

  startAuction(Auction? auction, Product product) {
    formatedTimeString.value = "00:00";
    Get.find<SocketController>().startAuction(auction);
    var payload = {
      "weight": product.shipping_profile?.weight,
      'unit': product.shipping_profile?.scale,
      "product": auction?.product?.id,
      "update": true,
      "owner": tokShowController.currentRoom.value?.owner?.id,
      "customer": authController.usermodel.value!.id,
    };
    Get.back();
    Get.back();
    print("payload $payload");

    shippingController.getShippingEstimate(data: payload);
    getAllAuctions(roomId: tokShowController.currentRoom.value!.id!);
  }

  // saveAuction(Product product) {
  //   formatedTimeString.value = "00:00";
  //   var au = {
  //     "baseprice": startBidPrice.text,
  //     "duration": selectedSeconds.value,
  //     "increaseBidBy": increaseduration.value,
  //     "started": false,
  //     'sudden': suddentAuction.value,
  //     "product": product.id,
  //     "tokshow": tokShowController.currentRoom.value!.id!
  //   };
  //   startBidPrice.clear();
  //   increasebidBy.clear();
  //   Get.back();
  //   Get.back();
  //   AuctinAPI().createAuction(au).then((value) {
  //     Auction auction = Auction.fromJson(value);
  //     tokShowController.currentRoom.value!.activeauction = auction;
  //     tokShowController.currentRoom.refresh();
  //     Get.find<SocketController>().startAuction();
  //
  //     shippingController.getShippingEstimate(data: {
  //       "weight": auction.product?.shipping_profile?.weight,
  //       'unit': auction.product?.shipping_profile?.scale,
  //       "product": auction.product?.id,
  //       "update": true,
  //       "owner": tokShowController.currentRoom.value?.owner?.id,
  //       "customer": authController.usermodel.value!.id,
  //     });
  //     // Get.find<SocketController>().pinAuction(auction, Get.context);
  //     getAllAuctions(roomId: tokShowController.currentRoom.value!.id!);
  //   });
  // }

  void prebidBottomSheet(BuildContext context, Product product) {
    AuctionController auctionController = Get.find<AuctionController>();
    if (authController.usermodel.value!.address == null ||
        authController.usermodel.value!.defaultpaymentmethod == null &&
            checkOwner() == false) {
      showAlert(context);
      return;
    }
    Auction auction = product.auction!;
    if (auction.product != null) {
      shippingController.getShippingEstimate(data: {
        "weight": product.shipping_profile?.weight,
        'unit': product.shipping_profile?.scale,
        "product": auction.product?.id,
        "update": false,
        "owner": product.ownerId?.id,
        "customer": authController.usermodel.value!.id,
      });
    }
    showCustomBottomSheet(
        context,
        Column(
          children: [
            Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      "bid_title_dialog_description".trParams({
                        'product': auction.product?.name!.capitalizeFirst ?? ""
                      }),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: 10),
                  CustomTextFormField(
                    controller: auctionController.maxbidcontroller,
                    label: "your_max_bid".tr,
                    fontsize: 18.sp,
                    validate: true,
                    autofocus: true,
                    txtType: TextInputType.number,
                    prefix: Text(currencySymbol),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Text(
                        "+${priceHtmlFormat(shippingController.shippingEstimate['amount'])} ${'shipping'.tr}"),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: CustomButton(
                      text: 'submit'.tr,
                      borderRadius: 20,
                      height: 35,
                      fontSize: 12.sp,
                      textColor: Theme.of(context).colorScheme.surface,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      width: MediaQuery.of(context).size.width * 0.8,
                      function: () {
                        if (auctionController.maxbidcontroller.text.isEmpty ||
                            int.parse(auctionController.maxbidcontroller.text) <
                                auction.baseprice) {
                          Get.snackbar(
                              "error".tr,
                              "bid_max_amount_error".trParams(
                                  {"amount": auction.baseprice.toString()}),
                              backgroundColor: Colors.red,
                              colorText: Colors.white);
                          return;
                        }
                        auctionController.prebid(
                            int.parse(auctionController.maxbidcontroller.text),
                            auction,
                            context);
                      },
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ],
        ),
        "place_bid".tr);
  }

  void prebid(int bidamount, Auction auction, BuildContext context) async {
    LoadingOverlay.showLoading(context);
    prebidding.value = true;
    autobid.value = true;
    await bid(bidamount, auction, prebid: true);
    prebidding.value = false;
    autobid.value = false;
    Get.back();
    maxbidcontroller.clear();
    LoadingOverlay.hideLoading(context);
    if (auction.tokshow != null) {
      productController.getAllroducts(
        saletype: "auction",
        roomid: auction.tokshow ?? "",
        type: "room",
      );
    }
    // getAllAuctions(
    //     roomId: Get.find<TokShowController>().currentRoom.value!.id!);
  }

  bid(int bidamount, Auction auction, {prebid = false}) async {
    TokShowController tokShowController = Get.find<TokShowController>();
    SocketController socketController = Get.put(SocketController());
    tokShowController.currentRoom.refresh();
    var payload = {
      "user": FirebaseAuth.instance.currentUser!.uid,
      "amount": autobid.isTrue && prebidding.isFalse
          ? tokShowController.currentRoom.value!.activeauction!.baseprice + 1
          : bidamount,
      "increaseBidBy": auction.increaseBidBy,
      "auction": auction.id,
      'prebid': prebid,
      'autobid': autobid.value,
      'autobidamount': bidamount,
      'roomId': tokShowController.currentRoom.value == null
          ? auction.tokshow
          : tokShowController.currentRoom.value!.id
    };
    if (prebid) {
      await AuctinAPI().bid(payload, auction.id!);
    } else {
      socketController.placeBid(payload);
    }
    tokShowController.currentRoom.refresh();
    _updateLocalBid(userController.currentProfile.value, bidamount);

    return tokShowController;
  }

  _updateLocalBid(UserModel currentUser, int bidamount) {
    TokShowController tokShowController = Get.find<TokShowController>();
    if (tokShowController.currentRoom.value == null ||
        tokShowController.currentRoom.value!.activeauction == null) return;
    if (tokShowController.currentRoom.value!.activeauction != null) {
      int i = Get.find<TokShowController>()
          .currentRoom
          .value!
          .activeauction!
          .bids!
          .indexWhere((element) => element.bidder.id == currentUser.id);
      if (i != -1) {
        tokShowController.currentRoom.value!.activeauction!.bids![i].amount =
            bidamount.toInt();
      } else {
        tokShowController.currentRoom.value!.activeauction!.bids!
            .add(Bid(bidder: currentUser, amount: bidamount.toInt()));
      }
    }
  }

  // void bid(UserModel currentUser, int bidamount) async {
  //   TokShowController tokShowController = Get.find<TokShowController>();
  //   Bid bid = Bid(bidder: currentUser, amount: bidamount);
  //   bool emit = _bidUpdateAdd(currentUser, bidamount);
  //   bool userExists = false;
  //   if (tokShowController.currentRoom.value!.activeauction != null) {
  //     int i = tokShowController.currentRoom.value!.activeauction!.bids!
  //         .indexWhere((element) => element.bidder.id == currentUser.id);
  //     if (i != -1) {
  //       userExists = true;
  //       Bid oldbid =
  //           tokShowController.currentRoom.value!.activeauction!.bids![i];
  //       if (oldbid.amount < bidamount) {
  //         tokShowController.currentRoom.value!.activeauction!.bids![i] = bid;
  //         emit = true;
  //       }
  //     } else {
  //       tokShowController.currentRoom.value!.activeauction!.bids!.add(bid);
  //       emit = true;
  //     }
  //   } else {
  //     tokShowController.currentRoom.value!.activeauction!.bids!.add(bid);
  //     emit = true;
  //   }
  //
  //   // emit to oother users
  //   if (emit) {
  //     tokShowController.currentRoom.value!.activeauction!.winning =
  //         findWinner(tokShowController.currentRoom.value!.activeauction)!
  //             .bidder;
  //     tokShowController.currentRoom.refresh();
  //     if (userExists) {
  //       AuctinAPI().updateBid(currentUser.id!, {
  //         "amount": bidamount,
  //       });
  //     } else {
  //       AuctinAPI().addBid({
  //         "user": currentUser.id,
  //         "amount": bidamount,
  //         "auction": tokShowController.currentRoom.value!.activeauction!.id
  //       });
  //     }
  //   }
  // }

  getAllAuctions({String? roomId, String? status}) async {
    loading.value = true;
    var response =
        await AuctinAPI().getAllAuctions(roomId: roomId, status: status);
    loading.value = false;
    print(response);
    List list = response['auctions'] ?? [];
    auctions.value = list.map((e) => Auction.fromJson(e)).toList();
    pendingauctions.value =
        auctions.where((element) => element.ended == false).toList();
    auctions.refresh();
  }

  Future<void> getNextAuction() async {
    var response = await AuctinAPI().getAllAuctions(
        roomId: Get.find<TokShowController>().currentRoom.value!.id,
        status: 'active');
    if (response.length > 0) {
      List list = response;
      List<Auction> auctions = list.map((e) => Auction.fromJson(e)).toList();
      pendingauctions.value = auctions;
      if (auctions.isNotEmpty) {
        Auction? nextAuction = auctions
            .where(
                (element) => element.ended == false && element.started == false)
            .toList()
            .first;
        Get.find<TokShowController>().currentRoom.value!.activeauction =
            nextAuction;

        // Get.find<SocketController>().pinAuction(nextAuction, null);
      }
    } else {
      pendingauctions.value = [];
      await RoomAPI().updateRoomId({"activeauction": null},
          Get.find<TokShowController>().currentRoom.value!.id!);
    }
    Get.find<TokShowController>().currentRoom.refresh();
  }

  checkNextAuction() {
    if (auctions.isNotEmpty &&
        auctions.where((element) => element.ended == false).isNotEmpty) {
      return true;
    }
    return false;
  }

  Bid? findWinner(List<Bid>? bids) {
    if (bids!.isEmpty) return null;
    List allbids = [];
    for (var element in bids) {
      allbids.add(element.amount);
    }
    int bidamount = allbids.reduce((curr, next) => curr > next ? curr : next);
    Bid bidwinnder = bids.firstWhere((element) => element.amount == bidamount);
    tokShowController.currentRoom.value!.activeauction!.winning =
        bidwinnder.bidder;
    winningCurrentPrice.value = bidamount.toDouble();
    tokShowController.currentRoom.refresh();
    return bidwinnder;
  }
}
