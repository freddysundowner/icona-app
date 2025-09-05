import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:tokshop/controllers/user_controller.dart';
import 'package:tokshop/widgets/live/no_items.dart';

import '../../controllers/chat_controller.dart';
import '../../controllers/room_controller.dart';
import '../../models/user.dart';
import '../../utils/utils.dart';
import '../../widgets/search_layout.dart';
import 'chat_room_page.dart';

class NewMessageSearch extends StatelessWidget {
  final TokShowController _tokshowcontroller = Get.find<TokShowController>();
  final UserController userController = Get.find<UserController>();
  final ChatController _chatController = Get.find<ChatController>();

  NewMessageSearch({super.key}) {
    userController.getFriends();
  }

  @override
  Widget build(BuildContext context) {
    _tokshowcontroller.onChatPage.value = false;
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          child: Icon(Icons.arrow_back_ios),
          onTap: () {
            Get.back();
          },
        ),
        title: Text(
          'choose_friend'.tr,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 5.0, right: 10, left: 10),
          child: Obx(() {
            return Column(
              children: [
                SearchLayout(
                  function: (value) {
                    userController.getFriends(v: value);
                  },
                ),
                SizedBox(
                  height: 0.01.sh,
                ),
                SizedBox(
                    height: 0.78.sh,
                    child: userController.loadingFriends.isFalse
                        ? GetBuilder<UserController>(builder: (dx) {
                            return userController.friends.isNotEmpty
                                ? ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: userController.friends.length,
                                    itemBuilder: (context, index) {
                                      UserModel user =
                                          userController.friends[index];
                                      return Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            child: InkWell(
                                              onTap: () {
                                                _chatController
                                                    .currentChat.value = [];
                                                _chatController
                                                    .currentChatId.value = "";
                                                _chatController
                                                    .getPreviousChat(user);
                                                _tokshowcontroller
                                                    .onChatPage.value = true;
                                                Get.to(ChatRoomPage(user));
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Center(
                                                        child: user.profilePhoto ==
                                                                    "" ||
                                                                user.profilePhoto ==
                                                                    null
                                                            ? const CircleAvatar(
                                                                radius: 25,
                                                                backgroundColor:
                                                                    Colors
                                                                        .transparent,
                                                                backgroundImage:
                                                                    AssetImage(
                                                                        "assets/icons/profile_placeholder.png"))
                                                            : CircleAvatar(
                                                                radius: 25,
                                                                onBackgroundImageError: (o,
                                                                        s) =>
                                                                    Image.asset(
                                                                        "assets/icons/profile_placeholder.png"),
                                                                backgroundColor: Styles
                                                                    .greenTheme
                                                                    .withOpacity(
                                                                        0.50),
                                                                backgroundImage:
                                                                    NetworkImage(
                                                                        user.profilePhoto!),
                                                              ),
                                                      ),
                                                      SizedBox(
                                                        width: 0.04.sw,
                                                      ),
                                                      Text(
                                                        "${user.firstName} ${user.lastName}",
                                                        style: TextStyle(
                                                            fontSize: 16.sp),
                                                      ),
                                                    ],
                                                  ),
                                                  const Icon(
                                                    Ionicons.add,
                                                    color: primarycolor,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          Divider(
                                            color: theme.dividerColor,
                                          )
                                        ],
                                      );
                                    })
                                : NoItems();
                          })
                        : const Center(
                            child: CircularProgressIndicator(
                                color: Colors.white))),
                if (userController.moreUsersLoading.isTrue)
                  Column(
                    children: [
                      const Center(
                          child: CircularProgressIndicator(
                        color: primarycolor,
                      )),
                      SizedBox(
                        height: 0.01.sh,
                      ),
                    ],
                  ),
                const SizedBox(
                  height: 100,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
