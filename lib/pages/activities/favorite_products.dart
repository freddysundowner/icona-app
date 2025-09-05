import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/product_controller.dart';

import '../../models/product.dart';
import '../../widgets/live/no_items.dart';
import '../../widgets/shimmers/product_card_grid.dart';
import '../inventory/widgets/product_card.dart';
import '../products/product_detail.dart';

class FavoriteProducts extends StatelessWidget {
  FavoriteProducts({super.key}) {
    // productController.getFavoriteProducts();
  }
  ProductController productController = Get.find<ProductController>();
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return _buildGridView(theme);
  }

  Widget _buildGridView(ThemeData theme) {
    return Obx(
      () => productController.loading.isTrue
          ? GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 25,
                mainAxisSpacing: 0,
              ),
              itemCount: 6, // Number of shimmer placeholders
              itemBuilder: (context, index) => buildShimmerProductCard(
                theme,
              ),
            )
          : productController.favoriteProducts.isEmpty
              ? NoItems()
              : GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 25,
                    mainAxisSpacing: 0,
                  ),
                  itemCount: productController.favoriteProducts.length,
                  itemBuilder: (context, index) {
                    final product = productController.favoriteProducts[index];
                    return buildProductCard(
                        product: product,
                        theme: theme,
                        isGrid: true,
                        function: (Product product) {
                          Get.to(() => ProductDetails(
                                product: product,
                              ));
                        });
                  },
                ),
    );
  }
}
