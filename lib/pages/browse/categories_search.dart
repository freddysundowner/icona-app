import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/search_controller.dart';
import 'package:tokshop/widgets/search_layout.dart';

import '../../main.dart';
import 'default_browse.dart';
import 'grid_category_view.dart';

class CategoriesSearch extends StatelessWidget {
  CategoriesSearch({super.key}) {
    productController.getCategories(page: "1", type: "recommended");
  }

  final TextEditingController controller = TextEditingController();
  final BrowseController searchController = Get.find<BrowseController>();

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: null,
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: SearchLayout(
                    height: 60,
                    controller: controller,
                    function: (v) {
                      searchController.searchtext.value = v;
                      searchController.isKeyboardVisible.value = true;
                      searchController.isKeyboardVisible.refresh();
                      int i = searchController.currentsearchtab.value;
                      if (i == 3) {
                        productController.getCategories(
                          title: v,
                        );
                      }
                      if (i == 1) {
                        tokShowController.page.value = "";
                        tokShowController.getTokshows(
                            limit: '15', status: 'active', text: v);
                      }
                      if (i == 2) {
                        userController.getAllUsers(text: v);
                      }
                      if (i == 0) {
                        productController.getAllroducts(title: v);
                      }
                    },
                    onTap: () {
                      searchController.isKeyboardVisible.value = true;
                      if (searchController.currentsearchtab.value == 3) {
                        productController.getCategories(
                            page: "1",
                            type: "recommended",
                            title: searchController.searchtext.value);
                      }
                      if (searchController.currentsearchtab.value == 1) {
                        tokShowController.page.value = "";
                        tokShowController.getTokshows(
                            limit: '15',
                            status: 'active',
                            text: searchController.searchtext.value);
                      }
                      if (searchController.currentsearchtab.value == 2) {
                        userController.getAllUsers(
                            text: searchController.searchtext.value);
                      }
                      if (searchController.currentsearchtab.value == 0) {
                        productController.getAllroducts(
                            title: searchController.searchtext.value);
                      }
                      searchController.isKeyboardVisible.refresh();
                    },
                    margin:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                  ),
                ),
                Obx(() => Row(children: [
                      if (searchController.isKeyboardVisible.isTrue)
                        const SizedBox(width: 20),
                      if (searchController.isKeyboardVisible.isTrue)
                        InkWell(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            searchController.isKeyboardVisible.value = false;
                            productController.getCategories(
                              page: "1",
                              type: "recommended",
                            );
                          },
                          child: Text(
                            "Cancel",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        )
                    ]))
              ],
            ),
            Expanded(
              child: Obx(() => AnimatedSwitcher(
                    duration:
                        const Duration(milliseconds: 300), // Animation speed
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: searchController.isKeyboardVisible.isTrue
                        ? DefaultBrowse(
                            key: const ValueKey(2),
                          )
                        : CategorySearch(
                            key: const ValueKey(
                                2), // Unique key for smooth transition
                          ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

class CategorySearch extends StatelessWidget {
  const CategorySearch({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   "browse_by_category".tr,
        //   style: theme.textTheme.headlineMedium,
        // ),
        // const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                productController.selectedFilterCategoryTab.value =
                    "recommended";
                productController.getCategories(page: "1", type: "recommended");
              },
              child: Obx(
                () => Container(
                  padding: EdgeInsets.symmetric(vertical: 7, horizontal: 13),
                  decoration: BoxDecoration(
                    color: productController.selectedFilterCategoryTab.value ==
                            "recommended"
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.onSecondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "recommended".tr,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: productController
                                      .selectedFilterCategoryTab.value ==
                                  "recommended"
                              ? Theme.of(context).scaffoldBackgroundColor
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            InkWell(
              onTap: () {
                productController.selectedFilterCategoryTab.value = "popular";
                productController.getCategories(page: "1", type: "popular");
              },
              child: Obx(
                () => Container(
                  padding: EdgeInsets.symmetric(vertical: 7, horizontal: 13),
                  decoration: BoxDecoration(
                    color: productController.selectedFilterCategoryTab.value ==
                            "popular"
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.onSecondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "popular".tr,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: productController
                                      .selectedFilterCategoryTab.value ==
                                  "popular"
                              ? Theme.of(context).scaffoldBackgroundColor
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            InkWell(
              onTap: () {
                productController.selectedFilterCategoryTab.value = "a-z";
                productController.getCategories(page: "1", type: "a-z");
              },
              child: Obx(
                () => Container(
                  padding: EdgeInsets.symmetric(vertical: 7, horizontal: 13),
                  decoration: BoxDecoration(
                    color: productController.selectedFilterCategoryTab.value ==
                            "a-z"
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.onSecondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "a-z".tr,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color:
                            productController.selectedFilterCategoryTab.value ==
                                    "a-z"
                                ? Theme.of(context).scaffoldBackgroundColor
                                : Theme.of(context).colorScheme.onSurface),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Expanded(child: GridCategoryView()),
      ],
    );
  }
}
