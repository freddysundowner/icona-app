import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:tokshop/pages/live/new_tokshow.dart';
import 'package:tokshop/pages/profile/address_details_form.dart';

import '../controllers/global.dart';
import '../controllers/room_controller.dart';
import '../controllers/user_controller.dart';
import '../main.dart';
import '../utils/styles.dart';
import '../widgets/bottom_sheet_dialog.dart';
import 'account.dart';
import 'activities/activities.dart';
import 'browse/categories_search.dart';
import 'home/body_views.dart';
import 'inventory/add_edit_product_screen.dart';
import 'onboard/guidelines.dart';

class HomeScreen extends StatelessWidget {
  final GlobalController _global = Get.find<GlobalController>();
  final UserController userController = Get.find<UserController>();
  final TokShowController tokShowController = Get.find<TokShowController>();
  final List<Widget> _pages = [
    BodyViews(),
    CategoriesSearch(),
    Activities(),
    Account()
  ];
  HomeScreen({super.key}) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      tokShowController.getTokshows(status: "active", category: "all");
      productController.getCategories();
    });
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: theme.brightness == Brightness.dark
          ? SystemUiOverlayStyle.light // white status bar text/icons
          : SystemUiOverlayStyle.dark, // black status bar text/icons(
      child: Obx(
        () => RefreshIndicator(
          onRefresh: () async {
            await tokShowController.getTokshows(
                status: 'active', category: 'all');
            await productController.getAllroducts(type: "home");
            productController.getCategories();
          },
          child: Scaffold(
            body: Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: _pages[_global.tabPosition.value],
            ),
            bottomNavigationBar: Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom, top: 8),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(
                    color: kTextColor,
                    width: 0.5,
                  ),
                ),
              ),
              child: Container(
                margin: const EdgeInsets.only(bottom: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      onTap: () {
                        _global.tabPosition.value = 0;
                        tokShowController.getTokshows(
                            status: 'active', category: 'all');
                      },
                      child: _tab(theme, 'home.png', 'home'.tr, false, 0),
                    ),
                    InkWell(
                      onTap: () {
                        productController.selectedFilterCategoryTab.value =
                            "recommended";
                        productController.getCategories(
                            page: "1", type: "recommended");
                        _global.tabPosition.value = 1;
                      },
                      child:
                          _tab(theme, 'SearchIcon.svg', 'browse'.tr, true, 1),
                    ),
                    InkWell(
                      onTap: () async {
                        showFilterBottomSheet(
                            context,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    Get.back();

                                    if (authController
                                            .usermodel.value!.seller ==
                                        false) {
                                      Get.to(() => Guidelines());
                                    } else {
                                      if (authController.currentuser?.address ==
                                          null) {
                                        showAlert(context);
                                        return;
                                      }
                                      Get.to(() => AddEditProductScreen());
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20, horizontal: 30),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "create_a_product".tr,
                                          style: TextStyle(fontSize: 21),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color: Colors.grey,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Divider(
                                  color: theme.dividerColor,
                                ),
                                InkWell(
                                  onTap: () {
                                    Get.back();
                                    if (authController
                                            .usermodel.value!.seller ==
                                        false) {
                                      Get.to(() => Guidelines());
                                    } else {
                                      if (authController.currentuser?.address ==
                                          null) {
                                        showAlert(context);
                                        return;
                                      }
                                      Get.to(() => NewTokshow());
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 20, horizontal: 30),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "schedule_a_live_show".tr,
                                          style: TextStyle(fontSize: 21),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color: Colors.grey,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            initialChildSize: 0.25);
                      },
                      child: _tab(theme, 'live_icon.svg', 'sell'.tr, true, 5),
                    ),
                    InkWell(
                      onTap: () {
                        _global.tabPosition.value = 2;
                      },
                      child:
                          _tab(theme, 'activity.svg', 'activity'.tr, true, 2),
                    ),
                    InkWell(
                      onTap: () {
                        Get.find<UserController>()
                            .getUserProfile(authController.currentuser!.id!);
                        _global.tabPosition.value = 3;
                      },
                      child: _tab(theme, 'user_ico.svg', 'account'.tr, true, 3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  showAlert(BuildContext context) {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        context: Get.context!,
        isScrollControlled: true,
        builder: (context) => Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(Get.context!).viewInsets.bottom),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Center(
                      child: Text(
                        'welcome_to_tokshow_in_order_to_start_live_or_auctions'
                            .tr,
                        style: TextStyle(fontSize: 18.sp),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    InkWell(
                      onTap: () {
                        Get.back();
                        Get.to(() => AddressDetailsForm());
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(15)),
                        child: Center(
                          child: Text(
                            'add_shipping_address'.tr,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.surface,
                                fontSize: 13.sp),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }

  Column _tab(ThemeData theme, String icon, String title, bool svg, int i) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (svg == false)
          Image.asset(
            "assets/icons/$icon",
            color: _global.tabPosition.value == i
                ? theme.colorScheme.onSurface
                : kTextColor,
            width: 25,
          ),
        if (svg == true)
          SvgPicture.asset(
            "assets/icons/$icon",
            color: _global.tabPosition.value == i
                ? theme.colorScheme.onSurface
                : kTextColor,
            width: 25,
          ),
        SizedBox(
          height: 2,
        ),
        Text(
          title,
          style: TextStyle(
              fontSize: 11.sp,
              color: _global.tabPosition.value == i
                  ? theme.colorScheme.onSurface
                  : kTextColor),
        )
      ],
    );
  }
}
