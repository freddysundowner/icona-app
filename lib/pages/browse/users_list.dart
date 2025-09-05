import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/user_controller.dart';
import '../../models/user.dart';
import '../../widgets/live/no_items.dart';
import '../../widgets/shimmers/user_list.dart';
import '../profile/widgets/user_card.dart';

class UsersList extends StatelessWidget {
  UsersList({super.key}) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // _userController.getAllUsers();
    });
  }
  final UserController _userController = Get.find<UserController>();
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Obx(() {
      // 1) If loading the very first page:
      if (_userController.allUsersLoading.value &&
          _userController.searchedUsers.isEmpty) {
        // Show shimmer placeholders
        return ListView.builder(
          itemCount: 10,
          itemBuilder: (context, index) => ShimmerUserCard(theme),
        );
      }

      // 2) If no users at all, show NoItems
      if (_userController.searchedUsers.isEmpty) {
        return NoItems();
      }

      // 3) Otherwise, build the real list
      // Notice we do "searchedUsers.length + 1" if hasMoreUsers == true
      final itemCount = _userController.searchedUsers.length +
          (_userController.hasMoreUsers.value ? 1 : 0);

      return ListView.builder(
        // Attach the SAME scroll controller from the controller
        controller: _userController.usersScrollController,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          // If within the users list range
          if (index < _userController.searchedUsers.length) {
            UserModel user = _userController.searchedUsers[index];
            return UserCard(userModel: user);
          } else {
            // The extra "loader" item at the bottom
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      );
    });
  }
}
