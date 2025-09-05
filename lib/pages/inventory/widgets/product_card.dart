import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/utils/helpers.dart';

import '../../../main.dart';
import '../../../models/product.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/show_image.dart';
import '../../products/widgets/favorite_layout.dart';
import '../add_edit_product_screen.dart';
import 'inshow_budge.dart';

Widget buildProductCard(
    {Product? product,
    ThemeData? theme,
    bool? manage = false,
    String from = '',
    Function? selected,
    required bool isGrid,
    Function? function}) {
  return InkWell(
    splashColor: Colors.transparent,
    onTap: () => from == "create_show"
        ? selected!(product)
        : function != null
            ? function(product)
            : null,
    child: Column(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 10),
          child: isGrid
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 0.8,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: displayProductImage(product!),
                          ),
                        ),
                        Positioned(
                            right: 10, top: 5, child: favoriteIcon(product)),
                        inshowBadge(theme!, product),
                        if (userController.viewproductsfrom.value ==
                            "myprofile")
                          Positioned(
                            top: 0,
                            right: 0,
                            child: InkWell(
                              onTap: () {
                                productController.populateProductFields(
                                    product: product);
                                Get.to(() =>
                                    AddEditProductScreen(product: product));
                              },
                              child: Container(
                                margin: EdgeInsets.only(right: 15, top: 10),
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            buildProductCardContent(product, theme, isGrid),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Stack(
                      children: [
                        if (product?.images == null || product!.images!.isEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              "assets/images/image_placeholder.jpg",
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                            ),
                          ),
                        favoriteIcon(product!),
                        if (product.images != null &&
                            product.images!.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: product.images!.first,
                              width: 80.h,
                              height: 80.h,
                              fit: BoxFit.cover,
                            ),
                          ),
                        // buildBadge(theme),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: buildProductCardContent(
                            product, theme!, isGrid,
                            from: from),
                      ),
                    ),
                    if (manage == true)
                      Checkbox(
                          value: product.selected,
                          onChanged: (value) {
                            selected!(product);
                          })
                  ],
                ),
        ),
        if (!isGrid)
          Divider(
            color: theme.dividerColor.withAlpha(100),
          ),
        if (!isGrid)
          SizedBox(
            height: 10,
          )
      ],
    ),
  );
}

Widget displayProductImage(Product product) {
  return product.images?.isNotEmpty == true
      ? CachedNetworkImage(
          imageUrl: product.images!.first, fit: BoxFit.cover, width: 10)
      : Image.asset(
          'assets/images/image_placeholder.jpg',
          fit: BoxFit.cover,
          width: double.infinity,
        );
}

List<Widget> buildProductCardContent(
    Product product, ThemeData theme, bool isGrid,
    {double titleSize = 14, String from = ''}) {
  return [
    if (from == "search")
      Row(
        children: [
          ShowImage(
            image: product.ownerId?.profilePhoto ?? '',
            height: 20,
            width: 20,
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(product.ownerId?.firstName ?? '',
                style: theme.textTheme.headlineSmall!
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 12.sp)),
          ),
          Icon(Icons.star, color: Colors.amber, size: 12.sp),
          Text(product.reviews!.length.toString(),
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontSize: 12.sp, fontWeight: FontWeight.normal)),
        ],
      ),
    Text(
      product.name!.capitalizeFirst ?? "",
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: titleSize ?? 13,
      ),
    ),
    if (product.productCategory != null)
      Text(
        product.productCategory?.name ?? "",
        style: theme.textTheme.bodyLarge
            ?.copyWith(color: Colors.grey, fontSize: 11.sp),
      ),
    Row(
      children: [
        Text(
          priceHtmlFormat(product.price ?? 0),
          style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16.sp),
        ),
        Text(" • "),
        Text(
          'available_count'.trParams({"count": product.quantity.toString()}),
          style: theme.textTheme.titleSmall?.copyWith(fontSize: 12.sp),
        ),
      ],
    ),
    const SizedBox(height: 4),
    if (userController.viewproductsfrom.value == "myprofile" && !isGrid)
      CustomButton(
        text: "Edit".tr,
        function: () {
          productController.populateProductFields(product: product);
          Get.to(() => AddEditProductScreen(product: product));
        },
        width: 100.w,
        height: 30.h,
        backgroundColor: theme.dividerColor.withValues(alpha: 0.5),
        iconData: Icons.edit,
        iconColor: Colors.white,
      ),
  ];
}
