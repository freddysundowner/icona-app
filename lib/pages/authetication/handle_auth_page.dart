import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/product_controller.dart';
import 'package:tokshop/controllers/room_controller.dart';

import '../../controllers/auth_controller.dart';
import '../../main.dart';

class HandleAuthPage extends StatefulWidget {
  const HandleAuthPage({super.key});
  @override
  State<HandleAuthPage> createState() => _HandleAuthPageState();
}

class _HandleAuthPageState extends State<HandleAuthPage> {
  final AuthController authController = Get.put(AuthController());
  final ProductController productController = Get.put(ProductController());
  final TokShowController tokShowController = Get.put(TokShowController());

  @override
  void initState() {
    super.initState();
    _handleDeepLinkOrInit();
    _isAndroidPermissionGranted();
    _requestPermissions();
  }

  void _handleDeepLinkOrInit() async {
    final uri = Uri.base;

    if (uri.scheme == 'tokshop' && uri.host == 'wc-success') {
      final userId = uri.queryParameters['user_id'];
      if (userId != null) {
        Future.delayed(Duration(milliseconds: 300), () {
          Get.offAllNamed('/wc-success', arguments: userId); // Use offAll
        });
        return;
      }
    }

    await authController.callInit();
  }

  Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Obx(() => authController.isLoading.isTrue
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : const SizedBox()),
    );
  }
}
