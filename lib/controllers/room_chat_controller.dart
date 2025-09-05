import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tokshop/main.dart';

class RoomChatController extends GetxController {
  var messages = <Map<String, dynamic>>[].obs;
  RxString chatRoomId = ''.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController messageController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
  }

  void listenToMessages(String chatId) {
    _firestore
        .collection('chats')
        .doc(chatId)
        .collection('room_messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((querySnapshot) {
      for (var change in querySnapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          final messageId = change.doc.id;
          final exists = messages.any((msg) => msg['id'] == messageId);
          if (!exists && data != null) {
            messages
                .insert(0, {'id': messageId, ...data}); // Add message with ID
          }
        }
      }
    });
  }

  void sendMessage({Map<String, dynamic>? data, String? roomId}) {
    if (data == null && messageController.text.trim().isEmpty) return;
    final message = data ??
        {
          'senderId': authController.usermodel.value!.id,
          'image_url': authController.usermodel.value!.profilePhoto,
          'name':
              '${authController.usermodel.value!.firstName}', // Change this to the actual user name
          'message': messageController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
        };

    _firestore
        .collection('chats')
        .doc(roomId ?? chatRoomId.value)
        .collection('room_messages')
        .add(message);

    messageController.clear();
  }
}
