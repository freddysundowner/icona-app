import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tokshop/pages/chats/chat_room_page.dart';
import 'package:tokshop/pages/profile/view_profile.dart';
import 'package:tokshop/utils/helpers.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/order.dart';
import '../../utils/configs.dart';
import '../../utils/functions.dart';
import 'dispute_page.dart';
import 'dispute_progress.dart';

class BuyerProtectionCard extends StatelessWidget {
  const BuyerProtectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shield Icon with W
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary,
                    ),
                    child: Icon(
                      Icons.shield_outlined,
                      size: 40,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "buyer_protection_policy".tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Center(
              child: Text(
                "buyer_protection_description".tr,
                style:
                    TextStyle(fontSize: 12, color: theme.colorScheme.onSurface),
              ),
            ),
            const SizedBox(height: 12),

            // Bullet points
            ListTile(
              dense: true,
              leading: Icon(
                Icons.check,
                color: theme.colorScheme.onSurface,
                size: 16.w,
              ),
              title: Text("refund_damaged_incorrect_missing".tr),
              contentPadding: EdgeInsets.zero,
              horizontalTitleGap: 0,
            ),
            ListTile(
              dense: true,
              leading: Icon(
                Icons.check,
                color: theme.colorScheme.onSurface,
                size: 16.w,
              ),
              title: Text("refund_defective_counterfeit".tr),
              contentPadding: EdgeInsets.zero,
              horizontalTitleGap: 0,
            ),
            ListTile(
              dense: true,
              leading: Icon(
                Icons.check,
                color: theme.colorScheme.onSurface,
                size: 16.w,
              ),
              title: Text("refund_package_not_received".tr),
              contentPadding: EdgeInsets.zero,
              horizontalTitleGap: 0,
            ),

            const SizedBox(height: 12),

            GestureDetector(
              onTap: () async {
                if (await canLaunchUrl(Uri.parse(privacyPolicyUrl))) {
                  await launchUrl(Uri.parse(privacyPolicyUrl),
                      mode: LaunchMode.externalApplication);
                } else {
                  throw 'Could not launch ${privacyPolicyUrl}';
                }
              },
              child: Text(
                "view_full_policy".tr,
                style: const TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderShipmentWidget extends StatelessWidget {
  Order purchase;
  OrderShipmentWidget({super.key, required this.purchase});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  purchase.status! == 'ready_to_ship' ? "ready_to_ship".tr : '',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                if (purchase.status! == "disputed")
                  Text(
                    "disputed".tr,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (purchase.status! != "disputed")
                  Text(
                    purchase.status! == "shipped"
                        ? "shipped".tr
                        : purchase.status == "cancelled"
                            ? "cancelled".tr
                            : "processing".tr,
                    style: TextStyle(fontSize: 14),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Delivery progress
            LinearProgressIndicator(
              value: 0.5,
              color: Colors.orange,
              backgroundColor: Colors.grey[300],
              minHeight: 6,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 16),

            // Info text
            if (purchase.customer?.address != null)
              Text(
                "deliver_to".trParams(
                    {"address": "${getAddress(purchase.customer!.address!)}."}),
                style: const TextStyle(fontSize: 14),
              ),
            const SizedBox(height: 16),

            Divider(
              color: Colors.grey[600],
            ),
            // Actions
            if (purchase.status != "cancelled")
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    if (purchase.status != "cancelled" &&
                        purchase.status != "disputed")
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.report_problem_outlined,
                            color: Colors.redAccent),
                        title: Text("raise_dispute".tr),
                        trailing: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 15,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        subtitle: Text("report_issue_with_order".tr),
                        onTap: () {
                          // Navigate to dispute page or open a dispute dialog
                          Get.to(() => RaiseDisputePage(order: purchase));
                        },
                      ),
                    if (purchase.status == "disputed")
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.report_problem_outlined,
                            color: Colors.redAccent),
                        title: Text("view_dispute_status".tr),
                        trailing: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 15,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        onTap: () {
                          Get.to(() => DisputeProgressPage(order: purchase));
                        },
                      ),
                    if (purchase.status != "cancelled")
                      Divider(color: Colors.grey[600]),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.chat_bubble_outline),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 15,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      title: Text("message_seller".tr),
                      onTap: () {
                        Get.to(() => ChatRoomPage(purchase.seller!));
                      },
                    ),
                    if (purchase.tracking_url != null &&
                        purchase.tracking_url!.isNotEmpty)
                      Divider(
                        color: Colors.grey[600],
                      ),
                    if (purchase.tracking_url != null &&
                        purchase.tracking_url!.isNotEmpty)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.local_shipping_outlined,
                            color: Theme.of(context).colorScheme.onSurface),
                        title: Text("track_your_order".tr),
                        subtitle: Text(purchase.tracking_number ?? ""),
                        trailing: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 15,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        onTap: () async {
                          if (await canLaunchUrl(
                              Uri.parse(purchase.tracking_url!))) {
                            await launchUrl(Uri.parse(purchase.tracking_url!),
                                mode: LaunchMode.externalApplication);
                          } else {
                            throw 'Could not launch ${purchase.tracking_url}';
                          }
                        },
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PurchaseDetailsPage extends StatelessWidget {
  Order? order;
  PurchaseDetailsPage({super.key, this.order});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("#${order?.invoice?.toString() ?? ""}"),
        leading: const BackButton(),
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            OrderShipmentWidget(purchase: order!),
            const SizedBox(height: 16),
            if (order?.items?.isNotEmpty == true &&
                order?.ordertype != "giveaway")
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (order?.items!.first.product?.images?.isNotEmpty == true)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child: Image.network(
                        order!.items!.first.product!.images!.first,
                        height: 160,
                        fit: BoxFit.cover,
                      ),
                    ),
                  if (order!.items!.first.product?.images?.isNotEmpty == false)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child: Image.asset(
                        "assets/images/image_placeholder.jpg",
                        height: 160,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(order!.items!.first.product!.name ?? "",
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontSize: 21.sp)),
                ],
              ),
            const SizedBox(height: 16),
            Text("order_details".tr,
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            // _infoTile("order_id".tr, "#${order?.invoice.toString() ?? ""}"),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("order".tr,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 14)),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(
                        ClipboardData(text: order!.invoice.toString()));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("copied_to_clipboard"
                            .trParams({"id": order!.invoice.toString()})),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        "#${order!.invoice.toString() ?? ""}",
                        style:
                            const TextStyle(fontSize: 14, color: Colors.blue),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.copy, size: 16, color: Colors.blue),
                    ],
                  ),
                ),
              ],
            ),
            _infoTile(
                "order_date".tr,
                DateFormat("MMM d, yyyy").format(
                  DateTime.fromMillisecondsSinceEpoch(order!.date!),
                )),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("sold_by".tr,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 14)),
                  InkWell(
                    onTap: () {
                      Get.to(() => ViewProfile(user: order!.seller!.id!));
                    },
                    child: Text(order?.seller?.firstName ?? "",
                        style:
                            const TextStyle(fontSize: 14, color: Colors.blue)),
                  ),
                ],
              ),
            ),
            // _infoTile("quantity".tr, order!.quantity.toString()),
            // if (order?.itemId?.productId?.productCategory != null)
            //   _infoTile("category".tr,
            //       order?.itemId?.productId?.productCategory?.name ?? ""),
            const Divider(height: 32),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: Text("receipt_shipping_details".tr),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Get.to(() => ReceiptShippingPage(order: order!));
              },
            ),
            SizedBox(
              height: 20,
            ),
            BuyerProtectionCard()
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

class ReceiptShippingPage extends StatelessWidget {
  Order order;
  ReceiptShippingPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("receipt_shipping_details".tr),
        leading: const BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text("receipt".tr, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _priceTile(
                "subtotal".tr,
                priceHtmlFormat(order.items?.fold(
                    0.0,
                    (previousValue, element) =>
                        previousValue + element.subTotal))),
            _priceTile(
                "shipping".tr,
                priceHtmlFormat(
                    order.ordertype == "giveaway" ? 0.0 : order.shippingFee)),
            _priceTile("taxes".tr, priceHtmlFormat(order.totalTax)),
            const Divider(),
            _priceTile("order_total".tr, priceHtmlFormat(order.getOrderTotal()),
                isBold: true),
            const SizedBox(height: 24),
            Text("shipping".tr, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("ship_to".tr,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(
                    getAddress(order.customer!.address!),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceTile(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          Text(value,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14)),
        ],
      ),
    );
  }
}
