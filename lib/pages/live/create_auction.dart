import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/auth_controller.dart';
import 'package:tokshop/controllers/user_controller.dart';
import 'package:tokshop/utils/helpers.dart';

import '../../controllers/auction_controller.dart';
import '../../controllers/room_controller.dart';
import '../../models/auction.dart';
import '../../widgets/text_form_field.dart';
import '../products/product_detail.dart';
import 'live_tokshows.dart';
import 'widgets/bids.dart';

class CreateAuction extends StatelessWidget {
  CreateAuction({super.key});

  final TokShowController _tokshowcontroller = Get.find<TokShowController>();
  final AuctionController auctionController = Get.find<AuctionController>();
  final UserController userController = Get.find<UserController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    Auction? auction = _tokshowcontroller.currentRoom.value!.activeauction;
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 20),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (auction!.winning != null && auction.ended == false)
              Text(
                "${auction.winning!.firstName} ${'is_winning'.tr}",
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            if (auction.winner != null && auction.ended == true)
              InkWell(
                onTap: () {
                  userController.getUserProfile(auction.winner!.id!);
                },
                child: Text(
                  "${auction.winner!.id == FirebaseAuth.instance.currentUser!.uid ? "You" : auction.winner!.firstName} ${'won'.tr}",
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            Row(
              children: [
                InkWell(
                  onTap: () {
                    Get.to(() => ProductDetails(product: auction.product!));
                  },
                  child: Text(
                    auction.product?.name ?? "",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                if (auction.ended == false) const Spacer(),
                if (auction.ended == false)
                  Container(
                      margin: const EdgeInsets.only(right: 15),
                      child: Text(auctionController.formatedTimeString.value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 30)))
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            if (_tokshowcontroller.currentRoom.value!.owner!.id ==
                    FirebaseAuth.instance.currentUser!.uid &&
                auction.started == false)
              InkWell(
                onTap: () async {
                  // await auctionController.startAuction();
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.only(top: 15, right: 10, bottom: 10),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child: Text(
                      'start_auction'.tr,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            if (_tokshowcontroller.currentRoom.value!.owner!.id ==
                    FirebaseAuth.instance.currentUser!.uid &&
                auction.started == true)
              InkWell(
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin:
                        const EdgeInsets.only(top: 15, right: 10, bottom: 10),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(20)),
                    child: Center(
                      child: Text(
                        "${auction.bids!.length} ${'bids'.tr}, (${'highest_bid'.tr} ${priceHtmlFormat(auctionController.getHighestBid(auction))})",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
                onTap: () {
                  BidsView(context,
                      _tokshowcontroller.currentRoom.value!.activeauction);
                },
              ),
            if (_tokshowcontroller.currentRoom.value!.owner!.id !=
                    FirebaseAuth.instance.currentUser!.uid &&
                auction.ended == false &&
                auction.started == false)
              Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.only(top: 15, right: 10, bottom: 10),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: Text(
                    'auction_will_start_soon'.tr,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            if (_tokshowcontroller.currentRoom.value!.owner!.id !=
                    FirebaseAuth.instance.currentUser!.uid &&
                auction.ended == true)
              Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.only(right: 10, bottom: 10),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: Text(
                    'auction_has_ended'.tr,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            if (_tokshowcontroller.currentRoom.value!.owner!.id !=
                    FirebaseAuth.instance.currentUser!.uid &&
                auction.started == true)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        margin: const EdgeInsets.only(
                            top: 15, right: 10, bottom: 10),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20)),
                        child: Center(
                          child: Text(
                            'custom'.tr,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        )),
                    onTap: () async {
                      _customBidBottomSheet();
                    },
                  ),
                  InkWell(
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        margin: const EdgeInsets.only(
                            top: 15, right: 15, bottom: 10),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20)),
                        child: Center(
                          child: Text(
                            "${'bid_with'.tr} \$${priceHtmlFormat(auction.getNextAmountBid())}",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        )),
                    onTap: () async {
                      if (authController.usermodel.value!.address == null ||
                          authController
                                  .usermodel.value!.defaultpaymentmethod ==
                              null) {
                        showAlert(context);
                      } else {
                        auctionController.bid(
                            auction.getNextAmountBid(),
                            _tokshowcontroller
                                .currentRoom.value!.activeauction!);
                      }
                    },
                  ),
                ],
              ),
            if (_tokshowcontroller
                .checkIfhavebid(userController.currentProfile.value))
              Center(
                child: Text(
                  "${'your_bid'.tr} ${priceHtmlFormat(auction.getCurrentUserBid().amount)}",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              )
          ],
        ),
      ),
    );
  }

  void _customBidBottomSheet() {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        backgroundColor: Color(0Xfff4f5fa),
        context: Get.context!,
        isScrollControlled: true,
        builder: (context) => Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(Get.context!).viewInsets.bottom),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'provide_custom_bid'.tr,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('enter_price'.tr,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14.sp)),
                        const SizedBox(
                          height: 5,
                        ),
                        CustomTextFormField(
                          controller: auctionController.custombidprice,
                          txtType: TextInputType.number,
                          prefix: Text(
                            'currencySymbol'.tr,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: InkWell(
                        onTap: () {
                          if (int.parse(auctionController.custombidprice.text) <
                              _tokshowcontroller
                                  .currentRoom.value!.activeauction!
                                  .getNextAmountBid()) {
                            Get.snackbar("",
                                "${'you_can_not_bid_less_than'.tr} ${priceHtmlFormat(_tokshowcontroller.currentRoom.value!.activeauction!.getNextAmountBid())}",
                                backgroundColor: Colors.red,
                                colorText: Colors.white);
                            return;
                          }
                          if (authController.usermodel.value!.address == null ||
                              authController
                                      .usermodel.value!.defaultpaymentmethod ==
                                  null) {
                            showAlert(context);
                          } else {
                            auctionController.bid(
                                int.parse(
                                    auctionController.custombidprice.text),
                                _tokshowcontroller
                                    .currentRoom.value!.activeauction!);
                            Get.back();
                          }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20)),
                          child: Center(
                            child: Text(
                              'bid'.tr,
                              style: TextStyle(
                                  color: Colors.white, fontSize: 12.sp),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ));
  }
}
