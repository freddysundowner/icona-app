import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/user_controller.dart';
import '../../../widgets/custom_button.dart';
import '../../chats/chat_room_page.dart';
import '../../chats/messages.dart';
import '../tip/send_tip.dart';

class ActionWidget extends StatelessWidget {
  ActionWidget({super.key});
  final UserController _userController = Get.find<UserController>();
  bool _owner() {
    return FirebaseAuth.instance.currentUser!.uid ==
        _userController.currentProfile.value.id;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_userController.currentProfile.value.id !=
              FirebaseAuth.instance.currentUser!.uid)
            CustomButton(
              height: 35,
              function: () async {
                _userController.followUfollow();
              },
              text: _userController.currentProfile.value.followers.indexWhere(
                          (element) =>
                              element.id ==
                              FirebaseAuth.instance.currentUser!.uid) !=
                      -1
                  ? 'unfollow'.tr
                  : 'follow'.tr,
              width: MediaQuery.of(Get.context!).size.width,
              backgroundColor: Theme.of(context).colorScheme.primary,
              textColor: Theme.of(context).colorScheme.onPrimary,
            ),
          if (_userController.currentProfile.value.id !=
              FirebaseAuth.instance.currentUser!.uid)
            SizedBox(height: 16),
          Row(
            children: [
              CustomButton(
                function: () {
                  if (_owner()) {
                    Get.to(AllChatsPage());
                  } else {
                    Get.to(ChatRoomPage(_userController.currentProfile.value));
                  }
                },
                text: 'message'.tr,
                backgroundColor: Colors.grey.withValues(alpha: 0.2),
                height: 40,
                iconData: Icons.message,
                iconColor: Colors.white,
              ),
              Spacer(),
              CustomButton(
                function: () {
                  Get.to(() => TipScreen(
                        user: _userController.currentProfile.value,
                      ));
                },
                text: 'tip_me'.tr,
                backgroundColor: Colors.transparent,
                height: 40,
                borderColor: Colors.grey.withValues(alpha: 0.2),
                iconData: Icons.card_giftcard_outlined,
                iconColor: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
