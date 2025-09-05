import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:tokshop/controllers/order_controller.dart';
import 'package:tokshop/main.dart';
import 'package:tokshop/utils/functions.dart';
import 'package:tokshop/utils/helpers.dart';
import 'package:tokshop/widgets/custom_button.dart';
import 'package:tokshop/widgets/loadig_page.dart';

import '../../models/order.dart';
import '../../widgets/live/bottom_sheet_options.dart';
import '../profile/view_profile.dart';
import 'dispute_progress.dart';

class ShipmentDetailsPage extends StatelessWidget {
  Order order;
  final OrderController _orderController = Get.find<OrderController>();
  double? weight = 0.0;

  ShipmentDetailsPage({super.key, required this.order}) {
    _orderController.getOrder(order);
    if (order.ordertype == "giveaway") {
      weight = order.giveaway!.shipping_profile!.weight ?? 0.0;
    } else {
      weight = order.items!.isEmpty
          ? 0.0
          : order.items!.fold(
              0.0,
              (previousValue, element) =>
                  previousValue! + int.parse(element.weight!));
    }
    shippingController.getShippingEstimate(data: {
      "weight": weight.toString(),
      "update": false,
      "owner": order.seller?.id,
      "customer": order.customer?.id,
    });
  }

  void productActions(BuildContext context) {
    Column column = Column(children: [
      if (_orderController.currentOrder.value.status == "ready_to_ship")
        InkWell(
          onTap: () async {
            _orderController.updateStatus(
                "shipped", _orderController.currentOrder.value, context);
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(
                  Icons.local_shipping_outlined,
                  size: 20,
                ),
                SizedBox(
                  width: 20,
                ),
                Text(
                  'ship'.tr,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface),
                ),
              ],
            ),
          ),
        ),
      InkWell(
        onTap: () async {
          Get.dialog(
            AlertDialog(
              title: Text("cancel_and_refund".tr),
              content: Text("are_you_sure_to_cancel_this_order".tr),
              actions: [
                TextButton(
                  child: Text("cancel".tr),
                  onPressed: () {
                    Get.back();
                  },
                ),
                TextButton(
                  child: Text("yes".tr,
                      style: TextStyle(
                        color: Colors.red,
                      )),
                  onPressed: () {
                    Get.back();
                    _orderController.updateStatus("cancelled",
                        _orderController.currentOrder.value, context);
                  },
                ),
              ],
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(
                Icons.delete_forever_outlined,
                size: 20,
                color: Colors.red,
              ),
              SizedBox(
                width: 20,
              ),
              Text(
                "cancel_and_refund".tr,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    ]);
    showCustomBottomSheet(context, column, "options".tr);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.top),
        child: Obx(() => _orderController.currentOrder.value.seller?.id ==
                authController.currentuser?.id
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 60,
                    padding: EdgeInsets.only(bottom: 20),
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(left: 20),
                    child: Center(child: Text("shipping_instructions".tr)),
                  ),
                  Obx(() => _orderController.currentOrder.value.status !=
                          "cancelled"
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                productActions(context);
                              },
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.more_horiz,
                                  color: Theme.of(context).colorScheme.surface,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            CustomButton(
                              text: _orderController
                                          .currentOrder.value.need_label ==
                                      false
                                  ? "print_label".tr
                                  : "generate_label".tr,
                              function: () async {
                                if (_orderController
                                        .currentOrder.value.need_label ==
                                    false) {
                                  var url = _orderController
                                          .currentOrder.value.labelUrl ??
                                      "";
                                  LoadingOverlay.showLoading(context);
                                  final response =
                                      await http.get(Uri.parse(url));
                                  if (response.statusCode == 200) {
                                    final pdfBytes = response.bodyBytes;
                                    await Printing.layoutPdf(
                                      onLayout: (format) async => pdfBytes,
                                    );
                                    LoadingOverlay.hideLoading(context);
                                  } else {
                                    throw Exception("Failed to load PDF");
                                  }
                                } else {
                                  _orderController.generateLabel({
                                    "rate_id": shippingController
                                        .shippingEstimate['rate_id'],
                                    "servicelevel": shippingController
                                        .shippingEstimate['servicelevel'],
                                    "shipping_fee": shippingController
                                        .shippingEstimate['amount'],
                                    "order":
                                        _orderController.currentOrder.value.id,
                                  }, context);
                                }
                              },
                              backgroundColor: _orderController
                                          .currentOrder.value.need_label ==
                                      false
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(context).primaryColor,
                              iconData: Icons.print,
                              textColor: Theme.of(context).colorScheme.surface,
                              height: 50,
                              width: MediaQuery.of(context).size.width * 0.8,
                            ),
                          ],
                        )
                      : SizedBox.shrink()),
                  SizedBox(
                    height: 5,
                  )
                ],
              )
            : SizedBox.shrink()),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Obx(() => _orderController.currentOrderLoading.isTrue
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                          onPressed: () {
                            Get.back();
                          },
                          label: Text(""),
                          icon: Icon(
                            Icons.close,
                            size: 25,
                            color: Theme.of(context).colorScheme.onSurface,
                          )),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      "${_orderController.currentOrder.value.items?.length ?? 0} items • \$${_orderController.currentOrder.value.items?.fold(0.0, (previousValue, element) => previousValue + element.subTotal).toStringAsFixed(2)}",
                      style: TextStyle(
                          color: Colors.grey.shade400, fontSize: 14.sp),
                    ),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(
                            text: _orderController.currentOrder.value.invoice
                                .toString()));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("copied_to_clipboard".trParams({
                              "id": _orderController.currentOrder.value.invoice
                                  .toString()
                            })),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Text(
                            "order_id".trParams({
                              'id': _orderController.currentOrder.value.invoice
                                  .toString()
                            }),
                            style: TextStyle(
                                fontSize: 13.sp, color: Colors.blueAccent),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.copy, size: 16, color: Colors.blue),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Items list
                    ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount:
                          _orderController.currentOrder.value.items?.length ??
                              0,
                      separatorBuilder: (_, __) =>
                          Divider(color: Colors.grey.shade800),
                      itemBuilder: (context, index) {
                        final item =
                            _orderController.currentOrder.value.items![index];
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: SizedBox(
                                height: 60.h,
                                width: 60.w,
                                child: item.product!.images!.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: item.product!.images!.first,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        'assets/images/image_placeholder.jpg',
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product?.name ?? "Unnamed item",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.sp),
                                  ),
                                  SizedBox(height: 4.h),
                                  // GestureDetector(
                                  //   onTap: () {
                                  //     // Clipboard.setData(ClipboardData(
                                  //     //     text: _orderController.currentOrder.value.invoice.toString()));
                                  //     // ScaffoldMessenger.of(context).showSnackBar(
                                  //     //   SnackBar(
                                  //     //     content: Text("copied_to_clipboard".trParams(
                                  //     //         {"id": item.invoice.toString()})),
                                  //     //     duration: const Duration(seconds: 2),
                                  //     //   ),
                                  //     // );
                                  //     // Optionally navigate to order detail page
                                  //   },
                                  //   child: Row(
                                  //     children: [
                                  //       // Text(
                                  //       //   "order_id".trParams(
                                  //       //       {'id': item.invoice.toString()}),
                                  //       //   style: TextStyle(
                                  //       //       fontSize: 13.sp,
                                  //       //       color: Colors.blueAccent),
                                  //       // ),
                                  //       const SizedBox(width: 6),
                                  //       const Icon(Icons.copy,
                                  //           size: 16, color: Colors.blue),
                                  //     ],
                                  //   ),
                                  // ),
                                  // SizedBox(height: 2.h),
                                  Text(
                                    DateFormat("MMM d, yyyy").format(
                                        DateTime.parse(item.createdAt!)),
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12.sp,
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("buyer".tr),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: () {
                                  Get.to(() => ViewProfile(
                                      user: _orderController
                                          .currentOrder.value.customer!.id!));
                                },
                                child: Text(
                                  _orderController.currentOrder.value.customer
                                          ?.firstName ??
                                      "",
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.blue),
                                ),
                              ),
                              const SizedBox(width: 10),
                              if (_orderController.currentOrder.value.status ==
                                  "disputed")
                                GestureDetector(
                                  onTap: () {
                                    Get.to(() =>
                                        DisputeProgressPage(order: order));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      "view_dispute".tr,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (order.ordertype == "giveaway")
                              Text(
                                "seller_paid_shipping_cost".tr,
                              ),
                            if (order.ordertype != "giveaway")
                              Text(
                                "shipping_cost".tr,
                              ),
                            Expanded(
                              child: Text(
                                "${priceHtmlFormat(shippingController.shippingEstimate["amount"])} ",
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        )),
                    SizedBox(height: 10),
                    if (_orderController.currentOrder.value.customer?.address !=
                        null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "shipping_to".tr,
                          ),
                          Expanded(
                            child: Text(
                              getAddress(_orderController
                                  .currentOrder.value.customer!.address!),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 10),
                    if (_orderController
                        .currentOrder.value.tracking_number!.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "tracking".tr,
                          ),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(
                                  text: _orderController
                                      .currentOrder.value.tracking_number
                                      .toString()));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("copied_to_clipboard".trParams({
                                    "id": _orderController
                                        .currentOrder.value.tracking_number
                                        .toString()
                                  })),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                              // Optionally navigate to order detail page
                            },
                            child: Row(
                              children: [
                                Text(
                                  _orderController
                                          .currentOrder.value.tracking_number ??
                                      "",
                                  style: TextStyle(
                                      fontSize: 13.sp,
                                      color: Colors.blueAccent),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.copy,
                                    size: 16, color: Colors.blue),
                              ],
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 10),
                    if (shippingController.shippingEstimate["servicelevel"] !=
                            null ||
                        _orderController
                            .currentOrder.value.servicelevel!.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "expected_to_ship".tr,
                          ),
                          Expanded(
                            child: Text(
                              _orderController
                                      .currentOrder.value.servicelevel!.isEmpty
                                  ? shippingController
                                      .shippingEstimate["servicelevel"]
                                  : _orderController
                                      .currentOrder.value.servicelevel,
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "package_weight".tr,
                        ),
                        Spacer(),
                        Text(
                          "$weight ${_orderController.currentOrder.value.scale}",
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "package_dimensions".tr,
                        ),
                        Spacer(),
                        Text(
                          "${_orderController.currentOrder.value.length!}in x ${_orderController.currentOrder.value.width!}in x ${_orderController.currentOrder.value.height!}in",
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                )),
        ),
      ),
    );
  }
}
