import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../main.dart';
import 'content_card_two.dart';
import 'custom_button.dart';

void imageActions(BuildContext context, {bool isVideo = false}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'chose_image_source'.tr,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontSize: 16),
            ),
            SizedBox(height: 20),
            ContentCardTwo(
              title: 'gallery'.tr,
              icon2: Icons.image_sharp,
              onEdit: () async {
                Get.back();
                if (isVideo) {
                  productController.addVideoButtonCallback(context,
                      imgSource: ImageSource.gallery);
                } else {
                  productController.addImageButtonCallback(context,
                      imgSource: ImageSource.gallery);
                }
              },
            ),
            SizedBox(height: 16),

            ContentCardTwo(
              title: 'camera'.tr,
              icon2: Icons.camera_alt_outlined,
              onEdit: () {
                Get.back();
                if (isVideo) {
                  productController.addVideoButtonCallback(context,
                      imgSource: ImageSource.camera);
                } else {
                  productController.addImageButtonCallback(context,
                      imgSource: ImageSource.camera);
                }
              },
            ),
            SizedBox(height: 10),
            Center(
              child: CustomButton(
                text: "Cancel",
                textColor: Colors.red,
                width: MediaQuery.of(context).size.width * 0.8,
                function: () {
                  Get.back();
                },
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}
