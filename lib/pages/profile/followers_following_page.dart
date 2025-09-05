import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/models/user.dart';
import 'package:tokshop/pages/profile/widgets/user_card.dart';
import 'package:tokshop/widgets/live/no_items.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/user_controller.dart';
import '../../services/user_api.dart';

class FollowersFollowingPage extends StatelessWidget {
  final String type;
  final UserController _userController = Get.find<UserController>();
  final AuthController authController = Get.find<AuthController>();

  FollowersFollowingPage(this.type, {super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.clear,
            color: theme.colorScheme.onSurface,
            size: 25,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          type,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Obx(() {
          return _userController.gettingFollowers.isFalse
              ? _userController.userFollowersFollowing.isNotEmpty
                  ? ListView.builder(
                      itemCount: _userController.userFollowersFollowing.length,
                      itemBuilder: (context, index) {
                        UserModel userModel =
                            _userController.userFollowersFollowing[index];
                        return UserCard(
                          userModel: userModel,
                          showFollowers: false,
                        );
                      })
                  : NoItems()
              : SizedBox(
                  height: 0.5.sh,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ));
        }),
      ),
    );
  }

  Future<void> followUser(int index, UserModel user) async {
    _userController.userFollowersFollowing
        .elementAt(index)["followers"]
        .add(FirebaseAuth.instance.currentUser!.uid);
    _userController.userFollowersFollowing.refresh();

    if (FirebaseAuth.instance.currentUser!.uid ==
        _userController.currentProfile.value.id) {
      _userController.currentProfile.value.followingCount =
          _userController.currentProfile.value.followingCount! + 1;
      _userController.currentProfile.refresh();
    }
    await UserAPI()
        .followAUser(FirebaseAuth.instance.currentUser!.uid, user.id!);
  }

  Future<void> unFollowUser(int index, UserModel user) async {
    _userController.userFollowersFollowing
        .elementAt(index)["followers"]
        .remove(FirebaseAuth.instance.currentUser!.uid);

    if (FirebaseAuth.instance.currentUser!.uid ==
        _userController.currentProfile.value.id) {
      _userController.currentProfile.value.followingCount =
          _userController.currentProfile.value.followingCount! - 1;
      _userController.currentProfile.refresh();
    }
    _userController.userFollowersFollowing.refresh();
    await UserAPI()
        .unFollowAUser(FirebaseAuth.instance.currentUser!.uid, user.id!);
  }
}
