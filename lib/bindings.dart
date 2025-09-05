import 'package:get/get.dart';
import 'package:tokshop/controllers/auction_controller.dart';
import 'package:tokshop/controllers/order_controller.dart';
import 'package:tokshop/controllers/room_controller.dart';
import 'package:tokshop/controllers/shipping_controller.dart';
import 'package:tokshop/controllers/wallet_controller.dart';

import 'controllers/auth_controller.dart';
import 'controllers/checkout_controller.dart';
import 'controllers/give_away_controller.dart';
import 'controllers/global.dart';
import 'controllers/notifications_controller.dart';
import 'controllers/payment_controller.dart';
import 'controllers/product_controller.dart';
import 'controllers/search_controller.dart';
import 'controllers/user_controller.dart';
import 'controllers/wishlist_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() async {
    Get.put<ProductController>(ProductController(), permanent: true);
    Get.put<CheckOutController>(CheckOutController(), permanent: true);
    Get.put<GlobalController>(GlobalController(), permanent: true);
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<UserController>(UserController(), permanent: true);
    Get.put<WishListController>(WishListController(), permanent: true);
    Get.put<WalletController>(WalletController(), permanent: true);
    Get.put<TokShowController>(TokShowController(), permanent: true);
    Get.put<AuctionController>(AuctionController(), permanent: true);
    Get.put<OrderController>(OrderController(), permanent: true);
    Get.put<NotificationsController>(NotificationsController(),
        permanent: true);
    Get.put<PaymentController>(PaymentController(), permanent: true);
    Get.put<BrowseController>(BrowseController(), permanent: true);
    Get.put<GiveAwayController>(GiveAwayController(), permanent: true);
    Get.put<ShippingController>(ShippingController(), permanent: true);
  }
}
