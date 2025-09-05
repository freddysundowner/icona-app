import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/shipping_controller.dart';
import 'package:tokshop/main.dart';

import 'create_shipping_profile.dart';

class ShippingProfilesPage extends StatelessWidget {
  ShippingProfilesPage({super.key}) {
    shippingController
        .getShippingProfilesByUserId(authController.currentuser?.id);
  }

  ShippingController shippingController = Get.put(ShippingController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "shipping_profile".tr,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Get.to(() => CreateShippingProfilePage(
                    shippingProfile: null,
                  ));
              // Handle add new profile
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Obx(() => shippingController.shippigprofiles.isNotEmpty
              ? ListView.builder(
                  itemCount: shippingController.shippigprofiles.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Get.to(() => CreateShippingProfilePage(
                            shippingProfile:
                                shippingController.shippigprofiles[index]));
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  shippingController
                                      .shippigprofiles[index].name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "${shippingController.shippigprofiles[index].weight} - ${shippingController.shippigprofiles[index].scale}"
                                      .toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            Icon(
                              Icons.arrow_forward_ios,
                            )
                          ],
                        ),
                      ),
                    );
                  },
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "no_shipping_profiles".tr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "shipping_profile_desc".tr,
                      style: TextStyle(
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () {
                        Get.to(() => CreateShippingProfilePage());
                      },
                      child: Text(
                        "create_profile".tr,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                )),
        ),
      ),
    );
  }
}
