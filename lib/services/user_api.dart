import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:tokshop/main.dart';
import 'package:tokshop/models/ShippingAddress.dart';

import '../models/user.dart';
import '../utils/utils.dart';
import 'client.dart';
import 'end_points.dart';

class UserAPI {
  getAllUsers(String page, {String title = ""}) async {
    try {
      var users = await DbBase().databaseRequest(
          '$user?page=$page&limit=$limit&title=$title',
          DbBase().getRequestType);
      var decodedUsers = jsonDecode(users);
      return decodedUsers;
    } catch (e, s) {
      printOut("$e $s");
    }
  }

  addUserReview(String id, String review, int rating,
      {String reviewType = "", String reviewedItem = ""}) async {
    var reviews = await DbBase()
        .databaseRequest(userreviews + id, DbBase().postRequestType, body: {
      "id": FirebaseAuth.instance.currentUser!.uid,
      "rating": rating,
      "review": review,
      "reviewType": reviewType,
      "reviewedItem": reviewedItem
    });
    return jsonDecode(reviews);
  }

  getUserReviews(String uid) async {
    var reviews = await DbBase()
        .databaseRequest(userreviews + uid, DbBase().getRequestType);
    return jsonDecode(reviews);
  }

  Future checkCanReview(UserModel userModel) async {
    var response = await DbBase().databaseRequest(
        checkcanreview + FirebaseAuth.instance.currentUser!.uid,
        DbBase().postRequestType,
        body: {"id": userModel.id});
    if (response == null) {
      return null;
    } else {
      return jsonDecode(response);
    }
  }

  getUserProfile(String uid) async {
    var user =
        await DbBase().databaseRequest(userById + uid, DbBase().getRequestType);

    if (user == null) {
      return null;
    } else {
      return jsonDecode(user);
    }
  }

  getUserFollowers(String uid) async {
    var users = await DbBase()
        .databaseRequest(userFollowers + uid, DbBase().getRequestType);

    if (users == null) {
      return null;
    } else {
      return jsonDecode(users);
    }
  }

  getUserFollowing(String uid) async {
    var users = await DbBase()
        .databaseRequest(userFollowing + uid, DbBase().getRequestType);

    if (users == null) {
      return null;
    } else {
      return jsonDecode(users);
    }
  }

  getUserOrders(String uid) async {
    var orders = await DbBase()
        .databaseRequest(userOrders + uid, DbBase().getRequestType);

    return jsonDecode(orders);
  }

  getUserBalances() async {
    var orders = await DbBase().databaseRequest(
        "$stripeBalance/${FirebaseAuth.instance.currentUser!.uid}",
        DbBase().getRequestType);

    return jsonDecode(orders);
  }

  getOrders(String filterparams) async {
    var orders = await DbBase()
        .databaseRequest("$allorders?$filterparams", DbBase().getRequestType);
    return jsonDecode(orders);
  }

  Future blockUser(String toblock, String id) async {
    try {
      var updated = await DbBase()
          .databaseRequest("$block$id/$toblock", DbBase().putRequestType);

      return jsonDecode(updated);
    } catch (e, s) {
      printOut("Error updating user $e $s");
    }
  }

  Future unblockUser(String toblock, String id) async {
    try {
      var updated = await DbBase()
          .databaseRequest("$unblock$id/$toblock", DbBase().putRequestType);
      return jsonDecode(updated);
    } catch (e, s) {
      printOut("Error updating user $e $s");
    }
  }

  Future updateUser(Map<String, dynamic> body, String id) async {
    try {
      var updated = await DbBase()
          .databaseRequest(editUser + id, DbBase().putRequestType, body: body);

      return jsonDecode(updated)["user"];
    } catch (e, s) {
      printOut("Error updating user $e $s");
    }
  }

  Future updateUserInterests(List<String> body, String id) async {
    try {
      var updated = await DbBase().databaseRequest(
          '${updateinterests}/$id', DbBase().putRequestType,
          body: {"interests": body});

      return jsonDecode(updated);
    } catch (e, s) {
      printOut("Error updating user $e $s");
    }
  }

  Future savePayoutMethod(Map<String, dynamic> body, String id) async {
    try {
      var updated = await DbBase().databaseRequest(
          payoutmethods + id, DbBase().postRequestType,
          body: body);

      return jsonDecode(updated);
    } catch (e, s) {
      printOut("Error updating user $e $s");
    }
  }

  Future getPayoutMethodByUserId(String id) async {
    try {
      var updated = await DbBase()
          .databaseRequest(payoutmethods + id, DbBase().getRequestType);

      return jsonDecode(updated);
    } catch (e, s) {
      printOut("Error updating user $e $s");
    }
  }

  Future createStripeCardToken(Map<String, dynamic> body, String id) async {
    try {
      var updated = await DbBase().databaseRequest(
          paymentmethods + id, DbBase().postRequestType,
          body: body);

      return jsonDecode(updated);
    } catch (e, s) {
      printOut("Error updating user $e $s");
    }
  }

  followAUser(String myId, String toFollowId) async {
    try {
      var updated = await DbBase().databaseRequest(
          "$followUser$myId/$toFollowId", DbBase().putRequestType);
    } catch (e, s) {
      printOut("Error following user $e $s");
    }
  }

  unFollowAUser(String myId, String toUnFollowId) async {
    try {
      await DbBase().databaseRequest(
          "$unFollowUser$myId/$toUnFollowId", DbBase().putRequestType);
    } catch (e, s) {
      printOut("Error following user $e $s");
    }
  }

  static authenticate(data) async {
    var response = await DbBase()
        .databaseRequest(auth, DbBase().postRequestType, body: data);
    return jsonDecode(response);
  }

  static Future getUserById() async {
    try {
      var response = await DbBase().databaseRequest(
          "$user/${FirebaseAuth.instance.currentUser!.uid}",
          DbBase().getRequestType);
      return jsonDecode(response);
    } catch (e) {
      print("get user error $e");
    }
  }

  static getAddressesFromUserId() async {
    var response = await DbBase().databaseRequest(
        addressForUser + FirebaseAuth.instance.currentUser!.uid,
        DbBase().getRequestType);
    return jsonDecode(response);
  }

  static getDefaultAddress() async {
    var response = await DbBase().databaseRequest(
      '$defaultaddress${authController.usermodel.value?.id}',
      DbBase().getRequestType,
    );
    return jsonDecode(response);
  }

  static Future addAddressForCurrentUser(ShippingAddress newAddress) async {
    print(newAddress.toJson());
    var response = await DbBase().databaseRequest(
        address, DbBase().postRequestType,
        body: newAddress.toJson());
    return jsonDecode(response);
  }

  String getPathForCurrentUserDisplayPicture() {
    final String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    return "user/display_picture/$currentUserUid";
  }

  static updateAddressForCurrentUser(
      Map<String, dynamic> newAddress, String id) async {
    var response = await DbBase().databaseRequest(
        address + id, DbBase().putRequestType,
        body: newAddress);
    return response;
  }

  static makeAddressPrimary(Map<String, dynamic> newAddress, String id) async {
    await DbBase().databaseRequest(address + id, DbBase().patchRequestType,
        body: newAddress);
  }

  static uploadDisplayPictureForCurrentUser(String downloadUrl) async {
    await DbBase().databaseRequest(
        "$user/${FirebaseAuth.instance.currentUser!.uid}",
        DbBase().putRequestType,
        body: {"profilePhoto": downloadUrl});

    return true;
  }

  static getMyFavorites() async {
    var response = await DbBase().databaseRequest(
      "$favorite/${FirebaseAuth.instance.currentUser!.uid}",
      DbBase().getRequestType,
    );
    return jsonDecode(response);
  }

  static getUserSummary(String shopid) async {
    var response = await DbBase().databaseRequest(
      usersummary + shopid,
      DbBase().getRequestType,
    );
    return jsonDecode(response);
  }

  static saveFovite(String productId) async {
    var response = await DbBase().databaseRequest(
        "$favorite/${FirebaseAuth.instance.currentUser!.uid}",
        DbBase().postRequestType,
        body: {"productId": productId});
    return jsonDecode(response);
  }

  static deleteFromFavorite(String productId) async {
    var response = await DbBase().databaseRequest(
        "$favorite/${FirebaseAuth.instance.currentUser!.uid}",
        DbBase().deleteRequestType,
        body: {"productId": productId});
    return jsonDecode(response);
  }

  static friendsToInvite() async {
    var response = await DbBase().databaseRequest(
        followersfollowing + FirebaseAuth.instance.currentUser!.uid,
        DbBase().getRequestType);
    return jsonDecode(response);
  }

  static searchFriends(String searchText) async {
    var response = await DbBase().databaseRequest(
        "$followersfollowingsearch${FirebaseAuth.instance.currentUser!.uid}/$searchText",
        DbBase().getRequestType);
    return jsonDecode(response);
  }

  static getUserCheckByEmail(String email) async {
    var response = await DbBase().databaseRequest(
        "$userExistsByEmail?email=$email", DbBase().getRequestType);
    return jsonDecode(response);
  }

  static getSettings() async {
    var response =
        await DbBase().databaseRequest(settings, DbBase().getRequestType);
    return jsonDecode(response);
  }

  static Future deleteStripeBankAccount() async {
    var response = await DbBase().databaseRequest(
        "$stripeAccountsDelete/${FirebaseAuth.instance.currentUser!.uid}",
        DbBase().deleteRequestType,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': "Bearer $stripeSecretKey"
        });
    return jsonDecode(response);
  }

  static approveSeller() async {
    var response = await DbBase().databaseRequest(
        "$approveeller/${FirebaseAuth.instance.currentUser!.uid}",
        DbBase().patchRequestType);
    return jsonDecode(response);
  }

  saveUserTipTransaction(Map<String, dynamic> payload) async {
    var response = await DbBase()
        .databaseRequest(tip, DbBase().postRequestType, body: payload);
    return jsonDecode(response);
  }

  static getFriends({String? name = ""}) async {
    var response = await DbBase().databaseRequest(
        "$friends/${FirebaseAuth.instance.currentUser!.uid}?name=$name",
        DbBase().getRequestType);
    return jsonDecode(response);
  }

  static getShipping() async {
    var response =
        await DbBase().databaseRequest(shipping, DbBase().getRequestType);
    return jsonDecode(response);
  }

  static getShippingUser(String userId) async {
    var response = await DbBase()
        .databaseRequest("$shipping/user/$userId", DbBase().getRequestType);
    return jsonDecode(response);
  }

  static updateShippingCost(String value) async {
    var response = await DbBase().databaseRequest(
        "$shipping/${FirebaseAuth.instance.currentUser!.uid}",
        DbBase().putRequestType,
        body: {"shipping": value});
    return jsonDecode(response);
  }

  registerUser(Map<String, String?> map) async {
    var response = await DbBase()
        .databaseRequest(register, DbBase().postRequestType, body: map);
    return jsonDecode(response);
  }

  loginUser(Map<String, String> map) async {
    var response = await DbBase()
        .databaseRequest(login, DbBase().postRequestType, body: map);
    return jsonDecode(response);
  }

  static getWcSettigs(user, key) async {
    var response = await DbBase().databaseRequest(
        "$allsettings?user=$user&key=$key", DbBase().getRequestType);
    return jsonDecode(response);
  }

  static disconectWc(user, key) async {
    var response = await DbBase().databaseRequest(
        "$allsettings?user=$user&key=$key", DbBase().putRequestType);
    return jsonDecode(response);
  }

  String createBasicAuthHeader(String key, String secret) {
    String raw = '$key:$secret';
    return 'Basic ${base64Encode(utf8.encode(raw))}';
  }

  fetchPublishedProductCount() async {
    var response = await DbBase().databaseRequest(
        "${userController.wcSettigs["wcUrl"]}$wcproducts&status=publish",
        DbBase().getRequestType,
        headers: {
          'Authorization': createBasicAuthHeader(
              userController.wcSettigs["wcConsumerKey"],
              userController.wcSettigs["wcSecretKey"])
        },
        returnFullResponse: true);
    return response;
  }

  static updateSync(String key, String setting, bool v) async {
    var response = await DbBase().databaseRequest(
        "$allsettingsuppdate?user=${authController.usermodel.value?.id}&key=$key&$setting=$v",
        DbBase().putRequestType);
    return jsonDecode(response);
  }

  static getnotificationSettings() async {
    var response = await DbBase().databaseRequest(
        "$notificationsettigs/${FirebaseAuth.instance.currentUser!.uid}",
        DbBase().getRequestType);
    return jsonDecode(response);
  }

  static updatenotificationSettings(Map<String, dynamic> payload) async {
    var response = await DbBase().databaseRequest(
        "$notificationsettigs/${FirebaseAuth.instance.currentUser!.uid}",
        DbBase().putRequestType,
        body: payload);
    return jsonDecode(response);
  }

  static deleteAddress(String s) async {
    var response = await DbBase()
        .databaseRequest("$address/$s", DbBase().deleteRequestType);
    return jsonDecode(response);
  }
}
