import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/models/auction.dart';
import 'package:tokshop/models/user.dart';
import 'package:tokshop/pages/profile/view_profile.dart';
import 'package:tokshop/utils/helpers.dart';

Future<dynamic> BidsView(BuildContext context, Auction? auction) {
  List<Bid> bids = auction!.bids!;
  bids.sort((a, b) {
    return a.amount
        .toString()
        .toLowerCase()
        .compareTo(b.amount.toString().toLowerCase());
  });
  return showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
      topLeft: Radius.circular(15),
      topRight: Radius.circular(15),
    )),
    builder: (context) {
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return DraggableScrollableSheet(
            initialChildSize: 0.8,
            expand: false,
            builder: (BuildContext context, ScrollController scrollController) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 0.02.sh,
                      ),
                      Text(
                        'total_bids'.trParams(
                            {'bids_count': auction!.bids!.length.toString()}),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      SizedBox(
                        height: 0.02.sh,
                      ),
                      SizedBox(
                        height: 0.01.sh,
                      ),
                      Column(
                        children: [
                          ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: bids.length,
                              itemBuilder: (context, index) {
                                UserModel user = bids[index].bidder;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: InkWell(
                                    onTap: () {
                                      Get.back();
                                      Get.to(() => ViewProfile(user: user.id!));
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              user.profilePhoto == "" ||
                                                      user.profilePhoto == null
                                                  ? const CircleAvatar(
                                                      radius: 20,
                                                      backgroundImage: AssetImage(
                                                          "assets/icons/profile_placeholder.png"))
                                                  : CircleAvatar(
                                                      radius: 20,
                                                      backgroundImage:
                                                          NetworkImage(user
                                                              .profilePhoto!),
                                                    ),
                                              SizedBox(
                                                width: 0.02.sw,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  "${user.firstName.toString()} ${user.lastName.toString()} ",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (auction.winning!.id == user.id)
                                          Text(
                                            'highest_bidder'.tr,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Text(
                                            priceHtmlFormat(bids[index].amount))
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            });
      });
    },
  );
}
