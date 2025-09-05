import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:tokshop/controllers/product_controller.dart';
import 'package:tokshop/pages/inventory/product_list_layout.dart';

import '../../widgets/search_layout.dart';
import '../products/widgets/product_action.dart';
import 'add_edit_product_screen.dart';

class MyInventory extends StatelessWidget {
  String? from;
  Callback? function;
  MyInventory({super.key, this.from, this.function}) {
    productController.page.value = 'myinventory';
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.getProductsByUserId(
          userId: FirebaseAuth.instance.currentUser!.uid, status: "active");
    });
  }
  ProductController productController = Get.find<ProductController>();
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: InkWell(
            child: Icon(Icons.arrow_back_ios),
            onTap: () {
              Get.back();
            },
          ),
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          actions: [
            if (from != 'create_show')
              InkWell(
                child: Obx(
                  () => Text(
                    productController.manage.value ? "cancel".tr : "manage".tr,
                    style: theme.textTheme.labelLarge,
                  ),
                ),
                onTap: () {
                  productController.manage.value =
                      !productController.manage.value;
                  productController.myIventory.refresh();
                },
              ),
            SizedBox(
              width: 20,
            )
          ],
        ),
        body: Column(
          children: [
            TabBar(
              isScrollable: true,
              indicatorColor: theme.colorScheme.primary,
              labelColor: theme.textTheme.bodyLarge!.color,
              unselectedLabelColor: theme.textTheme.bodyMedium!.color,
              labelPadding: EdgeInsets.symmetric(horizontal: 10),
              onTap: (i) {
                productController.inventoryTabIndex.value = i;
                if (i == 0) {
                  productController.getProductsByUserId(
                      userId: FirebaseAuth.instance.currentUser!.uid,
                      status: "active");
                }
                if (i == 1) {
                  productController.getProductsByUserId(
                      userId: FirebaseAuth.instance.currentUser!.uid,
                      status: "inactive");
                }
              },
              padding: EdgeInsets.zero,
              tabAlignment: TabAlignment.start,
              labelStyle: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
              tabs: [Tab(text: 'active'.tr), Tab(text: 'inactive'.tr)],
            ),
            Expanded(
                child: TabBarView(children: [
              Column(
                children: [
                  SearchLayout(
                    function: (text) => {
                      productController.getAllroducts(
                        title: text,
                        type: 'myinventory',
                        status: productController.inventoryTabIndex.value == 0
                            ? 'active'
                            : 'inactive',
                      )
                    },
                  ),
                  Expanded(
                      child: ProductListLayout(
                    function: function,
                    scrollcontroller:
                        productController.listActiveScrollController,
                    from: from,
                  )),
                ],
              ),
              Column(
                children: [
                  SearchLayout(
                    function: (text) => {
                      productController.getAllroducts(
                        title: text,
                        type: 'myinventory',
                        status: productController.inventoryTabIndex.value == 0
                            ? 'active'
                            : 'inactive',
                      )
                    },
                  ),
                  Expanded(
                      child: ProductListLayout(
                    function: function,
                    from: from,
                    scrollcontroller: productController.listScrollController,
                  )),
                ],
              )
            ]))
          ],
        ),
        bottomNavigationBar: Obx(
          () => productController.manage.isTrue
              ? Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Divider(
                        color: theme.dividerColor,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      ProductAction(
                        function:
                            productController.inventorySelectedProducts.isEmpty
                                ? null
                                : () {
                                    if (from == "create_show") {
                                      function!();
                                      return;
                                    }
                                    productController.assingLiveShow(context);
                                  },
                        from: from ?? "inventory",
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                )
              : Container(
                  height: 0,
                ),
        ),
        floatingActionButton: Obx(() => productController.manage.isTrue
            ? Container(
                height: 0,
              )
            : FloatingActionButton(
                onPressed: () {
                  productController.clearProductFields();
                  Get.to(() => AddEditProductScreen());
                },
                child: Icon(Icons.add),
              )),
      ),
    );
  }
}
