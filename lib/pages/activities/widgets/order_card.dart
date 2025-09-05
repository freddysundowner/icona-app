import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/utils/helpers.dart';

import '../../../models/order.dart';
import '../../../utils/functions.dart';

//ignore: must_be_immutable
class OrderCard extends StatelessWidget {
  Order order;
  ThemeData theme;
  OrderCard({super.key, required this.order, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: theme.dividerColor),
          color: Colors.transparent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSecondaryContainer,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Text(
                  "# ${order.invoice}",
                  style: theme.textTheme.titleMedium,
                ),
                Spacer(),
                Icon(Icons.more_horiz)
              ],
            ),
          ),
          Container(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.0),
                  Container(
                    color: Colors.transparent,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (order.ordertype != "giveaway" &&
                            order.items!.isNotEmpty)
                          SizedBox(
                            height: 60.h,
                            width: 60.w,
                            child: order.items!.isNotEmpty == true
                                ? CachedNetworkImage(
                                    imageUrl: order
                                        .items!.first.product!.images!.first,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    'assets/images/image_placeholder.jpg',
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        if (order.ordertype == "giveaway")
                          SizedBox(
                            height: 60.h,
                            width: 60.w,
                            child: order.giveaway?.images!.isNotEmpty == true
                                ? CachedNetworkImage(
                                    imageUrl: order.giveaway!.images!.first,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    'assets/images/image_placeholder.jpg',
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        SizedBox(width: 12.0),
                        if (order.ordertype != "giveaway")
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (order.items!.first.product != null)
                                  Text(
                                    order.items!.first.product!.name ?? "",
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontSize: 13),
                                    maxLines: 2,
                                  ),
                                SizedBox(height: 4.0),
                                Text(
                                  convertTime(order.date.toString()),
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        if (order.ordertype == "giveaway")
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.giveaway?.name ?? "",
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(fontSize: 13),
                                  maxLines: 2,
                                ),
                                SizedBox(height: 4.0),
                                Text(
                                  convertTime(order.date.toString()),
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: order.status == "cancelled" ||
                                    order.status == "disputed"
                                ? Colors.red
                                : order.status == "shipped"
                                    ? Colors.green[100]
                                    : Colors.amber[100],
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Text(
                            order.status == "ready_to_ship"
                                ? "ready_to_ship".tr
                                : order.status ?? "",
                            style: theme.textTheme.titleSmall?.copyWith(
                                fontSize: 12,
                                color: order.status == "cancelled" ||
                                        order.status == "disputed"
                                    ? Colors.white
                                    : order.status == "shipped"
                                        ? Colors.green
                                        : Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.0),
                  Divider(
                    color: theme.dividerColor,
                  ),
                  if (order.seller?.id ==
                      FirebaseAuth.instance.currentUser?.uid)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${order.customer!.firstName ?? ""} ${order.customer!.lastName ?? ""}",
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontSize: 12),
                        ),
                        Row(
                          children: [
                            Text(
                              "total".tr,
                              style: theme.textTheme.titleSmall
                                  ?.copyWith(fontSize: 12),
                            ),
                            Text(
                              " : ",
                            ),
                            Text(
                              priceHtmlFormat(order.getOrderTotal()),
                              style: theme.textTheme.titleSmall
                                  ?.copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  if (order.customer?.id ==
                      FirebaseAuth.instance.currentUser?.uid)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${order.seller!.firstName ?? ""} ${order.seller!.lastName ?? ""}",
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontSize: 12),
                        ),
                        Row(
                          children: [
                            Text(
                              "total".tr,
                              style: theme.textTheme.titleSmall
                                  ?.copyWith(fontSize: 12),
                            ),
                            Text(
                              " : ",
                            ),
                            Text(
                              priceHtmlFormat(order.getOrderTotal()),
                              style: theme.textTheme.titleSmall
                                  ?.copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
