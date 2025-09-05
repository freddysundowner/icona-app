import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/payment_controller.dart';
import 'package:tokshop/main.dart';
import 'package:tokshop/pages/onboard/guidelines.dart';
import 'package:tokshop/pages/payout/payout_page.dart';
import 'package:tokshop/pages/profile/my_profile.dart';
import 'package:tokshop/pages/profile/shipping_address.dart';
import 'package:tokshop/pages/profile/shippinng/shipping.dart';
import 'package:tokshop/pages/profile/view_profile.dart';
import 'package:tokshop/utils/configs.dart';
import 'package:tokshop/utils/helpers.dart';
import 'package:tokshop/widgets/shippping_payment_method_alert.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/global.dart';
import '../widgets/content_card_one.dart';
import '../widgets/custom_button.dart';
import '../widgets/show_image.dart';
import 'home/woocommerce_vendor_page.dart';
import 'homescreen.dart';
import 'inventory/my_inventory.dart';
import 'live/my_shows.dart';
import 'notifications/notification_settings.dart';

class Account extends StatelessWidget {
  final PaymentController paymentController = Get.find<PaymentController>();
  Account({super.key}) {
    userController.getWcSettings(FirebaseAuth.instance.currentUser!.uid);
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(
      () => DefaultTabController(
        length: authController.usermodel.value!.seller == true ? 2 : 1,
        child: Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => Column(
                  children: [
                    SizedBox(height: 20),
                    // Profile Section
                    Row(
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 20),
                          child: ShowImage(
                            image:
                                authController.usermodel.value!.profilePhoto!,
                            width: 45,
                            height: 45,
                          ),
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authController.usermodel.value?.firstName ?? "",
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            SizedBox(height: 5),
                            CustomButton(
                              function: () {
                                if (authController.usermodel.value!.id ==
                                    userController.currentProfile.value.id) {
                                  Get.to(() => MyProfilePage());
                                } else {
                                  Get.to(() => ViewProfile(
                                        user: userController
                                            .currentProfile.value.id!,
                                      ));
                                }
                              },
                              text: 'view_profile'.tr,
                              height: 25,
                              width: 100,
                              fontSize: 12,
                              backgroundColor: theme.colorScheme.onSurface,
                              textColor: theme.colorScheme.surface,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    authController.usermodel.value!.seller == true
                        ? TabBar(
                            isScrollable: true,
                            indicatorColor: theme.colorScheme.primary,
                            labelColor: theme.textTheme.bodyLarge!.color,
                            unselectedLabelColor:
                                theme.textTheme.bodyMedium!.color,
                            labelPadding: EdgeInsets.symmetric(horizontal: 10),
                            padding: EdgeInsets.zero,
                            tabAlignment: TabAlignment.start,
                            labelStyle: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold, fontSize: 16),
                            tabs: [
                              Tab(text: 'seller_hub'.tr),
                              Tab(text: 'account'.tr)
                            ],
                          )
                        : Container()
                  ],
                ),
              ),
              Obx(
                () => Expanded(
                  child: TabBarView(
                    children: [
                      if (authController.usermodel.value!.seller == true)
                        ListView(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                    child: ContentCardOne(
                                  content: "inventory".tr,
                                  icon: Icons.local_offer,
                                  function: () {
                                    Get.to(() => MyInventory());
                                  },
                                )),
                                Expanded(
                                    child: ContentCardOne(
                                  content: "shows".tr,
                                  icon: Icons.waves,
                                  function: () {
                                    Get.to(() => MyTokshows());
                                  },
                                )),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                    child: ContentCardOne(
                                  content: "orders".tr,
                                  icon: Icons.receipt,
                                  function: () {
                                    Get.find<GlobalController>()
                                        .tabPosition
                                        .value = 2;
                                    userController.activityTabIndex.value = 1;
                                    Get.to(() => HomeScreen());
                                  },
                                )),
                                Expanded(
                                    child: ContentCardOne(
                                  content: "payouts".tr,
                                  icon: Icons.monetization_on,
                                  function: () {
                                    Get.to(() => PayoutPage());
                                  },
                                )),
                              ],
                            ),
                            // _customListTile(
                            //   context,
                            //   icon: Icons.monetization_on_outlined,
                            //   title: 'refer_seller_earn'.tr,
                            //   onTap: () {
                            //     showCustomBottomSheet(
                            //         context, 'refer_seller_earn'.tr);
                            //   },
                            // ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "settings".tr,
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  Divider(),
                                ],
                              ),
                            ),
                            _customListTile(
                              context,
                              icon: Icons.local_shipping,
                              title: 'shipping'.tr,
                              subtitle: "",
                              onTap: () {
                                Get.to(() => ShippingPage());
                              },
                            ),
                            // _customListTile(
                            //   context,
                            //   iconWidget: Image.asset(
                            //     'assets/icons/shopify.png',
                            //     width: 24,
                            //     height: 24,
                            //   ),
                            //   title: 'import_shopify_store'.tr,
                            //   onTap: () async {
                            //     if (await canLaunchUrl(
                            //         Uri.parse(importshopify))) {
                            //       await launchUrl(Uri.parse(importshopify),
                            //           mode: LaunchMode.externalApplication);
                            //     } else {
                            //       throw 'Could not launch $importshopify';
                            //     }
                            //
                            //     // print("importshopify: $importshopify");
                            //     // Get.to(() =>
                            //     //     SimpleWebView(initialUrl: importshopify));
                            //     // productController.importShopify(context);
                            //     // importProducts(context,
                            //     //     type: "shopify",
                            //     //     widget: Column(
                            //     //       mainAxisSize: MainAxisSize.min,
                            //     //       children: [],
                            //     //     ));
                            //   },
                            // ),
                            _customListTile(
                              context,
                              iconWidget: Image.asset(
                                'assets/icons/woocommerce.png',
                                width: 24,
                                height: 24,
                              ),
                              title:
                                  userController.wcSettigs["wcConsumerKey"] ==
                                          null
                                      ? 'import_woocommerce_store'.tr
                                      : 'woocommerce_setup'.tr,
                              onTap: () {
                                if (userController.wcSettigs["wcConsumerKey"] !=
                                    null) {
                                  Get.to(() => WcVendorSuccess());
                                  return;
                                }
                                importProducts(context,
                                    type: "woocommerce",
                                    widget: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [],
                                    ));
                              },
                            ),
                          ],
                        ),
                      ListView(children: [
                        if (authController.usermodel.value!.seller == false)
                          SizedBox(height: 20),
                        if (authController.usermodel.value!.seller == false)
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 16),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'low_commission'.tr,
                                  style:
                                      Theme.of(context).textTheme.displaySmall,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'low_commission_desc'.tr,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomButton(
                                      function: () {},
                                      text: 'faq'.tr,
                                      backgroundColor: theme
                                          .colorScheme.onSecondaryContainer,
                                      height: 30.h,
                                    ),
                                    CustomButton(
                                      function: () {
                                        Get.to(() => Guidelines());
                                      },
                                      text: 'get_started'.tr,
                                      height: 30.h,
                                      backgroundColor:
                                          theme.colorScheme.primary,
                                      textColor: theme.colorScheme.onPrimary,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        if (authController.usermodel.value!.seller == false)
                          SizedBox(height: 10),
                        Row(
                          children: [
                            ContentCardOne(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer
                                  .withValues(alpha: 0.2),
                              content:
                                  '${'wallet'.tr}: ${priceHtmlFormat(authController.usermodel.value!.wallet?.toStringAsFixed(2))}',
                              icon: Icons.wallet,
                              sloganStyler:
                                  TextStyle(color: theme.colorScheme.primary),
                              function: () {
                                Get.to(() => PayoutPage());
                              },
                              width: 200,
                            ),
                          ],
                        ),
                        ..._buildCustomListTiles(context),
                      ])
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCustomListTiles(BuildContext context) {
    final theme = Theme.of(context);
    return [
      _customListTile(
        context,
        icon: Icons.payment,
        title: 'payments_shipping'.tr,
        onTap: () {
          showCustomBottomSheet(context, 'payments_shipping'.tr);
        },
      ),
      _customListTile(
        context,
        icon: Icons.location_on,
        title: 'addresses'.tr,
        onTap: () {
          userController.gettingMyAddrresses();
          Get.to(() => ShippingAddresses());
        },
      ),
      // _customListTile(
      //   context,
      //   icon: Icons.verified_user,
      //   title: 'become_verified_buyer'.tr,
      //   onTap: () {},
      // ),
      _customListTile(
        context,
        icon: Icons.notifications,
        title: 'notification_settings'.tr,
        onTap: () {
          Get.to(() => NotificationSettingsPage());
        },
      ),
      Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(
              color: theme.dividerColor,
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              "help".tr,
              style: theme.textTheme.headlineSmall,
            ),
            _customListTile(
              context,
              icon: Icons.message,
              title: 'contact_us'.tr,
              onTap: () {
                if (supportEmail.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'support_email_is_empty'.tr,
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                //   to ope email
                launch('mailto:$supportEmail');
              },
            ),
            _customListTile(
              context,
              icon: Icons.policy,
              title: 'privacy_policy'.tr,
              onTap: () async {
                if (privacyPolicyUrl.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'privacy_policy_url_is_empty'.tr,
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                String url = privacyPolicyUrl;
                if (!await launchUrl(Uri.parse(url),
                    mode: LaunchMode.inAppWebView)) {
                  throw Exception('Could not launch $url');
                }
              },
            ),
            _customListTile(
              context,
              icon: Icons.privacy_tip,
              title: 'terms_and_conditions'.tr,
              onTap: () async {
                if (termsAndConditionsUrl.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'terms_and_conditions_url_is_empty'.tr,
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                String url = termsAndConditionsUrl;
                if (!await launchUrl(Uri.parse(url),
                    mode: LaunchMode.inAppWebView)) {
                  throw Exception('Could not launch $url');
                }
              },
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSecondary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: themeController.isDarkMode.value
                        ? Icon(Icons.dark_mode)
                        : Icon(Icons.light_mode),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          "app_theme".tr,
                          style: theme.textTheme.titleMedium,
                        ),
                        Switch(
                            value: themeController.isDarkMode.value,
                            onChanged: (value) {
                              themeController.isDarkMode.value = value;
                              authController.saveTheme(
                                  themeController.isDarkMode.isTrue
                                      ? "dark"
                                      : "light");
                            }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: CustomButton(
                function: () {
                  authController.signOut();
                },
                text: 'logout'.tr,
                height: 35,
                width: MediaQuery.of(context).size.width,
                fontSize: 12,
                backgroundColor: theme.colorScheme.onSurface,
                textColor: theme.colorScheme.surface,
                iconData: Icons.logout,
              ),
            ),
            SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    ];
  }

  void importProducts(BuildContext context,
      {String type = "woocommerce", required Widget widget}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                userController.wcSettigs["wcConsumerKey"] == null
                    ? 'import_woocommerce_store_setup'
                        .trParams({'app_name': "app_name".tr})
                    : 'woocommerce_import_actions'.tr,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontSize: 16),
              ),
              SizedBox(height: 20),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: userController.urlController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "example.com",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 13.sp),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  CustomButton(
                      width: MediaQuery.of(context).size.width * 0.9,
                      text: "Connect",
                      backgroundColor: Theme.of(context).primaryColor,
                      textColor: Theme.of(context).colorScheme.onPrimary,
                      function: () {
                        Get.back();
                        productController.connectWcStore();
                      }) // close the dialog )
                ],
              ),
              SizedBox(height: 16),
              Center(
                child: CustomButton(
                  text: "cancel".tr,
                  textColor: Colors.red,
                  width: MediaQuery.of(context).size.width * 0.8,
                  function: () {
                    Get.back();
                  },
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _customListTile(
    BuildContext context, {
    IconData? icon,
    Widget? iconWidget,
    required String title,
    String? subtitle,
    required Function() onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        padding: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            if (icon != null)
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .onSecondaryContainer
                      .withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            if (iconWidget != null)
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSecondary.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: iconWidget,
              ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium,
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}
