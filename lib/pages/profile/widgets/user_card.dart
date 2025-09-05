import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../controllers/user_controller.dart';
import '../../../models/user.dart';
import '../../../widgets/custom_button.dart';
import '../../chats/chat_room_page.dart';
import '../my_profile.dart';
import '../view_profile.dart';

class UserCard extends StatelessWidget {
  UserModel userModel;
  Int? index;
  bool showFollowButton;
  bool showFollowers;
  bool showMessage;
  bool showProfile;
  final UserController _userController = Get.find<UserController>();
  UserCard({
    super.key,
    required this.userModel,
    this.index,
    this.showMessage = false,
    this.showProfile = false,
    this.showFollowButton = true,
    this.showFollowers = true,
  });

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return InkWell(
      splashColor: Colors.transparent,
      onTap: () {
        _userController.viewproductsfrom.value = "viewinventory";
        if (userModel.id != FirebaseAuth.instance.currentUser!.uid) {
          Get.to(() => ViewProfile(user: userModel.id!));
        } else {
          Get.to(() => MyProfilePage());
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15.0, top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: Row(
              children: [
                userModel.profilePhoto != null && userModel.profilePhoto != ""
                    ? CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(userModel.profilePhoto!),
                      )
                    : const CircleAvatar(
                        radius: 25,
                        backgroundImage:
                            AssetImage("assets/icons/profile_placeholder.png"),
                      ),
                SizedBox(
                  width: 0.02.sw,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${userModel.firstName!} ${userModel.lastName!}",
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      if (showFollowers == true)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userModel.followingCount.toString(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 10.sp),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'followers'.tr.toLowerCase(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 10.sp),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            )),
            if (userModel.id != FirebaseAuth.instance.currentUser!.uid &&
                showFollowButton == true)
              CustomButton(
                height: 30,
                width: 120,
                function: () async {
                  await _userController.followUser(userModel);
                },
                text: userModel.followers.indexWhere((element) =>
                            element.id ==
                            FirebaseAuth.instance.currentUser!.uid) ==
                        -1
                    ? 'follow'.tr
                    : 'unfollow'.tr,
                backgroundColor: theme.colorScheme.onSurface,
                textColor: theme.colorScheme.surface,
                fontSize: 12,
                borderRadius: 10,
              ),
            if (showProfile == true)
              CustomButton(
                height: 25,
                width: 100,
                function: () async {
                  Get.to(() => ViewProfile(user: userModel.id!));
                },
                text: 'view_profile'.tr,
                backgroundColor: theme.colorScheme.onSurface,
                textColor: theme.colorScheme.surface,
                fontSize: 12,
                borderRadius: 20,
              ),
            if (showMessage == true)
              CustomButton(
                height: 25,
                width: 100,
                function: () async {
                  Get.to(() => ChatRoomPage(userModel));
                },
                text: 'message'.tr,
                backgroundColor: theme.colorScheme.onSurface,
                textColor: theme.colorScheme.onPrimary,
                fontSize: 12,
                borderRadius: 20,
              ),
          ],
        ),
      ),
    );
  }
}
