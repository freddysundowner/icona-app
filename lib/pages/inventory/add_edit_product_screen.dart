import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/auction_controller.dart';
import 'package:tokshop/controllers/product_controller.dart';
import 'package:tokshop/main.dart';
import 'package:tokshop/models/category.dart';
import 'package:tokshop/models/giveaway.dart';
import 'package:tokshop/models/tokshow.dart';
import 'package:tokshop/pages/inventory/widgets/choose_seconds.dart';
import 'package:tokshop/utils/configs.dart';

import '../../models/product.dart';
import '../../models/shippingProfile.dart';
import '../../utils/styles.dart';
import '../../widgets/choose_category.dart';
import '../../widgets/content_card_one.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/image_actions.dart';
import '../../widgets/text_form_field.dart';
import '../products/widgets/give_away.dart';

class AddEditProductScreen extends StatelessWidget {
  final Product? product;
  final GiveAway? giveaway;
  String? from;
  AddEditProductScreen({super.key, this.product, this.from, this.giveaway}) {
    productController.clearProductFields();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      productController.loadRecents();
      if (giveaway != null) {
        giveAwayController.giveawayid.value = '';
        productController.populateProductFields(giveaway: giveaway);
      } else {
        productController.getCategories();
        tokShowController.getTokshows(
            userid: authController.currentuser!.id!, type: "myshows");
      }
    });
  }
  ProductController productController = Get.find<ProductController>();
  final _basicDetailsFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(Icons.clear)),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text("create_listing".tr),
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: Form(
            key: _basicDetailsFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "media".tr,
                  style: theme.textTheme.titleMedium,
                ),
                Obx(() => productController.selectedImages.isEmpty
                    ? ContentCardOne(
                        content: "add_photo".tr,
                        icon: Icons.add_a_photo_outlined,
                        slogan: "1_required".tr,
                        iconAlign: Alignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        backgroundColor: theme.colorScheme.onSecondaryContainer
                            .withValues(alpha: 0.05),
                        margin: EdgeInsets.symmetric(vertical: 15),
                        function: () {
                          imageActions(context);
                        },
                        height: 90.h,
                      )
                    : SizedBox(
                        height: 90.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: productController.selectedImages.length +
                              1, // Add 1 for ContentCardOne
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              // First item: ContentCardOne
                              return Container(
                                margin: EdgeInsets.only(right: 10),
                                child: ContentCardOne(
                                  content: "Add Photo",
                                  icon: Icons.add_circle_outline_outlined,
                                  iconAlign: Alignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  backgroundColor: theme
                                      .colorScheme.onSecondaryContainer
                                      .withOpacity(0.05),
                                  function: () {
                                    imageActions(context);
                                  },
                                  height: 120.h,
                                  width: 100.w,
                                  textStyle: theme.textTheme.bodySmall,
                                ),
                              );
                            }

                            // Remaining items: Images with delete functionality
                            final imageIndex =
                                index - 1; // Adjust index for selectedImages
                            return Stack(
                              children: [
                                Container(
                                  height: 120.h,
                                  width: 100.h,
                                  margin: EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        10), // Border radius for the container
                                    color: theme
                                        .colorScheme.onSecondaryContainer
                                        .withOpacity(0.05),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        10), // Border radius for the image
                                    child: productController
                                                .selectedImages[imageIndex]
                                                .imgType ==
                                            ImageType.local
                                        ? Image.memory(
                                            File(productController
                                                    .selectedImages[imageIndex]
                                                    .path)
                                                .readAsBytesSync(),
                                            fit: BoxFit.cover,
                                          )
                                        : CachedNetworkImage(
                                            imageUrl: productController
                                                .selectedImages[imageIndex]
                                                .path,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Center(
                                              child:
                                                  CircularProgressIndicator(), // Placeholder while loading
                                            ),
                                            errorWidget: (context, url,
                                                    error) =>
                                                Icon(Icons.error), // Error icon
                                          ),
                                  ),
                                ),
                                Positioned(
                                  right: 10,
                                  top: 5,
                                  child: InkWell(
                                    onTap: () {
                                      productController.selectedImages
                                          .removeAt(imageIndex);
                                      productController
                                          .deleteImageFromFirebase(imageIndex);
                                    },
                                    child:
                                        Icon(Icons.cancel, color: Colors.red),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      )),
                Obx(
                  () => Text(
                    "max_photos".trParams({
                      "count":
                          productController.selectedImages.length.toString()
                    }),
                    style: theme.textTheme.labelSmall,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Obx(() => productController.recentCategories.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(color: theme.dividerColor),
                          Text(
                            "recently_used".tr,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Obx(
                            () => SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: productController.recentCategories
                                    .map((cat) => Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8.0),
                                          child: ActionChip(
                                            backgroundColor: productController
                                                            .selectedCategory
                                                            .value
                                                            ?.id !=
                                                        null &&
                                                    productController
                                                            .selectedCategory
                                                            .value
                                                            ?.id ==
                                                        cat.id
                                                ? theme.colorScheme.onSurface
                                                : null,
                                            label: Text(
                                              cat.name ?? "",
                                              style: TextStyle(
                                                  color: productController
                                                                  .selectedCategory
                                                                  .value
                                                                  ?.id !=
                                                              null &&
                                                          productController
                                                                  .selectedCategory
                                                                  .value
                                                                  ?.id ==
                                                              cat.id
                                                      ? theme
                                                          .colorScheme.surface
                                                      : null),
                                            ),
                                            avatar: Icon(
                                              Icons.history,
                                              size: 16,
                                              color: productController
                                                          .selectedCategory
                                                          .value
                                                          ?.id ==
                                                      cat.id
                                                  ? theme.colorScheme.surface
                                                  : null,
                                            ),
                                            onPressed: () {
                                              print("cat id ${cat.id}");
                                              productController
                                                  .selectedCategory.value = cat;

                                              productController
                                                  .categoryFieldController
                                                  .text = cat.name ?? "";
                                            },
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      )
                    : SizedBox.shrink()),
                Divider(
                  color: theme.dividerColor,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "product_details".tr,
                  style: theme.textTheme.titleMedium,
                ),
                SizedBox(
                  height: 20,
                ),
                CustomTextFormField(
                  hint: "category".tr,
                  controller: productController.categoryFieldController,
                  suffixIcon: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                  readOnly: true,
                  onTap: () {
                    ChooseCategory(context,
                        function: (ProductCategory category) {
                      productController.selectedCategory.value = category;

                      productController.categoryFieldController.text =
                          category.name ?? "";
                    });
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                CustomTextFormField(
                    hint: "title".tr,
                    controller: productController.titleFieldController),
                SizedBox(
                  height: 20,
                ),
                if (productController.productTab.value != "auction")
                  CustomTextFormField(
                    hint: "description".tr,
                    controller: productController.desciptionFieldController,
                    txtType: TextInputType.multiline,
                    minLines: 5,
                  ),
                SizedBox(
                  height: 10,
                ),
                CustomTextFormField(
                    hint: "quantity".tr,
                    txtType: TextInputType.number,
                    controller: productController.qtyFieldController,
                    minLines: 1),
                SizedBox(
                  height: 10,
                ),
                Divider(
                  color: theme.dividerColor,
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  "pricing".tr,
                  style: theme.textTheme.titleMedium,
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSecondaryContainer,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            productController.productTab.value = "buy_now";
                            productController.reserve.value = false;
                            productController.liveactivetab.value = 1;
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
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            productController.productTab.value = "auction";
                            productController.reserve.value = true;
                            productController.liveactivetab.value = 0;
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
                      if (tokShowController.currentRoom.value != null)
                        SizedBox(width: 4.0),
                      if (tokShowController.currentRoom.value != null)
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              productController.productTab.value = "giveaway";
                              productController.reserve.value = false;
                              productController.liveactivetab.value = 2;
                            },
                            child: Obx(
                              () => Container(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                decoration: BoxDecoration(
                                  color: productController.productTab.value ==
                                          "giveaway"
                                      ? theme.colorScheme.onSurface
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: Center(
                                  child: Text(
                                    'giveaway'.tr,
                                    style: TextStyle(
                                      color:
                                          productController.productTab.value ==
                                                  "giveaway"
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
                SizedBox(
                  height: 20,
                ),
                CustomTextFormField(
                  hint: "shipping_profile".tr,
                  controller: productController.shippingprofileFieldController,
                  suffixIcon: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                  readOnly: true,
                  onTap: () {
                    shippingController.getShippingProfilesByUserId(
                        authController.currentuser!.id);
                    ChooseShipppingProfiles(context,
                        function: (ShippingProfile category) {
                      productController.shippingprofile.value = category;

                      productController.shippingprofileFieldController.text =
                          category.name ?? "";
                    });
                  },
                ),
                const SizedBox(height: 20),
                Obx(() => productController.productTab.value == "buy_now"
                    ? Column(
                        children: [
                          CustomTextFormField(
                            hint: "price".tr,
                            controller:
                                productController.originalPriceFieldController,
                            minLines: 1,
                            prefix: Container(
                                margin: EdgeInsets.only(right: 10),
                                child: Text(currencySymbol)),
                            txtType: TextInputType.number,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          CustomTextFormField(
                            hint: "discounted_price".tr,
                            controller:
                                productController.discountPriceFieldController,
                            minLines: 1,
                            txtType: TextInputType.number,
                            prefix: Container(
                                margin: EdgeInsets.only(right: 10),
                                child: Text(currencySymbol)),
                          ),
                        ],
                      )
                    : productController.productTab.value == "auction"
                        ? ActionFields()
                        : GiveawayWidget()),
                SizedBox(
                  height: 20,
                ),
                Divider(color: Theme.of(context).dividerColor),
                const SizedBox(height: 10),
                Obx(
                  () => productController.productTab.value != "buy_now"
                      ? Container(
                          height: 0,
                        )
                      : Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'reserve_for_live'.tr,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(fontSize: 16.sp),
                                    ),
                                    Text(
                                        'reserve_for_live_description'
                                            .tr
                                            .capitalizeFirst!,
                                        style: TextStyle(fontSize: 12.sp)),
                                  ],
                                ),
                              ),
                              Obx(
                                () => Switch(
                                    activeColor: kPrimaryColor,
                                    activeTrackColor: theme.primaryColor,
                                    value: productController.reserve.value,
                                    onChanged: (value) async {
                                      productController.reserve.value = value;
                                    }),
                              )
                            ],
                          ),
                        ),
                ),
                if (productController.productTab.value == "buy_now")
                  SizedBox(
                    height: 20,
                  ),
                Obx(() => productController.reserve.isTrue
                    ? CustomTextFormField(
                        hint: "select_show".tr,
                        controller: productController.selectedshowController,
                        suffixIcon: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey,
                        ),
                        readOnly: true,
                        onTap: () {
                          ChooseTokshow(context, function: (Tokshow tokshow) {
                            productController.selectedTokshow.value = tokshow;
                            productController.selectedshowController.text =
                                tokshow.title ?? "";
                          });
                        },
                      )
                    : Container()),
                SizedBox(
                  height: 20,
                ),
                Obx(() => productController.productTab.value == "buy_now"
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("variations".tr,
                              style: theme.textTheme.titleMedium),
                          SizedBox(height: 8),
                          InkWell(
                            onTap: () => showColorPickerDialog(context),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Obx(
                                  () => productController.selectedColors.isEmpty
                                      ? Text("select_colors".tr)
                                      : Text(
                                          "add_more".tr,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        )),
                            ),
                          ),
                          SizedBox(height: 10),
                          Obx(() => Wrap(
                                spacing: 8.0,
                                children: productController.selectedColors
                                    .map((colorName) {
                                  // Find the corresponding color value
                                  final colorMap = productController
                                      .availableColors
                                      .firstWhere(
                                          (element) =>
                                              element["name"] == colorName,
                                          orElse: () => {
                                                "color": Colors.grey
                                              }); // Default to grey if not found

                                  return InkWell(
                                    splashColor: Colors.transparent,
                                    onTap: () {
                                      productController.selectedColors
                                          .remove(colorName);
                                    },
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      margin: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: colorMap[
                                            "color"], // Set background color
                                        shape:
                                            BoxShape.circle, // Make it circular
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              )),
                          SizedBox(
                            height: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 8),
                              InkWell(
                                onTap: () => showAllSizesDialog(context),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "pick_sizes".tr,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Obx(() => Wrap(
                                    spacing: 8.0,
                                    children: productController.selectedSizes
                                        .map((size) {
                                      return Chip(
                                        label: Text(
                                          size,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        backgroundColor:
                                            theme.scaffoldBackgroundColor,
                                        onDeleted: () {
                                          productController.selectedSizes
                                              .remove(size);
                                        },
                                      );
                                    }).toList(),
                                  )),
                            ],
                          ),
                        ],
                      )
                    : Container(height: 0)),
                SizedBox(
                  height: 30,
                )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              CustomButton(
                text: "draft".tr,
                function: () {
                  productController.saveProduct(context, "inactive", product,
                      from: from);
                },
                backgroundColor: theme.colorScheme.onSurface,
                textColor: theme.colorScheme.surface,
                width: MediaQuery.of(context).size.width * 0.4,
              ),
              Spacer(),
              CustomButton(
                text: product != null || giveaway != null
                    ? 'update'.tr
                    : "publish".tr,
                function: () {
                  if (productController.productTab.value == "buy_now" ||
                      productController.productTab.value == "giveaway") {
                    productController.saveProduct(context, "active", product,
                        from: from);
                  }
                  if (productController.productTab.value == "auction") {
                    productController.liveactivetab.value = 0;
                    productController.saveProductAuction(product, context);
                  }
                },
                backgroundColor: theme.colorScheme.primary,
                textColor: theme.colorScheme.surface,
                width: MediaQuery.of(context).size.width * 0.4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showAllSizesDialog(BuildContext context) {
    Get.defaultDialog(
      title: "Select Sizes".tr,
      content: Obx(() {
        return Wrap(
          spacing: 8.0,
          children: productController.availableSizes.map((size) {
            final isSelected = productController.selectedSizes.contains(size);

            return GestureDetector(
              onTap: () {
                // Toggle selection
                if (isSelected) {
                  productController.selectedSizes.remove(size);
                } else {
                  productController.selectedSizes.add(size);
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                margin: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Text(
                  size,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }),
      confirm: ElevatedButton(
        onPressed: () {
          Get.back();
        },
        child: Text("Done"),
      ),
    );
  }

  void showColorPickerDialog(BuildContext context) {
    Get.defaultDialog(
      title: "select_color".tr,
      content: Obx(() {
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: productController.availableColors.map((colorMap) {
            final colorName = colorMap["name"];
            final colorValue = colorMap["color"];
            return GestureDetector(
              onTap: () {
                if (productController.selectedColors.contains(colorName)) {
                  productController.selectedColors.remove(colorName);
                } else {
                  productController.selectedColors.add(colorName);
                }
              },
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: productController.selectedColors.contains(colorName)
                      ? colorValue?.withOpacity(0.6)
                      : colorValue,
                  border: Border.all(
                    color: productController.selectedColors.contains(colorName)
                        ? Colors.black
                        : Colors.transparent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: colorValue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(colorName),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      }),
      confirm: ElevatedButton(
        onPressed: () {
          productController.colorFieldController.text =
              productController.selectedColors.join(", ");
          Get.back();
        },
        child: Text("Done"),
      ),
    );
  }
}

class ActionFields extends StatelessWidget {
  ActionFields({
    super.key,
  });
  ProductController productController = Get.find<ProductController>();
  AuctionController auctionController = Get.find<AuctionController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextFormField(
                hint: "starting_price".tr,
                controller: productController.originalPriceFieldController,
                minLines: 1,
                txtType: TextInputType.number, // Use TextInputType.txtType
                prefix: Container(
                    margin: EdgeInsets.only(right: 10),
                    child: Text(
                      currencySymbol,
                      style: TextStyle(color: Colors.white),
                    )),
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Expanded(
              child: CustomTextFormField(
                hint: "time_limit".tr,
                controller: auctionController.selectedSecondsController,
                suffixIcon: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey,
                ),
                readOnly: true,
                onTap: () {
                  ChooseSeconds(context);
                },
              ),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("sudden_death".tr,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontSize: 16.sp)),
                  Text(
                    "sudden_death_desc".tr,
                    style: TextStyle(fontSize: 11.sp),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Obx(
              () => Switch(
                  value: auctionController.suddentAuction.value,
                  onChanged: (v) {
                    auctionController.suddentAuction.value =
                        !auctionController.suddentAuction.value;
                  }),
            ),
            Divider(),
          ],
        ),
      ],
    );
  }
}
