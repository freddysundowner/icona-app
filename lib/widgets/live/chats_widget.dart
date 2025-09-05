import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/room_chat_controller.dart';
import '../show_image.dart';

class ChatsWidget extends StatelessWidget {
  final bool isKeyboardVisible;
  String? currentUserId;
  String? chatRoomId;
  ChatsWidget(
      {super.key,
      required this.isKeyboardVisible,
      this.chatRoomId,
      this.currentUserId}) {
    chatController.chatRoomId.value = chatRoomId!;
    chatController.listenToMessages(chatRoomId!);
  }

  final RoomChatController chatController = Get.put(RoomChatController());
  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: isKeyboardVisible
          ? MediaQuery.of(context).size.width * 0.9
          : MediaQuery.of(context).size.width * 0.8,
      margin: EdgeInsets.only(right: 15),
      height: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Real-time Chat Messages
          Expanded(
            child: Obx(() {
              final messagesList = chatController.messages;

              return ListView.builder(
                controller: _scrollController,
                reverse: true,
                itemCount: messagesList.length,
                itemBuilder: (context, index) {
                  final chat = messagesList[index];
                  return Row(
                    children: [
                      ShowImage(
                        image: chat["image_url"] ?? "Anonymous",
                        height: 28.0,
                        width: 28.0,
                        text: chat["name"] ?? "Anonymous",
                        isAsset: false,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              chat["name"] ?? "Anonymous",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                            ),
                            Text(
                              chat["message"] ?? "",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            }),
          ),

          // Message Input
          Container(
            margin: EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: chatController.messageController,
                    decoration: InputDecoration(
                      hintText: "writeHere".tr,
                      hintStyle: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                              fontFamily: 'SchibstedGrotesk',
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color),
                      filled: false,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 0,
                      ),
                    ),
                  ),
                ),
                if (isKeyboardVisible)
                  IconButton(
                    onPressed: () {
                      chatController.sendMessage();
                    },
                    icon: SvgPicture.asset(
                      "assets/icons/send.svg",
                      width: 28,
                      height: 28,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
