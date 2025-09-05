import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/product_controller.dart';
import 'package:tokshop/pages/inventory/product_list_layout.dart';
import 'package:tokshop/pages/products/product_detail.dart';
import 'package:tokshop/pages/products/product_swipe_card.dart';
import 'package:tokshop/widgets/live/no_items.dart';

import '../main.dart';
import '../widgets/shimmers/product_card_grid.dart';
import 'inventory/add_edit_product_screen.dart';
import 'inventory/widgets/product_card.dart';

class ProductGrid extends StatelessWidget {
  String? from;
  String? userId;
  ProductGrid({super.key, this.from, this.userId});

  final ProductController productController = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      if (productController.myIventory.isEmpty) {
        return NoItems();
      }

      return Column(
        children: [
          Row(
            children: [
              Obx(
                () => Text(
                  '${'products'.tr} (${productController.myIventory.length})',
                  style: theme.textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Spacer(),
              Obx(
                () => TextButton.icon(
                  onPressed: () {
                    productController.isGridView.value =
                        !productController.isGridView.value;
                  },
                  icon: Icon(
                    productController.isGridView.value
                        ? Icons.grid_view
                        : Icons.list,
                    color: theme.iconTheme.color,
                  ),
                  label: Text(
                    productController.isGridView.value ? 'grid'.tr : 'list'.tr,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: productController.isGridView.isTrue
                ? _buildGridView(theme)
                : ProductListLayout(
                    scrollcontroller: productController.gridScrollController,
                    from: from,
                  ),
          ),
        ],
      );
    });
  }

  Widget _buildGridView(ThemeData theme) {
    // If loading first batch and no products yet
    if (productController.loading.isTrue &&
        productController.myIventory.isEmpty) {
      // Show shimmer placeholders
      return GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 25,
          mainAxisSpacing: 0,
        ),
        itemCount: 6,
        itemBuilder: (_, index) => buildShimmerProductCard(theme),
      );
    }

    // Display the actual products
    return GridView.builder(
      // IMPORTANT: use the controller's ScrollController here
      controller: productController.gridScrollController,
      padding: const EdgeInsets.all(8.0),
      // If we still have more data to load, add an extra item for a loader
      itemCount: productController.myIventory.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.55,
        crossAxisSpacing: 25,
        mainAxisSpacing: 0,
      ),
      itemBuilder: (context, index) {
        // If it's still within the product list
        // if (index < productController.myIventory.length) {
        final product = productController.myIventory[index];
        return buildProductCard(
          product: product,
          theme: theme,
          isGrid: true,
          function: (_) {
            // Example usage:
            // If user is not product owner => swipe card
            if (FirebaseAuth.instance.currentUser!.uid != product.ownerId?.id) {
              productController.currentProductIndexSwiper.value = index;
              Get.to(() => ProductSwipeCard(
                    list: productController.myIventory,
                  ));
            } else {
              // Otherwise your existing logic
              if (productController.manage.value) {
                _selectProduct(product);
              } else {
                if (userController.viewproductsfrom.value == "viewinventory") {
                  Get.to(() => ProductDetails(product: product));
                } else {
                  productController.populateProductFields(product: product);
                  Get.to(() => AddEditProductScreen(product: product));
                }
              }
            }
          },
        );
        // } else {
        //   // Extra loader item at the bottom
        //   return const Center(
        //     child: Padding(
        //       padding: EdgeInsets.all(16.0),
        //       child: CircularProgressIndicator(),
        //     ),
        //   );
        // }
      },
    );
  }

  void _selectProduct(s) {
    if (productController.inventorySelectedProducts
            .indexWhere((element) => element.id == s.id) ==
        -1) {
      productController.inventorySelectedProducts.add(s);
    } else {
      productController.inventorySelectedProducts
          .removeWhere((element) => element.id == s.id);
    }
    productController.inventorySelectedProducts.refresh();
    productController.myIventory.refresh();
  }
}
