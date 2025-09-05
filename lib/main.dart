import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tokshop/controllers/product_controller.dart';
import 'package:tokshop/controllers/room_controller.dart';
import 'package:tokshop/controllers/user_controller.dart';
import 'package:tokshop/pages/activities/purchase_details.dart';
import 'package:tokshop/pages/authetication/handle_auth_page.dart';
import 'package:tokshop/pages/home/woocommerce_vendor_page.dart';
import 'package:tokshop/pages/live/live_tokshows.dart';
import 'package:tokshop/pages/profile/view_profile.dart';
import 'package:tokshop/pages/splash_screen.dart';
import 'package:tokshop/services/orders_api.dart';
import 'package:tokshop/services/user_api.dart';
import 'package:tokshop/utils/configs.dart';
import 'package:tokshop/utils/styles.dart';
import 'package:url_launcher/url_launcher.dart';

import 'bindings.dart';
import 'controllers/auth_controller.dart';
import 'controllers/chat_controller.dart';
import 'controllers/give_away_controller.dart';
import 'controllers/shipping_controller.dart';
import 'models/order.dart';
import 'theme_controller.dart';
import 'translations.dart';

var stripePublishKey = "";
var stripeSecretKey = "";
var tip_processing = 0.0;
var agoraAppID = "";
final AuthController authController = Get.put(AuthController());
final UserController userController = Get.put(UserController());
final ProductController productController = Get.put(ProductController());
final TokShowController tokShowController = Get.put(TokShowController());
final ThemeController themeController = Get.put(ThemeController());
final GiveAwayController giveAwayController = Get.put(GiveAwayController());
final ShippingController shippingController = Get.put(ShippingController());
final ChatController _chatController =
    Get.put<ChatController>(ChatController());

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void navigateFromNotification(Map<String, dynamic>? data) async {
  if (data == null) return;

  String? screen = data["screen"];
  String? id = data["id"];

  switch (screen) {
    case 'ChatScreen':
      final chatController = Get.find<ChatController>();
      chatController.currentChatId.value = id!;
      await chatController.getChatById(id);
      await chatController.getChatUsers(id);
      // Get.to(() => ChatRoomPage(chatId: id));
      break;

    case "ProfileScreen":
      Get.to(() => ViewProfile(user: id!));
      break;

    case "RoomChatScreen":
      tokShowController.roomPageInitialPage.value = 0;
      tokShowController.pageController.jumpToPage(0);
      break;

    case "RoomScreen":
      Get.to(() => LiveShowPage(
            roomId: id!,
          ));
      break;

    case "OrderScreen":
      var res = await OrderApi.getOrderById(id!);
      Get.to(() => PurchaseDetailsPage(
            order: Order.fromJson(res),
          ));
      break;
  }
}

void showLocalNotification(RemoteMessage message) {
  final notification = message.notification;
  final data = message.data;

  if (notification == null) return;

  flutterLocalNotificationsPlugin.show(
    notification.hashCode,
    notification.title,
    notification.body,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'default_channel',
        'Notifications',
        importance: Importance.max,
      ),
    ),
    payload: jsonEncode(data), // pass data as payload
  );
}

getApiSettings() async {
  try {
    List response = await UserAPI.getSettings();
    if (response.isNotEmpty) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String code = packageInfo.buildNumber;
      String type = "";
      String url = "";
      if (Platform.isAndroid) {
        type = "androidVersion";
        url =
            "https://play.google.com/store/apps/details?id=$androidPackageName&hl=en&gl=US";
      } else if (Platform.isIOS) {
        type = "iosVersion";
        url = "https://apps.apple.com/us/app/itunes-connect/id$iosAppID";
      }
      if (response.first['forceUpdate'] == true &&
          response.first[type] != null &&
          response.first[type] != "" &&
          int.parse(code) > int.parse(response[0][type])) {
        Future.delayed(const Duration(seconds: 2), () {
          GetSnackBar(
            snackPosition: SnackPosition.TOP,
            messageText: Text(
              'appUpdate_message'.tr,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            mainButton: InkWell(
              onTap: () async {
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url));
                } else {
                  throw "Could not launch $url";
                }
              },
              child: Text('updateNowMessage'.tr,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ),
            backgroundColor: kPrimaryColor,
          ).show();
        });
      }
      agoraAppID = response[0]["agoraAppID"];
      currencySymbol = response[0]["currency"];
      stripePublishKey = response[0]["stripepublickey"];
      stripeSecretKey = response[0]["stripeSecretKey"];
      privacyPolicyUrl = response[0]["privacy_url"];
      termsAndConditionsUrl = response[0]["terms_url"];
      supportEmail = response[0]["support_email"] ?? "";
    }
  } finally {
    try {
      await FirebaseMessaging.instance.requestPermission();
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null && FirebaseAuth.instance.currentUser != null) {
        await UserAPI().updateUser(
            {"fcmToken": fcmToken}, FirebaseAuth.instance.currentUser!.uid);
      }
    } catch (e) {}
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // transparent so UI goes under it
      statusBarIconBrightness: Brightness.light, // white icons
      statusBarBrightness: Brightness.dark, // iOS (inverted logic)
    ),
  );
  await Firebase.initializeApp();
  await getApiSettings();
  if (stripePublishKey.isNotEmpty) {
    Stripe.publishableKey = stripePublishKey;
    Stripe.merchantIdentifier = 'tokshop';
    await Stripe.instance.applySettings();
  }
  await productController.loadRecents();
  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
        android: AndroidInitializationSettings('logo'),
        iOS: DarwinInitializationSettings()),
    onDidReceiveNotificationResponse: (response) {
      final payload = response.payload;
      if (payload != null) {
        navigateFromNotification(jsonDecode(payload));
      }
    },
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    showLocalNotification(message);
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    navigateFromNotification(message.data);
  });

  // Handle notification tap when the app was terminated
  final RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigateFromNotification(initialMessage.data);
    });
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _runWhileAppIsTerminated();
  }

  void _runWhileAppIsTerminated() async {
    var details =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    if (details!.didNotificationLaunchApp) {
      await SharedPreferences.getInstance();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (BuildContext context, c) {
          return Obx(() => GetMaterialApp(
                debugShowCheckedModeBanner: false,
                translations: AppTranslations(),
                locale: Get.deviceLocale,
                fallbackLocale: Locale('en'),
                getPages: [
                  GetPage(name: '/', page: () => const HandleAuthPage()),
                  GetPage(name: '/wc-success', page: () => WcVendorSuccess()),
                ],
                initialRoute: '/', // keep routes if needed
                theme: ThemeController.lightTheme,
                darkTheme: ThemeController.darkTheme,
                initialBinding: AuthBinding(),
                themeMode: themeController.currentThemeMode,

                // ✅ start here
                home: const SplashScreen(),
              ));
        });
  }
}
