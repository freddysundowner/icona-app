import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tokshop/models/tokshow.dart';

import '../../controllers/room_controller.dart';
import '../../main.dart';

class ShortsSection extends StatelessWidget {
  ShortsSection({super.key}) {
    productController.getCategories();
    tokShowController.getTokshows();
  }
  final TokShowController tokShowController = Get.find<TokShowController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => tokShowController.allroomsList.isEmpty
        ? Container(
            height: 0,
          )
        : SizedBox(
            height: 330,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Icon(Icons.flash_on, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'for_you'.tr,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'SchibstedGrotesk',
                              color: Colors.white,
                            ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    itemCount: tokShowController.allroomsList.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.7,
                    ),
                    itemBuilder: (context, index) {
                      Tokshow tokshow = tokShowController.allroomsList[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: tokshow.thumbnail!,
                          ),
                        ),
                      );
                    },
                  ), // make it grid
                ),
              ],
            ),
          ));
  }
}
