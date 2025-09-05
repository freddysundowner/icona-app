import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tokshop/models/category.dart';

import '../../main.dart';

class StickyCategoriesDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and Title in a Row
          Row(
            children: [
              Icon(Icons.grid_view, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'newCategories'.tr,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SchibstedGrotesk',
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 8), // Space between title and categories
          // Horizontal List of Categories
          SizedBox(
            height: 40, // Set a fixed height for the list
            child: Obx(
              () => ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount:
                    productController.categories.length + 1, // +1 for "All"
                itemBuilder: (context, index) {
                  ProductCategory? category;
                  String categoryName;
                  String? categoryId;

                  if (index == 0) {
                    categoryName = "All";
                    categoryId = null; // Use null or an empty string as default
                  } else {
                    category = productController
                        .categories[index - 1]; // Shifted index
                    categoryName = category.name ?? "";
                    categoryId = category.id;
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        productController.selectedFilterCategory.value = index;
                        productController.getAllroducts(
                          category: categoryId ?? "", // Send null for "All"
                          type: "home",
                        );
                      },
                      child: Obx(
                        () => Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.0),
                          decoration: BoxDecoration(
                            color: index ==
                                    productController
                                        .selectedFilterCategory.value
                                ? Colors.yellow
                                : Colors.grey[800],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              categoryName,
                              style: TextStyle(
                                color: index ==
                                        productController
                                            .selectedFilterCategory.value
                                    ? Colors.black
                                    : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'SchibstedGrotesk',
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 100; // Fixed height for the header
  @override
  double get minExtent => 100; // Fixed height for the header
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
