import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:tokshop/controllers/auction_controller.dart';
import 'package:tokshop/controllers/room_chat_controller.dart';
import 'package:tokshop/controllers/room_controller.dart';
import 'package:tokshop/models/giveaway.dart';
import 'package:tokshop/models/product.dart';
import 'package:tokshop/models/tokshow.dart';
import 'package:tokshop/models/user.dart';
import 'package:tokshop/services/room_api.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../main.dart';
import '../models/auction.dart';
import '../widgets/loadig_page.dart';

class SocketController extends GetxController {
  IO.Socket? socket;
  var isConnected = false.obs;
  var messages = <String>[].obs;

  String roomId = '';
  String userId = '';
  String userName = '';

  RoomChatController chatController = Get.put(RoomChatController());

  /// Initialize the socket connection
  void initSocket({
    required String serverUrl,
    required String defaultRoomId,
    required String defaultUserId,
    required String defaultUserName,
  }) {
    roomId = defaultRoomId;
    userId = defaultUserId;
    userName = defaultUserName;
    if (socket != null && socket!.connected) {
      return; // ✅ Prevent multiple connections
    }

    TokShowController tokShowController = Get.find<TokShowController>();
    AuctionController auctionController = Get.find<AuctionController>();
    socket = IO.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    if (socket == null || !socket!.connected) {
      socket?.connect();
    }
    socket?.on('connect_error', (data) {
      print('Connect Error: $data');
    });
    socket?.on('connect_timeout', (data) {
      print('Connect Timeout: $data');
    });
    socket?.on('connect', (_) {
      isConnected.value = true;
      print('Socket connected: ${socket?.id}');
    });

    // 4) Listen for disconnection
    socket?.on('disconnect', (_) {
      isConnected.value = false;
    });

    socket?.on('user-connected', (data) {
      int? i = tokShowController.currentRoom.value?.viewers!
          .indexWhere((element) => element.id == data['userId']);
      if (i == -1) {
        tokShowController.currentRoom.value?.viewers!
            .add(UserModel(id: data['userId']));
      }
      tokShowController.currentRoom.refresh();
    });

    socket?.on('createMessage', (data) {
      if (data is Map) {
        final msg = data['message'];
        final senderName = data['senderName'];
        messages.add('$senderName: $msg');
      } else if (data is List && data.length >= 2) {
        // Or if the server used two arguments
        final msg = data[0];
        final senderName = data[1];
        messages.add('$senderName: $msg');
      }
    });

    socket?.on('joined-giveaway', (data) {
      tokShowController.currentRoom.value?.giveAway = GiveAway.fromJson(data);
      tokShowController.currentRoom.refresh();
    });
    socket?.on("followed-user", (data) async {
      var response = await RoomAPI().getRoomById(roomId);
      tokShowController.currentRoom.value = Tokshow.fromJson(response);
      tokShowController.currentRoom.refresh();
    });
    socket?.on('product-pinned', (data) {
      tokShowController.currentRoom.value = Tokshow.fromJson(data);
      tokShowController.currentRoom.refresh();
    });
    socket?.on("ended-giveaway", (data) {
      giveAwayController.expanded.value = true;
      giveAwayController.findingwinner.value = false;
      tokShowController.currentRoom.value?.giveAway = GiveAway.fromJson(data);
      tokShowController.currentRoom.refresh();
      Future.delayed(const Duration(seconds: 10), () {
        giveAwayController.expanded.value = false; // or set a flag to hide it
      });
      // }
      giveAwayController.getGiveAways(
        room: tokShowController.currentRoom.value!.id!,
      );
    });
    socket?.on("started-giveaway", (data) {
      print("started giveaway: $data");
      tokShowController.currentRoom.value?.giveAway = GiveAway.fromJson(data);
      tokShowController.currentRoom.refresh();
      giveAwayController.startTimer(
        1,
        tokShowController.currentRoom.value?.giveAway?.startedtime ?? "",
      );
    });
    socket?.on('auction-pinned', (data) {
      tokShowController.currentRoom.value?.activeauction =
          Auction.fromJson(data);
      tokShowController.currentRoom.refresh();
    });
    socket?.on('room-started', (data) async {
      WakelockPlus.enable();
      tokShowController.currentRoom.value = Tokshow.fromJson(data);
      await tokShowController.initAgora();
      tokShowController
          .checkDateGreaterthaNow(tokShowController.currentRoom.value);
      tokShowController.currentRoom.refresh();
    });
    socket?.on('left-room', (data) {
      WakelockPlus.disable();
      if (tokShowController.currentRoom.value != null) {
        int i = tokShowController.currentRoom.value!.viewers!
            .indexWhere((u) => u.id == data['userId']);
        if (i != -1) {
          tokShowController.currentRoom.value?.viewers?.removeAt(i);
        }
      }
      tokShowController.currentRoom.refresh();
    });
    socket?.on('auction-ended', (data) {
      List bidsres = data['bids'];
      List<Bid> bids = bidsres.map((e) => Bid.fromJson(e)).toList();
      Bid? bid = auctionController.findWinner(bids);
      if (bid != null) {
        auctionController.showbubble.value = true;
        tokShowController.wornUi(Get.context!, bid.bidder);
      }
      tokShowController.currentRoom.value?.activeauction =
          Auction.fromJson(data);
      tokShowController.currentRoom.value?.activeauction?.ended = true;
      tokShowController.currentRoom.refresh();
    });
    socket?.on('current-user-joined', (data) {
      WakelockPlus.enable();
    });
    socket?.on('room-ended', (data) {
      WakelockPlus.disable();
      tokShowController.leaveAgoraEngine();
      tokShowController.currentRoom.value?.activeauction = null;
      tokShowController.currentRoom.value?.ended = true;
      tokShowController.currentRoom.refresh();
    });
    socket?.on('auction-started', (data) {
      final auction = Auction.fromJson(data);
      auction.ended = false;
      if (auction.endTime == null && auction.duration > 0) {
        auction.endTime =
            DateTime.now().add(Duration(seconds: auction.duration));
      }
      tokShowController.currentRoom.value?.activeauction = auction;
      tokShowController.currentRoom.refresh();
      auctionController.findWinner(auction.bids);
      auctionController.formatedTimeString.value = "00:00";

      auctionController.startTimerWithEndTime();
    });

    socket?.on('auction-time-extended', (data) {
      tokShowController.currentRoom.value?.activeauction?.endTime =
          data['newEndTime'] != null
              ? DateTime.parse(data['newEndTime'])
              : null;
      tokShowController.currentRoom.refresh();
    });

    socket?.on('bid-updated', (data) {
      if (data is Map) {
        tokShowController.currentRoom.value?.activeauction =
            Auction.fromJson(data);
        auctionController.findWinner(
            tokShowController.currentRoom.value?.activeauction?.bids);
      }
    });
  }

  void leaveRoom() {
    if (!isConnected.value) return;
    socket?.emit('leave-room', {
      "roomId": roomId,
      "userId": userId,
      "userName": userName,
    });
  }

  void endRoom() {
    if (!isConnected.value) return;
    socket?.emit('end-room', {
      "roomId": roomId,
      "userId": userId,
    });
  }

  void muteUser() {
    if (!isConnected.value) return;
    socket?.emit('mute-user', {
      "roomId": roomId,
      "userId": userId,
      "mute": Get.find<TokShowController>().audioMuted.value
    });
  }

  void joinRoom() {
    var message = {
      'senderId': userId,
      'image_url': authController.usermodel.value!.profilePhoto,
      'name':
          '${authController.usermodel.value!.firstName}', // Change this to the actual user name
      'message': "$userName ${'joined'.tr} 👋",
      'timestamp': FieldValue.serverTimestamp(),
    };
    chatController.sendMessage(data: message, roomId: roomId);
    socket?.emit('join-room', {
      "roomId": roomId,
      "userId": userId,
      "userName": userName,
    });
  }

  void followUser() {
    if (!isConnected.value) return;
    socket?.emit('follow-user', {
      "showId": roomId,
      "userId": userId,
      "toFollowUserId":
          Get.find<TokShowController>().currentRoom.value?.owner?.id
    });
  }

  void startAuction(Auction? auction) {
    if (!isConnected.value) return;
    socket?.emit('start-auction', {
      "roomId": roomId,
      'auction': auction?.toMap(),
    });
  }

  void pinGiveaway(GiveAway giveAway, BuildContext? context) {
    if (!isConnected.value) return;
    if (context != null) LoadingOverlay.showLoading(context);
    socket?.emit('start-giveaway',
        {"giveawayId": giveAway.id, "showId": giveAway.room?.id});
    if (context != null) LoadingOverlay.hideLoading(context);
  }

  void endGiveaway(GiveAway giveAway) {
    if (!isConnected.value) return;
    socket?.emit('draw-giveaway',
        {"giveawayId": giveAway.id, 'showId': giveAway.room?.id});
  }

  void pinAuction(Auction? auction, BuildContext? context,
      {Product? product, Tokshow? tokshow}) {
    if (context != null) LoadingOverlay.showLoading(context);
    if (!isConnected.value) return;
    if (product != null) {
      socket?.emit('pin-product', {
        "pinned": tokshow!.pinned == null || tokshow!.pinned!.id != product.id,
        "product": product.id,
        "tokshow": tokshow.id
      });
      if (context != null) LoadingOverlay.hideLoading(context);
      return;
    }
    socket?.emit('pin-auction',
        {"pinned": true, "auction": auction?.id, "tokshow": auction?.tokshow});
    if (context != null) LoadingOverlay.hideLoading(context);
  }

  /// Send a chat message
  void sendMessage(String message) {
    if (!isConnected.value) return;
    if (message.trim().isEmpty) return;

    // Based on your server code, you might need an object or multiple args
    socket?.emit('createMessage', {
      'message': message,
      'senderName': userName,
    });

    messages.add('Me: $message');
  }

  /// Place a bid
  void placeBid(payload) {
    if (!isConnected.value) return;
    // This must match the server’s "place-bid" event signature
    socket?.emit('place-bid', payload);
  }

  /// Disconnect the socket
  void disconnectSocket() {
    if (socket!.connected) {
      socket?.emit('leave-room', {
        "roomId": roomId,
        "userId": userId,
        "userName": userName,
      });
      socket!.clearListeners();
      socket?.disconnect();
    }
    isConnected.value = false;
  }

  @override
  void onClose() {
    // Cleanup
    disconnectSocket();
    super.onClose();
  }

  void startShow() {
    tokShowController.isReadyPreview.value = true;
    socket?.emit('start-room', {
      "roomId": roomId,
      "userId": userId,
      "userName": userName,
    });
  }

  void joinGiveaway(GiveAway giveAway) async {
    if (!isConnected.value) return;
    socket?.emit('join-giveaway', {
      "giveawayId": giveAway.id,
      'showId': giveAway.room?.id,
      "userId": userId
    });
  }
}
