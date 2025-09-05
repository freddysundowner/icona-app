import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/cart_controller.dart';
import 'package:tokshop/controllers/checkout_controller.dart';
import 'package:tokshop/utils/helpers.dart';

import '../../controllers/payment_controller.dart';
import '../../main.dart';
import '../../models/product.dart';
import '../payments/add_payment_method.dart';
import '../profile/shipping_address.dart';
import 'gift_friend_sheet.dart';

class BuyNowSheet extends StatefulWidget {
  Product product;
  BuyNowSheet({super.key, required this.product});

  @override
  State<BuyNowSheet> createState() => _BuyNowSheetState();
}

class _BuyNowSheetState extends State<BuyNowSheet> {
  final PaymentController paymentController = Get.find<PaymentController>();

  CheckOutController checkOutController = Get.find<CheckOutController>();

  CartController cartController = Get.put(CartController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userController.gettingMyAddrresses();
      checkOutController.getTaxEstimate({
        "amount": widget.product.price,
        "reference": widget.product.id,
        "tax_code": widget.product.shipping_profile?.taxCode,
        "quantity": 1,
        'customerId': authController.currentuser?.id,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.9, // Height of the bottom sheet
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon:
                          Icon(Icons.close, color: theme.colorScheme.onSurface),
                    ),
                  ],
                ),
                // Product Section
                Row(
                  children: [
                    if (widget.product.images?.isNotEmpty == true)
                      SizedBox(
                        height: 60.h,
                        width: 60.w,
                        child: widget.product.images?.isNotEmpty == true
                            ? CachedNetworkImage(
                                imageUrl: widget.product.images!.first,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/images/image_placeholder.jpg',
                                fit: BoxFit.cover,
                              ),
                      ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        widget.product.name ?? "",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Send as Gift
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.card_giftcard,
                      color: theme.colorScheme.onSurface),
                  title: Text(
                    'send_gift'.tr,
                    style: TextStyle(
                        fontSize: 14.sp, color: theme.colorScheme.onSurface),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios,
                      color: Colors.grey, size: 16.sp),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => GiftFriendSheet(),
                    );
                  },
                ),
                Divider(color: theme.dividerColor),

                // Payment Section
                Text('payment_method'.tr, style: _sectionTitleStyle()),
                SizedBox(height: 8.h),
                InkWell(
                  onTap: () {
                    Get.to(() => AddPaymetMethods());
                  },
                  child: Obx(
                    () => paymentController.loading.isTrue
                        ? CircularProgressIndicator()
                        : Row(
                            children: [
                              Icon(Icons.credit_card,
                                  color: theme.colorScheme.onSurface),
                              SizedBox(width: 8.w),
                              if (paymentController.paymentMethods.isEmpty)
                                Flexible(
                                  child: Text(
                                    'no_payment_method'.tr,
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        color: theme.colorScheme.onSurface),
                                  ),
                                ),
                              if (paymentController.paymentMethods.isNotEmpty)
                                Flexible(
                                  child: Text(
                                    "${paymentController.paymentMethods.first.name} - ${paymentController.paymentMethods.first.last4} - ${paymentController.paymentMethods.first.expiraydate}",
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        color: theme.colorScheme.onSurface),
                                  ),
                                ),
                              Icon(Icons.edit,
                                  color: Colors.orange, size: 18.sp),
                            ],
                          ),
                  ),
                ),
                SizedBox(height: 8.h),
                Divider(color: Colors.grey),

                // Address Section
                Text('address'.tr, style: _sectionTitleStyle()),
                SizedBox(height: 8.h),
                InkWell(
                  onTap: () async {
                    await Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                          builder: (_) => ShippingAddresses(from: "buy_now")),
                    );
                    setState(() {}); // refresh after coming back
                  },
                  child: Obx(
                    () => Row(
                      children: [
                        Icon(Icons.location_on,
                            color: theme.colorScheme.onSurface),
                        SizedBox(width: 8.w),
                        if (authController.currentuser?.address == null)
                          Expanded(
                            child: Text(
                              'no_address'.tr,
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  color: theme.colorScheme.onSurface),
                            ),
                          ),
                        if (authController.currentuser?.address != null)
                          Expanded(
                            child: Text(
                              '${authController.currentuser?.address?.name}\n${authController.currentuser?.address?.addrress1},${authController.currentuser?.address?.city}\n${authController.currentuser?.address?.country}',
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  color: theme.colorScheme.onSurface),
                            ),
                          ),
                        Icon(Icons.edit, color: Colors.orange, size: 18.sp),
                      ],
                    ),
                  ),
                ),
                Divider(color: Colors.grey),

                // Price Breakdown
                _priceRow(
                    'subtotal'.tr, priceHtmlFormat(widget.product.price ?? 0)),
                _priceRow(
                    "${'shipping'.tr}\n${""}",
                    priceHtmlFormat(
                        shippingController.shippingEstimate['amount'] ?? 0)),
                Obx(() => checkOutController.tax.isEmpty
                    ? _priceRow('tax'.tr, priceHtmlFormat(0))
                    : _priceRow('tax'.tr,
                        priceHtmlFormat(checkOutController.tax.value ?? 0))),
                SizedBox(height: 8.h),
                _priceRow(
                    'total'.tr,
                    priceHtmlFormat((widget.product.price! +
                            double.parse(checkOutController.tax.isEmpty
                                ? '0.0'
                                : checkOutController.tax.value) +
                            double.parse(
                                shippingController.shippingEstimate['amount']))
                        .toStringAsFixed(2)),
                    isBold: true),
                SizedBox(height: 16.h),

                SizedBox(
                  width: double.infinity,
                  height: 40.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      if (paymentController.paymentMethods.isEmpty) {
                        Get.showSnackbar(GetSnackBar(
                          message: 'no_payment_method'.tr,
                          backgroundColor: Colors.red,
                          snackPosition: SnackPosition.TOP,
                          isDismissible: true,
                        ));
                        return;
                      }

                      if (userController.myAddresses.isEmpty) {
                        Get.showSnackbar(GetSnackBar(
                          message: 'no_address'.tr,
                          backgroundColor: Colors.red,
                          snackPosition: SnackPosition.TOP,
                        ));
                        return;
                      }
                      await checkOutController.saveOrder({
                        "product": widget.product.id,
                        'status': "processing",
                        'shippingFee':
                            shippingController.shippingEstimate['amount'],
                        "rate_id": shippingController.shippingEstimate['id'],
                        'subtotal': widget.product.price,
                        'tax': checkOutController.tax.value,
                        'seller': widget.product.ownerId!.id,
                        'buyer': authController.usermodel.value!.id,
                        'quantity': 1,
                        'total': (widget.product.price! +
                                double.parse(checkOutController.tax.value) +
                                double.parse(shippingController
                                    .shippingEstimate['amount']))
                            .toStringAsFixed(2),
                        'color': cartController.selectedsize.value,
                        "size": cartController.selectedsize.value,
                        "tokshow": tokShowController.currentRoom.value?.id
                      }, context, widget.product);
                    },
                    child: Text(
                      'confirm_purchase'.tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method for section title style
  TextStyle _sectionTitleStyle() {
    return TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.bold,
      color: Colors.grey,
    );
  }

  // Helper method for price rows
  Widget _priceRow(String label, String price, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(Get.context!).colorScheme.onSurface,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            price,
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(Get.context!).colorScheme.onSurface,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
