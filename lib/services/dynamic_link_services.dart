import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tokshop/controllers/user_controller.dart';
import 'package:tokshop/services/product_api.dart';

import '../controllers/room_controller.dart';
import '../pages/products/product_detail.dart';
import '../utils/utils.dart';

class DynamicLinkService {
  final TokShowController _tokshowcontroller = Get.put(TokShowController());
  // Future<String> generateShareLink(String groupId,
  //     {String? type,
  //     String? title = "",
  //     String? msg = "",
  //     String? imageurl = ""}) async {
  //   final DynamicLinkParameters parameters = DynamicLinkParameters(
  //     uriPrefix: deepLinkUriPrefix,
  //     link: Uri.parse(_createLink(groupId, type!)),
  //     androidParameters: AndroidParameters(
  //       packageName: androidPackageName,
  //     ),
  //     // NOT ALL ARE REQUIRED ===== HERE AS AN EXAMPLE =====
  //     iosParameters: IOSParameters(
  //       bundleId: androidPackageName,
  //       minimumVersion: '1.7',
  //       appStoreId: '1630634917',
  //     ),
  //     socialMetaTagParameters: SocialMetaTagParameters(
  //         title: title ?? "TokShop",
  //         description: msg,
  //         imageUrl: Uri.parse(imageurl!)),
  //   );
  //
  //   final ShortDynamicLink dynamicUrl =
  //       await FirebaseDynamicLinks.instance.buildShortLink(parameters);
  //   return dynamicUrl.shortUrl.toString();
  // }
  String generateShareLink(String tokshowId) {
    return 'https://tokshoplive.com/tokshow?id=$tokshowId&utm_source=app&utm_medium=share';
  }

  Future handleDynamicLinks() async {
    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();

    if (data != null) {
      _handleDeepLink(data);
    }

    FirebaseDynamicLinks.instance.onLink.listen(
        (PendingDynamicLinkData dynamicLink) async {
      _handleDeepLink(dynamicLink);
    }, onError: (error) async {
      printOut("Error FirebaseDynamicLinks.instance.onLink $error");
    });
  }

  Future<void> _handleDeepLink(PendingDynamicLinkData data) async {
    final Uri deepLink = data.link;

    if (deepLink.queryParameters['type'] == "refer") {
      var groupId = deepLink.queryParameters['groupid'];
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString("referrer", groupId!);
    }
    if (deepLink.queryParameters['type'] == "product") {
      var groupId = deepLink.queryParameters['groupid'];
      var element = await ProductPI().getProductById(groupId!);
      Get.to(ProductDetails(
        product: element,
      ));
    }

    if (FirebaseAuth.instance.currentUser != null) {
      if (deepLink.queryParameters['type'] == "room") {
        var groupId = deepLink.queryParameters['groupid'];
        _tokshowcontroller.joinRoom(groupId!);
      } else if (deepLink.queryParameters['type'] == "profile") {
        var groupId = deepLink.queryParameters['groupid'];
        await Get.find<UserController>().getUserProfile(groupId!);
        // Get.to(() => UserProfile());
      }
    }
  }
}
