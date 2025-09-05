import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tokshop/controllers/auth_controller.dart';
import 'package:tokshop/models/user.dart';
import 'package:tokshop/services/dynamic_link_services.dart';
import 'package:tokshop/services/user_api.dart';

userActionSheet(BuildContext context,
    {required UserModel user, String? userType}) {
  final theme = Theme.of(context);
  showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(user.firstName!),
        actions: [
          CupertinoActionSheetAction(
            child: Text("share_profile".tr,
                style: TextStyle(
                    fontSize: 16, color: theme.colorScheme.onSurface)),
            onPressed: () async {
              String url = DynamicLinkService().generateShareLink(user.id!);
              await Share.share(url,
                  subject: "${'share'.tr} ${user.firstName!} ${'profile'.tr}");
            },
          ),
          if (user.id != FirebaseAuth.instance.currentUser!.uid)
            CupertinoActionSheetAction(
              child: Text(
                  Get.find<AuthController>()
                              .currentuser!
                              .blocked
                              .indexWhere((element) => element == user.id) !=
                          -1
                      ? 'unblock'.tr
                      : 'block'.tr,
                  style: TextStyle(
                      color: theme.colorScheme.onSurface, fontSize: 16)),
              onPressed: () async {
                Navigator.pop(context);
                if (Get.find<AuthController>()
                    .currentuser!
                    .blocked
                    .contains(user.id!)) {
                  unBlockProfile(context, reportuser: user);
                } else {
                  var userdata = await UserAPI().blockUser(user.id!,
                      Get.find<AuthController>().usermodel.value!.id!);
                  Get.find<AuthController>().usermodel.value =
                      UserModel.fromJson(userdata);
                  Get.snackbar("", "${user.firstName}${'has_been_blocked'.tr}",
                      backgroundColor: Colors.red, colorText: Colors.white);
                }
              },
            ),
          if (user.id != FirebaseAuth.instance.currentUser!.uid)
            CupertinoActionSheetAction(
              child: Text("${'report'.tr} ${user.firstName}",
                  style: TextStyle(
                      color: theme.colorScheme.onSurface, fontSize: 16)),
              onPressed: () {
                Navigator.pop(context);
                reportProfile(context, user);
              },
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(
            'cancel'.tr,
            style: TextStyle(color: theme.colorScheme.error),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        )),
  );
}

/*
      report profile
   */
reportProfile(BuildContext context, UserModel profile) {
  var reportcontroller = TextEditingController();

  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
      topLeft: Radius.circular(15),
      topRight: Radius.circular(15),
    )),
    builder: (context) {
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return DraggableScrollableSheet(
            initialChildSize: 0.9,
            expand: false,
            builder: (BuildContext context, ScrollController scrollController) {
              return SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Text(
                          "${'why_do_you_want_to_report'.tr} ${profile.userName}?",
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        height: 200,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: TextFormField(
                          controller: reportcontroller,
                          maxLength: null,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                              hintText:
                                  "${'describe_why_you_want_to_report'.tr}${profile.userName}",
                              hintStyle: const TextStyle(
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              fillColor: Colors.white),
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black54,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              );
            });
      });
    },
  );
}

Future<void> unBlockProfile(BuildContext context,
    {UserModel? myprofile, UserModel? reportuser}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        scrollable: false,
        title: Text("${'unblock'.tr} ${reportuser!.firstName}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("this_will_no_longer_be_prevented".tr),
            const SizedBox(
              height: 20,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'cancel'.tr,
                      style: TextStyle(color: Colors.red),
                    )),
                const SizedBox(
                  height: 20,
                ),
                InkWell(
                    onTap: () async {
                      Navigator.pop(context);
                      var userdata = await UserAPI().unblockUser(reportuser.id!,
                          Get.find<AuthController>().currentuser!.id!);
                      Get.find<AuthController>().usermodel.value =
                          UserModel.fromJson(userdata);
                      Get.snackbar("",
                          "${reportuser.firstName} ${'has_been_unblocked'.tr}",
                          backgroundColor: Colors.green,
                          colorText: Colors.white);
                    },
                    child: Text(
                      'unblock'.tr,
                      style: TextStyle(color: Colors.green),
                    ))
              ],
            )
          ],
        ),
      );
    },
  );
}
