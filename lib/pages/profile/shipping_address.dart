import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/user_controller.dart';
import 'package:tokshop/main.dart';
import 'package:tokshop/widgets/live/no_items.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/room_controller.dart';
import '../../models/ShippingAddress.dart';
import 'address_details_form.dart';

class ShippingAddresses extends StatelessWidget {
  String? from;
  final AuthController authController = Get.find<AuthController>();
  final UserController userController = Get.find<UserController>();
  final TokShowController _tokshowcontroller = Get.find<TokShowController>();

  ShippingAddresses({Key? key, this.from}) : super(key: key);

  final String socialLinkError = '';
  Widget addressCardSectionn(
      {required IconData icon,
      required String content,
      required Function() onEdit}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeController.isDarkMode.value
            ? Theme.of(Get.context!).colorScheme.secondaryContainer
            : Theme.of(Get.context!).colorScheme.onSecondary.withOpacity(0.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              content,
              style: Theme.of(Get.context!).textTheme.titleSmall,
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit,
                color: Theme.of(Get.context!).colorScheme.onSurface),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }

  void showCustomBottomSheet(BuildContext context, ShippingAddress address) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: Text(
                  'address_action'.tr,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              SizedBox(height: 10),
              InkWell(
                onTap: () {
                  Get.back();
                  userController.makeAddressPrimary(address);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "make_primary".tr,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Icon(
                        Icons.arrow_forward_ios_outlined,
                        size: 20,
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              InkWell(
                onTap: () {
                  Get.back();
                  userController.deleteAddress(address);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "delete".tr,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Icon(
                        Icons.delete,
                        color: Theme.of(context).colorScheme.error,
                        size: 20,
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _tokshowcontroller.onChatPage.value = false;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'addresses'.tr,
        ),
        leading: IconButton(
            onPressed: () => Get.back(), icon: Icon(Icons.arrow_back_ios)),
        actions: [
          IconButton(
              onPressed: () {
                if (from == 'buy_now') {
                  Get.back();
                }
                Get.to(() => AddressDetailsForm());
              },
              icon: Icon(
                Icons.add,
                size: 30,
              ))
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Obx(
          () => userController.myAddresses.isEmpty
              ? NoItems()
              : ListView.builder(
                  itemCount: userController.myAddresses.length,
                  itemBuilder: (context, i) {
                    ShippingAddress address = userController.myAddresses[i];
                    return InkWell(
                      onTap: () {
                        showCustomBottomSheet(context, address);
                      },
                      child: Stack(
                        children: [
                          if (address.primary == true)
                            Positioned(
                              right: 10,
                              top: 5,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(5)),
                                child: Text("Primary"),
                              ),
                            ),
                          Container(
                            margin: EdgeInsets.only(bottom: 10),
                            child: addressCardSectionn(
                              icon: Icons.account_balance_wallet,
                              content:
                                  '${address.name.capitalizeFirst}\n${address.addrress1.capitalizeFirst}\n${address.state} - ${address.city}\n${address.country}',
                              onEdit: () {
                                Get.to(() => AddressDetailsForm(
                                      addressToEdit: address,
                                    ));
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
        ),
      ),
    );
  }
}
