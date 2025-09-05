import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tokshop/main.dart';
import 'package:tokshop/pages/profile/my_profile.dart';
import 'package:tokshop/pages/profile/view_profile.dart';

import '../../models/order.dart';
import '../../utils/helpers.dart';

class SoldOrderDetails extends StatelessWidget {
  Order order;
  SoldOrderDetails({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    OrderItem item = order.items!.first;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 300,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).maybePop(),
              tooltip: 'back'.tr,
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (item.product?.images?.isEmpty == true)
                    Image.asset(
                      "assets/images/image_placeholder.jpg",
                      fit: BoxFit.cover,
                    ),
                  if (item.product?.images?.isNotEmpty == true)
                    CachedNetworkImage(
                      imageUrl: item.product!.images!.first,
                      fit: BoxFit.cover,
                    ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                  // Big "10K GOLD" badge mock
                  if (order.ordertype != 'tokshow')
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.65),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: Colors.amber.shade400, width: 1.2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.auto_awesome,
                                  color: Colors.amber),
                              const SizedBox(width: 8),
                              Text(
                                order.ordertype ?? "",
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.amber.shade300,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.product!.name ?? "",
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: [
                      // _chip(context, 'new_label'.tr, theme.colorScheme.primary,
                      //     Icons.fiber_new),
                      _chip(context, 'sold'.tr, theme.disabledColor, Icons.lock,
                          disabled: true),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (order.ordertype != 'tokshop')
                        Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSecondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('sale_type'.tr,
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(color: theme.hintColor)),
                              SizedBox(
                                width: 50,
                              ),
                              Text(order.ordertype ?? "",
                                  style: theme.textTheme.bodyLarge),
                            ],
                          ),
                        ),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () {
                          if (order.customer!.id ==
                              authController.currentuser?.id) {
                            Get.to(() => MyProfilePage());
                          } else {
                            Get.to(
                                () => ViewProfile(user: order.customer!.id!));
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('buyer'.tr,
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(color: theme.hintColor)),
                              SizedBox(
                                width: 50,
                              ),
                              buildAvatar(
                                  order.customer!.profilePhoto!.isEmpty
                                      ? order.customer!.firstName
                                      : order.customer!.profilePhoto,
                                  width: 25,
                                  height: 25),
                              const SizedBox(width: 8),
                              Text(order.customer!.firstName!,
                                  style: theme.textTheme.bodyLarge
                                      ?.copyWith(color: Colors.blue)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () {
                          if (order.seller!.id ==
                              authController.currentuser?.id) {
                            Get.to(() => MyProfilePage());
                          } else {
                            Get.to(() => ViewProfile(user: order.seller!.id!));
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSecondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('sold_by'.tr,
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(color: theme.hintColor)),
                              SizedBox(
                                width: 50,
                              ),
                              buildAvatar(
                                  order.seller!.profilePhoto!.isEmpty
                                      ? order.seller!.firstName
                                      : order.seller!.profilePhoto,
                                  width: 25,
                                  height: 25),
                              const SizedBox(width: 8),
                              Text(order.seller!.firstName!,
                                  style: theme.textTheme.bodyLarge
                                      ?.copyWith(color: Colors.blue)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _tabsCard(theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabsCard(ThemeData theme) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text('details'.tr, style: theme.textTheme.titleMedium),
          Divider(),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(order.items?.first.product?.description ?? ""),
              ),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSecondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('category'.tr,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: theme.hintColor)),
                    SizedBox(
                      width: 50,
                    ),
                    Text(
                        order.items?.first.product?.productCategory?.name ?? "",
                        style: theme.textTheme.bodyLarge),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.hintColor)),
          ),
          Text(value,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String text, Color color, IconData icon,
      {bool disabled = false}) {
    final theme = Theme.of(context);
    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: disabled
              ? theme.disabledColor.withOpacity(0.08)
              : color.withOpacity(0.12),
          border: Border.all(
              color: disabled ? theme.disabledColor : color.withOpacity(0.6)),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: disabled ? theme.disabledColor : color),
            const SizedBox(width: 6),
            Text(text,
                style: theme.textTheme.labelLarge?.copyWith(
                    color: disabled ? theme.disabledColor : color,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  String _formatViews(double n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toStringAsFixed(0);
  }
}
