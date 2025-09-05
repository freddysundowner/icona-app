import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tokshop/pages/profile/shippinng/shipping_profiles.dart';

class ShippingPage extends StatelessWidget {
  const ShippingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "shipping".tr,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // _buildShippingTile(
          //   title: "Domestic Shipments",
          //   subtitle: "Customize your default shipping options.",
          //   trailingText: "USPS Priority Mail and 1 other",
          //   onTap: () {
          //     // Navigate to Domestic Shipments settings
          //   },
          // ),
          // const SizedBox(height: 12),
          // _buildShippingTile(
          //   title: "Shipping Costs",
          //   subtitle:
          //       "Offer reduced or free shipping to buyers. Selections apply to all future shipments.",
          //   trailingText: "Buyer pays all shipping costs",
          //   onTap: () {
          //     // Navigate to Shipping Costs settings
          //   },
          // ),
          const SizedBox(height: 12),
          _buildShippingTile(
            title: "shipping_profile".tr,
            subtitle: "shipping_profile_description".tr,
            onTap: () {
              Get.to(() => ShippingProfilesPage());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShippingTile({
    required String title,
    required String subtitle,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  if (trailingText != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      trailingText,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ]
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
