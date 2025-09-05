import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:tokshop/pages/inventory/widgets/product_card.dart';

import '../../controllers/product_controller.dart';
import '../../main.dart';
import '../../models/product.dart';
import '../../widgets/live/no_items.dart';
import '../../widgets/shimmers/product_card_list.dart';
import '../products/product_swipe_card.dart';
import 'add_edit_product_screen.dart';

class ProductListLayout extends StatefulWidget {
  final String? from;
  final Callback? function;
  final ScrollController scrollcontroller;

  const ProductListLayout({
    super.key,
    this.from,
    this.function,
    required this.scrollcontroller,
  });

  @override
  _ProductListLayoutState createState() => _ProductListLayoutState();
}

class _ProductListLayoutState extends State<ProductListLayout>
    with AutomaticKeepAliveClientMixin {
  final ProductController productController = Get.find<ProductController>();

  @override
  bool get wantKeepAlive => true; // Preserve widget state (and scroll offset)

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.from == "create_show") {
        productController.manage.value = true;
      } else {
        productController.manage.value = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    var theme = Theme.of(context);

    return Obx(() {
      // When no products are loaded:
      if (productController.myIventory.isEmpty) {
        // If still loading initial data, show shimmer placeholders.
        if (productController.loading.isTrue) {
          return ListView.builder(
            key: const PageStorageKey("myInventoryShimmer"),
            controller: widget.scrollcontroller,
            padding: const EdgeInsets.all(8.0),
            itemCount: 5,
            itemBuilder: (context, index) => ProductCardShimme(theme),
          );
        } else {
          return NoItems();
        }
      } else {
        // When products exist, show the list with an extra spinner item (if loading more).
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                key: const PageStorageKey("myInventoryList"),
                controller: widget.scrollcontroller,
                itemCount: productController.myIventory.length,
                itemBuilder: (context, index) {
                  final product = productController.myIventory[index];
                  product.selected = productController.inventorySelectedProducts
                          .indexWhere((element) => element.id == product.id) !=
                      -1;
                  return buildProductCard(
                    product: product,
                    theme: theme,
                    from: widget.from ?? "",
                    manage: productController.manage.value,
                    isGrid: false,
                    selected: (s) {
                      _selectProduct(s);
                    },
                    function: (Product product) {
                      if (widget.from == "create_show") return;
                      if (userController.viewproductsfrom.value ==
                              "myprofile" ||
                          authController.currentuser?.id !=
                              product.ownerId?.id) {
                        productController.currentProductIndexSwiper.value =
                            index;
                        Get.to(() => ProductSwipeCard(
                              list: productController.myIventory,
                            ));
                      } else {
                        if (productController.manage.value) {
                          _selectProduct(product);
                        } else {
                          productController.populateProductFields(
                              product: product);
                          Get.to(() => AddEditProductScreen(product: product));
                        }
                      }
                    },
                  );
                  // } else {
                  //   // Loader indicator for "load more"
                  //   return const Center(
                  //     child: Padding(
                  //       padding: EdgeInsets.all(16.0),
                  //       child: CircularProgressIndicator(),
                  //     ),
                  //   );
                  // }
                },
              ),
            ),
          ],
        );
      }
    });
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
