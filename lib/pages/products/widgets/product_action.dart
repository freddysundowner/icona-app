import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/product_controller.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/live/bottom_sheet_options.dart';

class ProductAction extends StatelessWidget {
  Function? function;
  String? from;
  ProductAction({super.key, this.function, this.from = ''});

  ProductController productController = Get.find<ProductController>();
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (from == "inventory")
          InkWell(
            onTap: () {
              productActions(context);
            },
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: from == "inventory"
                    ? productController.inventorySelectedProducts.isNotEmpty
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSecondaryContainer
                    : function == null
                        ? theme.colorScheme.onSecondaryContainer
                        : theme.colorScheme.onSurface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                Icons.more_horiz,
                color: productController.inventorySelectedProducts.isNotEmpty
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        if (from == "inventory")
          SizedBox(
            width: 10,
          ),
        Expanded(
          child: CustomButton(
            text: from == 'create_show'
                ? 'import_product'.trParams({
                    'product': productController
                        .inventorySelectedProducts.length
                        .toString()
                  })
                : "assign_live_show".tr,
            function: from == "inventory" || from == 'create_show'
                ? productController.inventorySelectedProducts.isNotEmpty
                    ? function
                    : null
                : function,
            backgroundColor: theme.colorScheme.primary,
            width: MediaQuery.of(context).size.width * 0.8,
            textColor: theme.scaffoldBackgroundColor,
          ),
        ),
      ],
    );
  }

  void productActions(BuildContext context) {
    Column column = Column(children: [
      InkWell(
        onTap: () async {
          await productController.updateManyProducts(
              productController.inventorySelectedProducts
                  .map((e) => e.id)
                  .toList(),
              context,
              {
                "status": productController.inventoryTabIndex.value == 0
                    ? 'inactive'
                    : 'active'
              });
          productController.inventorySelectedProducts.clear();
          productController.inventorySelectedProducts.refresh();
          productController.getAllroducts(
            status: productController.inventoryTabIndex.value == 0
                ? 'active'
                : 'inactive',
            type: 'myinventory',
            userid: FirebaseAuth.instance.currentUser!.uid,
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(
                Icons.pause,
                size: 20,
              ),
              SizedBox(
                width: 20,
              ),
              Text(
                productController.inventoryTabIndex.value == 0
                    ? "deactivate".tr
                    : "activate".tr,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
      InkWell(
        onTap: () async {
          await productController.deleteProduct(
              productController.inventorySelectedProducts
                  .map((e) => e.id)
                  .toList(),
              context);
          productController.inventorySelectedProducts.clear();
          productController.inventorySelectedProducts.clear();
          productController.inventorySelectedProducts.refresh();
          productController.getAllroducts(
            status: productController.inventoryTabIndex.value == 0
                ? 'active'
                : 'inactive',
            type: 'myinventory',
            userid: FirebaseAuth.instance.currentUser!.uid,
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(
                Icons.delete_forever_outlined,
                size: 20,
                color: Colors.red,
              ),
              SizedBox(
                width: 20,
              ),
              Text(
                "delete".tr,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ),
      )
    ]);
    showCustomBottomSheet(context, column, "options".tr);
  }
}
