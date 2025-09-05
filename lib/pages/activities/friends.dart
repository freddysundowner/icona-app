import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/user_controller.dart';
import 'package:tokshop/pages/profile/view_profile.dart';
import 'package:tokshop/pages/profile/widgets/user_card.dart';

import '../../models/user.dart';
import '../../widgets/live/no_items.dart';

class Friends extends StatelessWidget {
  String? from;
  Friends({super.key, this.from}) {
    userController.getFriends();
  }
  UserController userController = Get.find<UserController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: InkWell(
            child: Icon(Icons.clear),
            onTap: () => Get.back(),
          ),
          title: Text("friends".tr),
        ),
        body: Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: Obx(
            () => userController.friends.isEmpty
                ? NoItems()
                : ListView.builder(
                    itemCount: userController.friends.length,
                    itemBuilder: (context, index) {
                      UserModel friend = userController.friends[index];
                      return InkWell(
                        onTap: () {
                          if (from == 'create_room') {
                            Get.back();
                            return;
                          }
                          Get.to(() => ViewProfile(user: friend.id!));
                        },
                        child: UserCard(
                          userModel: friend,
                          showFollowers: false,
                          showFollowButton: false,
                          showMessage: true,
                        ),
                      );
                    }),
          ),
        ));
  }
}
