import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tokshop/widgets/live/bottom_sheet_options.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/user_controller.dart';
import '../../widgets/content_card_two.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/text_form_field.dart';

class EditProfile extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final UserController _userController = Get.find<UserController>();
  final TextEditingController firstNameController = TextEditingController();
  EditProfile({super.key}) {
    _userController.populateUserFormData();
  }
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          child: Icon(Icons.arrow_back_ios, color: theme.colorScheme.onSurface),
          onTap: () => Get.back(),
        ),
        title: Text('edit_profile'.tr),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child: IconButton(
              icon: Text(
                "Save",
                style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                _userController.updateProfile(context);
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(
              height: 120.h,
              child: Obx(
                () => Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 120.h,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(0.6),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          image: authController.usermodel.value!.coverPhoto !=
                                      null &&
                                  authController.usermodel.value!.coverPhoto !=
                                      ""
                              ? DecorationImage(
                                  image: NetworkImage(authController
                                          .usermodel.value!.coverPhoto ??
                                      ''),
                                  fit: BoxFit.cover,
                                )
                              : null),
                    ),
                    if (_userController.coverPhotoLocalPath.value.isNotEmpty)
                      Image.memory(
                        File(_userController.coverPhotoLocalPath.value)
                            .readAsBytesSync(),
                        fit: BoxFit.cover,
                        height: 120.h,
                        width: MediaQuery.of(context).size.width,
                      ),
                    Positioned(
                      top: 20,
                      left: 8,
                      right: 8, // Add right constraint to ensure proper layout
                      child: IconButton(
                        onPressed: () async {
                          _uploadImage(context, "cover");
                        },
                        icon: Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -30,
                      left: 20,
                      child: GestureDetector(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.shade200,
                              border: Border.all(color: Colors.white, width: 5),
                              image: _userController
                                      .profileImageLocalPath.value.isNotEmpty
                                  ? DecorationImage(
                                      image: MemoryImage(
                                      File(_userController
                                              .profileImageLocalPath.value)
                                          .readAsBytesSync(),
                                    ))
                                  : DecorationImage(
                                      image: NetworkImage(authController
                                          .usermodel.value!.profilePhoto!))),
                          child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black45.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  Icons
                                      .camera_alt, // Replace with your desired icon
                                  size: 30.0, // Adjust the icon size
                                  color: Colors.white, // Icon color
                                ),
                              )),
                        ),
                        onTap: () {
                          _uploadImage(context, 'profile');
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "personal_details".tr,
                    style:
                        theme.textTheme.displaySmall?.copyWith(fontSize: 16.sp),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  CustomTextFormField(
                    controller: _userController.displaynameEditFormField,
                    hint: 'display_name'.tr,
                    label: 'display_name'.tr,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  CustomTextFormField(
                    controller: _userController.usernameEditFormField,
                    hint: 'username'.tr,
                    label: 'username'.tr,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  CustomTextFormField(
                    controller: _userController.bioEditFormField,
                    hint: 'bio'.tr,
                    label: 'bio'.tr,
                    minLines: 5,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _uploadImage(BuildContext context, String type) {
    Column actionsWidget = Column(children: [
      SizedBox(height: 16),
      Text(
        'chose_image_source'.tr,
        style:
            Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 16),
      ),
      SizedBox(height: 20),
      ContentCardTwo(
        title: 'gallery'.tr,
        icon2: Icons.image_sharp,
        onEdit: () async {
          Get.back();
          _userController.addImageButtonCallback(context,
              imgSource: ImageSource.gallery, type: type);
        },
      ),
      SizedBox(height: 16),
      ContentCardTwo(
        title: 'camera'.tr,
        icon2: Icons.camera_alt_outlined,
        onEdit: () {
          Get.back();
          _userController.addImageButtonCallback(context,
              imgSource: ImageSource.camera);
        },
      ),
      SizedBox(height: 10),
      Center(
        child: CustomButton(
          text: "cancel".tr,
          textColor: Colors.red,
          width: MediaQuery.of(context).size.width * 0.8,
          function: () {
            Get.back();
          },
        ),
      ),
      SizedBox(height: 20),
    ]);
    showCustomBottomSheet(context, actionsWidget, "actions".tr);
  }
}
