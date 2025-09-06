import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/room_controller.dart';
import '../utils/functions.dart';
import 'client.dart';
import 'end_points.dart';

class RoomAPI {
  getShows(
      {String limit = "15",
      int page = 1,
      String category = "",
      String text = "",
      String userid = "",
      String status = ""}) async {
    var res = await DbBase().databaseRequest(
        "$rooms?page=$page&limit=$limit&category=$category&userid=$userid&currentUserId=${FirebaseAuth.instance.currentUser!.uid}&title=$text&status=$status",
        DbBase().getRequestType);
    return jsonDecode(res);
  }

  getAllMyEvents(String userId) async {
    var rooms = await DbBase()
        .databaseRequest("$myEvents/$userId", DbBase().getRequestType);

    return jsonDecode(rooms);
  }

  getAllEvents() async {
    var rooms = await DbBase().databaseRequest(
        "$allEvents/${FirebaseAuth.instance.currentUser!.uid}",
        DbBase().getRequestType);

    return jsonDecode(rooms);
  }

  getRoomById(String roomId) async {
    var room =
        await DbBase().databaseRequest(rooms + roomId, DbBase().getRequestType);
    return jsonDecode(room);
  }

  getEndedRoomById(String roomId) async {
    var room = await DbBase()
        .databaseRequest(endedRoomById + roomId, DbBase().getRequestType);
    return jsonDecode(room);
  }

  getEventById(String roomId) async {
    var room = await DbBase()
        .databaseRequest(eventById + roomId, DbBase().getRequestType);
    return jsonDecode(room);
  }

  createShow(Map<String, dynamic> roomData) async {
    try {
      var room = await DbBase()
          .databaseRequest(rooms, DbBase().postRequestType, body: roomData);
      return jsonDecode(room);
    } catch (e, s) {
      printOut("Error creating room $e $s");
    }
  }

  createEvent(Map<String, dynamic> roomData) async {
    try {
      var room = await DbBase().databaseRequest(
          createEventE + Get.find<AuthController>().usermodel.value!.id!,
          DbBase().postRequestType,
          body: roomData);
      return jsonDecode(room);
    } catch (e, s) {
      printOut("Error creating room $e $s");
    }
  }

  generateAgoraToken(String channel, int uid) async {
    try {
      var data = {"channel": channel, "uid": uid};

      var token = await DbBase()
          .databaseRequest(tokenPath, DbBase().postRequestType, body: data);

      if (token != null) {
        return jsonDecode(token)["token"];
      } else {
        printOut('Failed to load token $token');
        throw Exception('Failed to load token');
      }
    } catch (e, s) {
      printOut("Error generating agora token room $e $s");
    }
  }

  generateRtmToken(String uid) async {
    try {
      var token = await DbBase()
          .databaseRequest("$rtmtoken/$uid", DbBase().getRequestType);

      if (token != null) {
        return jsonDecode(token)["token"];
      } else {
        printOut('Failed to load token $token');
        throw Exception('Failed to load token');
      }
    } catch (e, s) {
      printOut("Error generating agora token room $e $s");
    }
  }

  updateRoomId(Map<String, dynamic> body, String id) async {
    try {
      var updated = await DbBase()
          .databaseRequest(rooms + id, DbBase().putRequestType, body: body);
      return jsonDecode(updated);
    } catch (e) {
      printOut("Error updateRoomByIdNew room $e");
    }
  }

  Future<void> updateRoomById(Map<String, dynamic> body, String id) async {
    final TokShowController tokshowcontroller = Get.find<TokShowController>();
    try {
      if (body["title"] == null) {
        body.addAll({"title": tokshowcontroller.currentRoom.value!.title});
      }
      if (body["activeTime"] == null) {
        body.addAll({
          "activeTime": DateTime.now().millisecondsSinceEpoch,
        });
      }

      await DbBase()
          .databaseRequest(rooms + id, DbBase().putRequestType, body: body);
    } catch (e) {
      printOut("Error updating room $e");
    }
  }

  Future<void> removeProoductFromRoom(
      Map<String, dynamic> body, String id) async {
    try {
      await DbBase().databaseRequest(
          removeRoomProduct + id, DbBase().putRequestType,
          body: body);
    } catch (e) {
      printOut("Error updating room $e");
    }
  }

  addUserrToRoom(Map<String, dynamic> body, String id) async {
    try {
      await DbBase().databaseRequest(
          addUserToRoom + id, DbBase().putRequestType,
          body: body);
    } catch (e) {
      printOut("Error addUserrToRoom room $e");
    }
  }

  removeUserFromPreviousRoom(Map<String, dynamic> body) async {
    try {
      await DbBase().databaseRequest(
          removeFromCurrentRoom +
              Get.find<AuthController>().usermodel.value!.id!,
          DbBase().putRequestType,
          body: body);
    } catch (e) {
      printOut("Error removeFromCurrentRoom room $e");
    }
  }

  removeUserFromRoom(Map<String, dynamic> body, String id) async {
    try {
      await DbBase().databaseRequest(
          removeUserFromRoomUrl + id, DbBase().putRequestType,
          body: body);
    } catch (e) {
      printOut("Error removeUserFromAudience  room $e");
    }
  }

  removeUserFromInvitedSpeakerInRoom(
      Map<String, dynamic> body, String id) async {
    try {
      await DbBase().databaseRequest(
          removeInvitedSpeaker + id, DbBase().putRequestType,
          body: body);
    } catch (e) {
      printOut("Error removeInvitedSpeaker  room $e");
    }
  }

  removeUserFromHostInRoom(Map<String, dynamic> body, String id) async {
    try {
      await DbBase().databaseRequest(removeHost + id, DbBase().putRequestType,
          body: body);
    } catch (e) {
      printOut("Error removeUserFromHost room $e");
    }
  }

  removeUserFromRaisedHandsInRoom(Map<String, dynamic> body, String id) async {
    try {
      await DbBase().databaseRequest(
          removeUserFromRaisedHands + id, DbBase().putRequestType,
          body: body);
    } catch (e) {
      printOut("Error removeUserFromAudience  room $e");
    }
  }

  deleteARoom(String id, {bool destroy = false}) async {
    try {
      await DbBase().databaseRequest(
          "$rooms/$id?destroy=$destroy", DbBase().deleteRequestType);
    } catch (e) {
      printOut("Error deleteARoom  room $e");
    }
  }

  sendRoomNotication(Map<String, dynamic> body) async {
    var updated = await DbBase()
        .databaseRequest(roomNotication, DbBase().postRequestType, body: body);
    return jsonDecode(updated);
  }

  static deleteAuction(String? id) async {
    var updated = await DbBase()
        .databaseRequest('$auction/$id', DbBase().deleteRequestType);
    return jsonDecode(updated);
  }

  static getToken(Map<String, String?> map) async {
    var updated = await DbBase()
        .databaseRequest(livekitToken, DbBase().postRequestType, body: map);
    return jsonDecode(updated);
  }
}
