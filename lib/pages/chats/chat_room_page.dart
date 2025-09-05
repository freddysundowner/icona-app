import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/auth_controller.dart';
import 'package:tokshop/models/inbox.dart';
import 'package:tokshop/pages/profile/view_profile.dart';
import 'package:tokshop/pages/profile/widgets/user_actions.dart';

import '../../controllers/chat_controller.dart';
import '../../controllers/room_controller.dart';
import '../../controllers/user_controller.dart';
import '../../models/chat.dart';
import '../../models/user.dart';
import '../../utils/utils.dart';

//ignore: must_be_immutable
class ChatRoomPage extends StatelessWidget {
  UserModel user;
  Inbox? inbox;
  final ChatController _chatController = Get.find<ChatController>();
  final UserController _userController = Get.find<UserController>();
  TextEditingController messageController = TextEditingController();
  final TokShowController _tokshowcontroller = Get.find<TokShowController>();
  final ScrollController _sc = ScrollController();

  ChatRoomPage(this.user, {super.key, this.inbox}) {
    _chatController.currentChat.value = [];
    _chatController.currentChatId.value = "";
    _chatController.getPreviousChat(_userController.currentProfile.value);
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    _chatController.readChats();
    return WillPopScope(
      onWillPop: () async {
        Get.find<ChatController>().updateOnlineStatus(false);
        Get.find<ChatController>().updateTypingStatus(false);
        _tokshowcontroller.onChatPage.value = false;
        FocusManager.instance.primaryFocus?.unfocus();
        _chatController.currentChat.value = [];
        _chatController.currentChatId.value = "";
        _chatController.currentChatUsers.value = [];
        Get.back();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Get.find<ChatController>().updateOnlineStatus(false);
              Get.find<ChatController>().updateTypingStatus(false);
              _tokshowcontroller.onChatPage.value = false;
              FocusManager.instance.primaryFocus?.unfocus();
              _chatController.currentChat.value = [];
              _chatController.currentChatId.value = "";
              _chatController.currentChatUsers.value = [];
              Get.back();
            },
            icon: const Icon(Icons.arrow_back),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  Get.to(() => ViewProfile(user: user.id!));
                },
                child: Row(
                  children: [
                    user.profilePhoto == "" || user.profilePhoto == null
                        ? const CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.transparent,
                            backgroundImage: AssetImage(
                                "assets/icons/profile_placeholder.png"))
                        : CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.transparent,
                            backgroundImage: NetworkImage(user.profilePhoto!),
                          ),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${user.firstName} ${user.lastName}"),
                        const SizedBox(
                          height: 5,
                        ),
                        Obx(
                          () => Text(
                            _chatController.typing.isTrue
                                ? 'typing'.tr
                                : _chatController.online.isTrue
                                    ? 'online'.tr
                                    : _chatController.lastseen.value.isNotEmpty
                                        ? "${'last_seen'.tr} ${_chatController.lastseen.value}"
                                        : "",
                            style:
                                TextStyle(fontSize: 10.sp, color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  userActionSheet(context, user: user);
                },
                child: const Icon(
                  Icons.more_vert,
                  color: Colors.white,
                ),
              )
            ],
          ),
          centerTitle: false,
        ),
        body: Obx(
          () => Column(
            children: [
              Expanded(
                flex: 1,
                child: Obx(() {
                  return _chatController.currentChatLoading.isFalse
                      ? RefreshIndicator(
                          onRefresh: () => _chatController
                              .getChatById(_chatController.currentChatId.value),
                          child: _chatController.currentChat.isNotEmpty
                              ? SingleChildScrollView(
                                  reverse: true,
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      controller: _sc,
                                      padding: const EdgeInsets.all(8.0),
                                      itemCount:
                                          _chatController.currentChat.length,
                                      itemBuilder: (context, index) {
                                        printOut(
                                            _chatController.currentChat.length);
                                        Chat chat = _chatController.currentChat
                                            .elementAt(index);
                                        return Align(
                                          alignment: chat.sender !=
                                                  FirebaseAuth
                                                      .instance.currentUser!.uid
                                              ? Alignment.centerLeft
                                              : Alignment.centerRight,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Container(
                                                  width: 0.5.sw,
                                                  decoration: BoxDecoration(
                                                      color: chat.sender ==
                                                              FirebaseAuth
                                                                  .instance
                                                                  .currentUser!
                                                                  .uid
                                                          ? theme.colorScheme
                                                              .onSecondaryContainer
                                                          : theme.colorScheme
                                                              .primary,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Text(
                                                      chat.message,
                                                      style: TextStyle(
                                                          color: chat.sender ==
                                                                  FirebaseAuth
                                                                      .instance
                                                                      .currentUser!
                                                                      .uid
                                                              ? Colors.white
                                                              : Colors.black,
                                                          fontSize: 12.sp),
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  convertTime(chat.date),
                                                  style: const TextStyle(
                                                      color:
                                                          Styles.dullGreyColor),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                )
                              : Center(
                                  child: Text(
                                    'nothing_here'.tr,
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 16.sp),
                                  ),
                                ),
                        )
                      : const Center(
                          child: CircularProgressIndicator(
                          color: Colors.white,
                        ));
                }),
              ),
              if (Get.find<AuthController>()
                  .usermodel
                  .value!
                  .blocked
                  .contains(user.id))
                InkWell(
                  onTap: () {
                    unBlockProfile(context, reportuser: user);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10.0, right: 10, bottom: 10, top: 5),
                    child: Container(
                      width: 0.8.sw,
                      decoration: BoxDecoration(
                          color: Styles.greenTheme.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20)),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 10.0, right: 10, top: 10, bottom: 10),
                          child: Center(
                            child: Text(
                              "${'you_blocked'.tr} ${user.firstName}, ${'unblock'.tr}?",
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (user.blocked
                  .contains(Get.find<AuthController>().usermodel.value!.id))
                InkWell(
                  onTap: () {
                    unBlockProfile(context, reportuser: user);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10.0, right: 10, bottom: 10, top: 5),
                    child: Container(
                      width: 0.8.sw,
                      decoration: BoxDecoration(
                          color: Styles.greenTheme.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20)),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 10.0, right: 10, top: 10, bottom: 10),
                          child: Center(
                            child: Text(
                              "${'blocked_by'.tr} ${user.firstName}",
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (!Get.find<AuthController>()
                  .usermodel
                  .value!
                  .blocked
                  .contains(user.id))
                Padding(
                  padding: const EdgeInsets.only(
                      left: 10.0, right: 10, bottom: 10, top: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 0.8.sw,
                        margin: EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.grey.withOpacity(0.3)),
                            color: Colors.grey.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20)),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 10.0, right: 10),
                            child: Center(
                              child: Focus(
                                onFocusChange: (hasFocus) {
                                  if (hasFocus) {
                                    _chatController.updateTypingStatus(true);
                                  }
                                },
                                child: TextField(
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  controller: messageController,
                                  maxLines: 10,
                                  minLines: 1,
                                  autofocus: false,
                                  decoration: InputDecoration(
                                    hintText: 'send_message'.tr,
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16.sp,
                                    ),
                                    border: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  style: TextStyle(fontSize: 16.sp),
                                  onChanged: (text) {
                                    Get.find<ChatController>()
                                        .updateTypingStatus(true);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          if (messageController.text.trim().isNotEmpty) {
                            _chatController.sendMessage(
                                messageController.text.trim(), user);
                            messageController.clear();
                          }
                        },
                        child: Obx(() {
                          return Container(
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Styles.greenTheme),
                            child: _chatController.sendingMessage.isFalse
                                ? Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Center(
                                      child: Image.asset(
                                        "assets/icons/send_message.png",
                                        scale: 0.9,
                                        color: Colors.black,
                                      ),
                                    ),
                                  )
                                : Transform.scale(
                                    scale: 0.3,
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                    )),
                          );
                        }),
                      )
                    ],
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
