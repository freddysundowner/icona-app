import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tokshop/models/shippingProfile.dart';
import 'package:tokshop/models/tokshow.dart';
import 'package:tokshop/widgets/text_card_one.dart';

import '../../main.dart';
import '../../models/category.dart';
import '../pages/profile/shippinng/create_shipping_profile.dart';

void ChooseTokshow(BuildContext context,
    {required Function function, bool showOptions = false}) {
  tokShowController.getTokshows(
      userid: FirebaseAuth.instance.currentUser!.uid, type: 'myshows');
  var theme = Theme.of(context);
  showModalBottomSheet(
    context: context,
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
            if (showOptions)
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          productController.productTab.value = "buy_now";
                        },
                        child: Obx(
                          () => Container(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            decoration: BoxDecoration(
                              color: productController.productTab.value ==
                                      "buy_now"
                                  ? theme.colorScheme.onSurface
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Center(
                              child: Text(
                                'buy_it_now'.tr,
                                style: TextStyle(
                                  color: productController.productTab.value ==
                                          "buy_now"
                                      ? theme.colorScheme.surface
                                      : theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 4.0),
                    // Auction Tab
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          productController.productTab.value = "auction";
                        },
                        child: Obx(
                          () => Container(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            decoration: BoxDecoration(
                              color: productController.productTab.value ==
                                      "auction"
                                  ? theme.colorScheme.onSurface
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Center(
                              child: Text(
                                'auction'.tr,
                                style: TextStyle(
                                  color: productController.productTab.value ==
                                          "auction"
                                      ? theme.colorScheme.surface
                                      : theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                Center(
                    child: Text(
                  "choose_show".tr,
                  style: theme.textTheme.headlineSmall,
                )),
                Spacer(),
                InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Icon(Icons.close),
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: Obx(() => ListView.builder(
                    itemBuilder: (c, i) {
                      Tokshow tokshow = tokShowController.mytokshows[i];
                      return InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          function(tokshow);
                          Get.back();
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 10),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  TextCardOne(
                                    title: tokshow.title ?? "",
                                    style: theme.textTheme.headlineSmall,
                                  ),
                                  Spacer(),
                                  Icon(
                                    Icons.arrow_forward_ios_outlined,
                                    size: 15,
                                    color: Colors.grey,
                                  )
                                ],
                              ),
                              Divider(
                                color: theme.dividerColor,
                              )
                            ],
                          ),
                        ),
                      );
                    },
                    itemCount: tokShowController.mytokshows.length,
                  )),
            ),
            SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}

void ChooseCategory(BuildContext context,
    {required Function(ProductCategory) function}) {
  var theme = Theme.of(context);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      List<ProductCategory> currentList = productController.categories;
      List<String> breadcrumbs = ["Categories"];
      ProductCategory? selectedCategory;

      return StatefulBuilder(
        builder: (context, setState) {
          bool atLeafLevel = currentList.isNotEmpty &&
              (currentList.every(
                  (cat) => cat.sub == null || cat.sub!.isEmpty)); // all leaves

          return Padding(
            padding: EdgeInsets.only(
              top: 20,
              left: 10,
              right: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // title row
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (breadcrumbs.length > 1)
                        InkWell(
                          onTap: () {
                            setState(() {
                              breadcrumbs.removeLast();
                              // back to root
                              if (breadcrumbs.length == 1) {
                                currentList = productController.categories;
                              } else {
                                // TODO: deeper nesting tracking if needed
                              }
                              selectedCategory = null;
                            });
                          },
                          child: const Icon(Icons.arrow_back_ios_new),
                        )
                      else
                        const SizedBox(width: 40),
                      Expanded(
                        child: Center(
                          child: Text(
                            breadcrumbs.last,
                            style: theme.textTheme.headlineSmall,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => Get.back(),
                        child: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: currentList.length,
                    itemBuilder: (c, i) {
                      ProductCategory productCategory = currentList[i];

                      if (productCategory.sub != null &&
                          productCategory.sub!.isNotEmpty) {
                        // parent row
                        return InkWell(
                          onTap: () {
                            setState(() {
                              currentList = productCategory.sub!;
                              breadcrumbs.add(productCategory.name ?? "");
                              selectedCategory = null;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(productCategory.name ?? "",
                                        style: theme.textTheme.headlineSmall),
                                    const Spacer(),
                                    const Icon(Icons.arrow_forward_ios_outlined,
                                        size: 15, color: Colors.grey),
                                  ],
                                ),
                                Divider(color: theme.dividerColor),
                              ],
                            ),
                          ),
                        );
                      }

                      // leaf row → radio button
                      // leaf row → radio button
                      return RadioListTile<ProductCategory>(
                        contentPadding: EdgeInsets.symmetric(horizontal: 5),
                        title: Text(
                          productCategory.name ?? "",
                          style: theme.textTheme.headlineSmall,
                        ),
                        value: productCategory,
                        groupValue: selectedCategory,
                        onChanged: (val) {
                          setState(() => selectedCategory = val);
                          productController.addRecent(selectedCategory!);
                        },
                        controlAffinity: ListTileControlAffinity
                            .trailing, // 👈 radio on right
                      );
                    },
                  ),
                ),

                // done button if at leaf level
                if (atLeafLevel)
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: selectedCategory == null
                            ? null
                            : () {
                                function(selectedCategory!);
                                Get.back();
                              },
                        child: Text(
                          "Done",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.surface),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      );
    },
  );
}

void ChooseShipppingProfiles(BuildContext context,
    {required Function(ShippingProfile) function}) {
  var theme = Theme.of(context);
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      ShippingProfile? selectedShippingProfile;

      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 10,
                right: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // title row
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            "shipping_profile".tr,
                            style: theme.textTheme.headlineSmall,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => Get.back(),
                        child: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Obx(() => shippingController.loadingShippingProfile.isTrue
                    ? const CircularProgressIndicator()
                    : const SizedBox.shrink()),
                // empty state
                if (shippingController.shippigprofiles.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "no_shipping_profiles".tr,
                            style: theme.textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () {
                              Get.to(() => CreateShippingProfilePage());
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                            ),
                            label: Text("create_new".tr,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.surface,
                                )),
                          ),
                        ],
                      ),
                    ),
                  ),

                // list of profiles
                if (shippingController.shippigprofiles.isNotEmpty)
                  Expanded(
                    child: Obx(
                      () => ListView.builder(
                        itemCount: shippingController.shippigprofiles.length,
                        itemBuilder: (c, i) {
                          ShippingProfile shipping =
                              shippingController.shippigprofiles[i];
                          return RadioListTile<ShippingProfile>(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 5),
                            title: Text(
                              shipping.name ?? "",
                              style: theme.textTheme.headlineSmall,
                            ),
                            value: shipping,
                            groupValue: selectedShippingProfile,
                            onChanged: (val) {
                              setState(() => selectedShippingProfile = val);
                              function(val!);
                              Get.back();
                            },
                            controlAffinity: ListTileControlAffinity.trailing,
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      );
    },
  );
}
