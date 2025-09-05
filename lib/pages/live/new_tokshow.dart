import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tokshop/models/tokshow.dart';

import '../../controllers/product_controller.dart';
import '../../controllers/room_controller.dart';
import '../../main.dart';
import '../../models/category.dart';
import '../../utils/utils.dart';
import '../../widgets/bottom_sheet_dialog.dart';
import '../../widgets/choose_category.dart';
import '../../widgets/content_card_one.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/image_actions.dart';
import '../../widgets/text_form_field.dart';
import '../../widgets/video_player_preview.dart';

class NewTokshow extends StatelessWidget {
  final Tokshow? roomModel;
  NewTokshow({super.key, this.roomModel}) {
    tokshowcontroller.eventTitleController.text = "";
    tokshowcontroller.visibility.value = "public";
    tokshowcontroller.selectedRepeat.value = 'none';
    productController.selectedImages.value = [];
    productController.selectedVides.value = [];
    tokshowcontroller.category.value = null;
    tokshowcontroller.roomCategoryController.text = "";
    WidgetsBinding.instance.addPostFrameCallback((_) {
      productController.getCategories();
    });
    if (roomModel != null) {
      tokshowcontroller.eventTitleController.text = roomModel!.title!;
      tokshowcontroller.eventDate.value =
          DateTime.fromMillisecondsSinceEpoch(roomModel!.date!);
      tokshowcontroller.timeOfDay.value =
          TimeOfDay.fromDateTime(tokshowcontroller.eventDate.value!);
      tokshowcontroller.timeController.text =
          DateFormat('hh:mm a').format(tokshowcontroller.eventDate.value!);
      tokshowcontroller.visibility.value = roomModel!.roomType!;
      tokshowcontroller.selectedRepeat.value = roomModel!.repeat!;

      productController.selectedImages.value = [
        CustomImage(imgType: ImageType.network, path: roomModel!.thumbnail!)
      ];
      if (roomModel!.previewVideos!.isNotEmpty) {
        productController.selectedVides.value = [
          CustomImage(
              imgType: ImageType.network, path: roomModel!.previewVideos!)
        ];
      }

      tokshowcontroller.category.value = roomModel!.category!;
      tokshowcontroller.roomCategoryController.text =
          roomModel!.category!.name!;
    } else {
      final now = DateTime.now();

// Round up to next full hour
      DateTime nextHour = DateTime(now.year, now.month, now.day, now.hour + 1);

// Ensure at least 15 minutes buffer
      if (nextHour.difference(now).inMinutes < 15) {
        nextHour = nextHour.add(const Duration(hours: 1));
      }

// ✅ Set event date (rolls forward if nextHour is tomorrow)
      tokshowcontroller.eventDate.value = DateTime(
        nextHour.year,
        nextHour.month,
        nextHour.day,
      );

// Update date text field
      tokshowcontroller.eventDateController.text =
          DateFormat('MMM dd, yyyy').format(tokshowcontroller.eventDate.value!);

// ✅ Store time (uses 24h internally)
      tokshowcontroller.timeOfDay.value = TimeOfDay(
        hour: nextHour.hour,
        minute: nextHour.minute,
      );

// ✅ Show formatted time (respects AM/PM)
      tokshowcontroller.timeController.text =
          tokshowcontroller.timeOfDay.value!.format(Get.context!);
    }
  }
  final TokShowController tokshowcontroller = Get.find<TokShowController>();

  @override
  Widget build(BuildContext context) {
    tokshowcontroller.roomRepeatController.text.isEmpty
        ? "No Repeat"
        : tokshowcontroller.selectedRepeat.value;
    var theme = Theme.of(context);
    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              CustomButton(
                text: "cancel".tr,
                function: () {
                  Get.back();
                },
                backgroundColor: theme.colorScheme.onSurface,
                textColor: theme.colorScheme.surface,
                width: MediaQuery.of(context).size.width * 0.4,
              ),
              Spacer(),
              CustomButton(
                text: 'schedule'.tr,
                function: () {
                  tokshowcontroller.createShow(context);
                },
                backgroundColor: theme.colorScheme.primary,
                textColor: theme.colorScheme.surface,
                width: MediaQuery.of(context).size.width * 0.4,
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: Text(
          roomModel != null ? 'liveShow_details'.tr : 'schedule_a_live_show'.tr,
          style: theme.textTheme.headlineMedium,
        ),
      ),
      body: Obx(
        () => Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: [
              TextFormField(
                controller: tokshowcontroller.eventTitleController,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  hintStyle: theme.textTheme.bodySmall,
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Colors.grey,
                      width: 0.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Colors.grey,
                      width: 0.5,
                    ),
                  ),
                  filled: false,
                  hintText: 'show_title'.tr,
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 0.5),
                      borderRadius: BorderRadius.circular(6.0)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
                ),
                validator: (_) {
                  if (tokshowcontroller.eventTitleController.text.isEmpty) {
                    return 'title_is_required'.tr;
                  }
                  return null;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      onTap: () async {
                        DateTime? d = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900, 5, 5, 20, 50),
                          lastDate: DateTime(2030, 6, 7, 05, 09),
                          builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: primarycolor,
                                  onPrimary: Colors.white,
                                  surface: kPrimaryColor,
                                  onSurface: Colors.black,
                                ),
                                dialogBackgroundColor: Colors.white,
                              ),
                              child: child!,
                            );
                          },
                        );
                        tokshowcontroller.eventDate.value = d;
                        tokshowcontroller.eventDateController.text =
                            DateFormat('MMM dd, yyyy')
                                .format(tokshowcontroller.eventDate.value!);
                      },
                      controller: tokshowcontroller.eventDateController,
                      hint: DateFormat('MMM dd, yyyy').format(DateTime.now()),
                      readOnly: true,
                      suffixIcon: Icon(Icons.calendar_month),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: CustomTextFormField(
                      onTap: () {
                        showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(
                              hour: DateTime.now().hour,
                              minute: DateTime.now().minute),
                        ).then((pickedTime) {
                          if (pickedTime != null) {
                            tokshowcontroller.timeOfDay.value = pickedTime;
                            int hour = pickedTime.hour == 0
                                ? 12 // Convert 0 (midnight) to 12 AM
                                : (pickedTime.hour > 12
                                    ? pickedTime.hour - 12
                                    : pickedTime.hour);

                            String minute = pickedTime.minute
                                .toString()
                                .padLeft(2, '0'); // Ensure two-digit minutes
                            String period =
                                pickedTime.period == DayPeriod.am ? "AM" : "PM";

                            tokshowcontroller.timeController.text =
                                '$hour:$minute $period';
                          }
                        });
                      },
                      controller: tokshowcontroller.timeController,
                      readOnly: true,
                      suffixIcon: Icon(Icons.timer_sharp),
                      hint: roomModel == null
                          ? TimeOfDay.fromDateTime(DateTime.now())
                              .format(context)
                          : TimeOfDay.fromDateTime(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      roomModel!.date!))
                              .format(context),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              // InkWell(
              //   onTap: () {
              //     Get.to(() => Friends(from: "create_room"));
              //   },
              //   child: Container(
              //     padding:
              //         const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
              //     decoration: BoxDecoration(
              //         borderRadius: const BorderRadius.all(Radius.circular(8)),
              //         border: Border.all(color: Colors.grey, width: 0.5)),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: [
              //         Text(
              //           "moderators".tr,
              //           style: theme.textTheme.bodySmall,
              //         ),
              //         const Icon(
              //           Icons.add_circle_outline_outlined,
              //           color: Colors.grey,
              //           size: 20,
              //         )
              //       ],
              //     ),
              //   ),
              // ),
              // const SizedBox(
              //   height: 20,
              // ),

              CustomTextFormField(
                hint: "how_to_repeat".tr,
                controller: tokshowcontroller.roomRepeatController,
                suffixIcon: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey,
                ),
                readOnly: true,
                onTap: () {
                  showFilterBottomSheet(
                      context,
                      initialChildSize: 0.3,
                      Obx(
                        () => Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15)),
                              color: theme.scaffoldBackgroundColor),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children:
                                tokshowcontroller.repeatRoom.map((element) {
                              return InkWell(
                                onTap: () {
                                  if (element == 'no repeat') {
                                    element = 'none';
                                  }
                                  tokshowcontroller.selectedRepeat.value =
                                      element;
                                  tokshowcontroller.roomRepeatController.text =
                                      element == 'none'
                                          ? "No Repeat"
                                          : 'Repeat $element';
                                  Get.back();
                                },
                                child: Row(
                                  children: [
                                    Radio(
                                      value: element,
                                      groupValue: tokshowcontroller
                                          .selectedRepeat.value,
                                      onChanged: (v) {},
                                      activeColor: Colors.amber,
                                    ),
                                    Text(
                                      element.capitalizeFirst!,
                                      style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w300),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ));
                },
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "media".tr,
                style: theme.textTheme.headlineMedium,
              ),
              Text('room_media_description'.tr.capitalizeFirst!,
                  style: TextStyle(color: kTextColor, fontSize: 12.sp)),
              Row(
                children: [
                  Expanded(
                    child: Obx(() => productController.selectedImages.isEmpty
                        ? ContentCardOne(
                            content: "add_thumbnail".tr,
                            icon: Icons.add_a_photo_outlined,
                            iconAlign: Alignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            backgroundColor: theme
                                .colorScheme.onSecondaryContainer
                                .withValues(alpha: 0.05),
                            margin: EdgeInsets.symmetric(vertical: 15),
                            function: () {
                              imageActions(context);
                            },
                            height: 180.h,
                          )
                        : SizedBox(
                            height: 180.h,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: productController.selectedImages
                                  .length, // Add 1 for ContentCardOne
                              itemBuilder: (context, index) {
                                // Remaining items: Images with delete functionality
                                final imageIndex = index;
                                return Stack(
                                  children: [
                                    Container(
                                      height: 180.h,
                                      margin: EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            10), // Border radius for the container
                                        color: theme
                                            .colorScheme.onSecondaryContainer
                                            .withOpacity(0.05),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            10), // Border radius for the image
                                        child: productController
                                                .selectedImages[imageIndex]
                                                .path
                                                .isEmpty
                                            ? ContentCardOne(
                                                content: "add_thumbnail".tr,
                                                icon:
                                                    Icons.add_a_photo_outlined,
                                                iconAlign: Alignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                backgroundColor: theme
                                                    .colorScheme
                                                    .onSecondaryContainer
                                                    .withValues(alpha: 0.05),
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 15),
                                                function: () {
                                                  imageActions(context);
                                                },
                                                width: 130.h,
                                              )
                                            : productController
                                                        .selectedImages[
                                                            imageIndex]
                                                        .imgType ==
                                                    ImageType.local
                                                ? Image.memory(
                                                    File(productController
                                                            .selectedImages[
                                                                imageIndex]
                                                            .path)
                                                        .readAsBytesSync(),
                                                    fit: BoxFit.cover,
                                                  )
                                                : CachedNetworkImage(
                                                    imageUrl: productController
                                                        .selectedImages[
                                                            imageIndex]
                                                        .path,
                                                    fit: BoxFit.cover,
                                                    placeholder:
                                                        (context, url) =>
                                                            Center(
                                                      child:
                                                          CircularProgressIndicator(), // Placeholder while loading
                                                    ),
                                                  ),
                                      ),
                                    ),
                                    if (productController
                                        .selectedImages[imageIndex]
                                        .path
                                        .isNotEmpty)
                                      Positioned(
                                        right: 10,
                                        top: 5,
                                        child: InkWell(
                                          onTap: () {
                                            productController.selectedImages
                                                .removeAt(imageIndex);
                                            productController
                                                .deleteImageFromFirebase(
                                                    imageIndex);
                                          },
                                          child: Icon(Icons.cancel,
                                              color: Colors.red),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          )),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: Obx(() => productController.selectedVides.isEmpty
                        ? ContentCardOne(
                            content: "add_preview_video".tr,
                            icon: Icons.play_circle,
                            iconAlign: Alignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            backgroundColor: theme
                                .colorScheme.onSecondaryContainer
                                .withValues(alpha: 0.05),
                            margin: EdgeInsets.symmetric(vertical: 15),
                            function: () {
                              imageActions(context, isVideo: true);
                            },
                            height: 180.h,
                          )
                        : SizedBox(
                            height: 180.h,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: productController.selectedVides
                                  .length, // Add 1 for ContentCardOne
                              itemBuilder: (context, index) {
                                // Remaining items: Images with delete functionality
                                final imageIndex =
                                    index; // Adjust index for selectedImages
                                return Stack(
                                  children: [
                                    Container(
                                      height: 180.h,
                                      width: 180.w,
                                      margin: EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            10), // Border radius for the container
                                        color: theme
                                            .colorScheme.onSecondaryContainer
                                            .withOpacity(0.05),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            10), // Border radius for the image
                                        child: VideoPlayerWidget(
                                            customImage: productController
                                                .selectedVides[imageIndex]),
                                      ),
                                    ),
                                    Positioned(
                                      right: 40,
                                      top: 5,
                                      child: InkWell(
                                        onTap: () {
                                          productController.selectedVides
                                              .removeAt(imageIndex);
                                          productController
                                              .deleteImageFromFirebase(
                                                  imageIndex);
                                        },
                                        child: Icon(Icons.cancel,
                                            color: Colors.red),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          )),
                  ),
                ],
              ),
              Obx(() => productController.recentCategories.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(color: theme.dividerColor),
                        Text(
                          "recently_used".tr,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Obx(
                          () => SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: productController.recentCategories
                                  .map((cat) => Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: ActionChip(
                                          backgroundColor: productController
                                                          .selectedCategory
                                                          .value
                                                          ?.id !=
                                                      null &&
                                                  productController
                                                          .selectedCategory
                                                          .value
                                                          ?.id ==
                                                      cat.id
                                              ? theme.colorScheme.onSurface
                                              : null,
                                          label: Text(
                                            cat.name ?? "",
                                            style: TextStyle(
                                                color: productController
                                                                .selectedCategory
                                                                .value
                                                                ?.id !=
                                                            null &&
                                                        productController
                                                                .selectedCategory
                                                                .value
                                                                ?.id ==
                                                            cat.id
                                                    ? theme.colorScheme.surface
                                                    : null),
                                          ),
                                          avatar: Icon(
                                            Icons.history,
                                            size: 16,
                                            color: productController
                                                        .selectedCategory
                                                        .value
                                                        ?.id ==
                                                    cat.id
                                                ? theme.colorScheme.surface
                                                : null,
                                          ),
                                          onPressed: () {
                                            tokshowcontroller.category.value =
                                                cat;

                                            tokshowcontroller
                                                .roomCategoryController
                                                .text = cat.name ?? "";
                                          },
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    )
                  : SizedBox.shrink()),
              Divider(
                color: theme.dividerColor,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'category'.tr,
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 16.sp),
              ),
              SizedBox(
                height: 0.01.sh,
              ),
              CustomTextFormField(
                hint: "select_category".tr,
                controller: tokshowcontroller.roomCategoryController,
                suffixIcon: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey,
                ),
                readOnly: true,
                onTap: () {
                  ChooseCategory(context, function: (ProductCategory category) {
                    tokshowcontroller.category.value = category;
                    tokshowcontroller.roomCategoryController.text =
                        category.name!;
                  });
                },
              ),
              SizedBox(
                height: 0.01.sh,
              ),
              Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'private'.tr,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(fontSize: 16.sp),
                          ),
                          Text('private_room_description'.tr.capitalizeFirst!,
                              style: TextStyle(
                                  color: kTextColor, fontSize: 12.sp)),
                        ],
                      ),
                    ),
                    Switch(
                        activeColor: kPrimaryColor,
                        activeTrackColor: theme.primaryColor,
                        value:
                            (tokshowcontroller.visibility.value == "private"),
                        onChanged: (value) async {
                          tokshowcontroller.visibility.value =
                              value == true ? "private" : "public";
                        })
                  ],
                ),
              ),
              SizedBox(
                height: 0.01.sh,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
