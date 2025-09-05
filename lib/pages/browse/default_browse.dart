import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/product_controller.dart';
import 'package:tokshop/controllers/search_controller.dart';
import 'package:tokshop/pages/browse/users_list.dart';
import 'package:tokshop/pages/live/widgets/tokshop_list_grid.dart';

import '../../main.dart';
import '../products_grid.dart';
import 'grid_category_view.dart';

class DefaultBrowse extends StatelessWidget {
  DefaultBrowse({super.key}) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.isGridView.value = false;
    });
  }
  final BrowseController browseController = Get.put(BrowseController());
  final ProductController productController = Get.put(ProductController());
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return DefaultTabController(
      length: 4,
      initialIndex: browseController.currentsearchtab.value,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            isScrollable: true,
            indicatorColor: theme.colorScheme.primary,
            labelColor: Colors.grey,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
            labelPadding: EdgeInsets.symmetric(horizontal: 10),
            labelStyle: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey),
            padding: EdgeInsets.zero,
            tabAlignment: TabAlignment.start,
            onTap: (i) {
              browseController.currentsearchtab.value = i;
              if (i == 3) {
                productController.getCategories();
              }
              if (i == 1) {
                tokShowController.page.value = "";
                tokShowController.getTokshows(limit: '15', status: 'active');
              }
              if (i == 2) {
                userController.getAllUsers();
              }
              if (i == 0) {
                productController.getAllroducts();
              }
            },
            tabs: [
              Tab(
                  child: Text(
                'products'.tr,
              )),
              Tab(child: Text('shows'.tr)),
              Tab(child: Text('users'.tr)),
              Tab(child: Text('categories'.tr))
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                Obx(() => productController.loading.isTrue
                    ? Center(child: CircularProgressIndicator())
                    : ProductGrid(from: "search")),
                Obx(
                  () => tokShowController.isLoading.isTrue
                      ? Center(child: CircularProgressIndicator())
                      : Container(
                          margin: EdgeInsets.only(top: 20),
                          child: TokshopListGrid(
                              rooms: tokShowController.allroomsList,
                              aspectRatio: Platform.isIOS ? 0.40.h : 0.48,
                              scrollController:
                                  tokShowController.roomsScrollController)),
                ),
                UsersList(),
                GridCategoryView(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
