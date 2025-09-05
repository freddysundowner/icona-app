import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tokshop/main.dart';
import 'package:tokshop/pages/live/widgets/tokshop_list_grid.dart';

import '../../widgets/search_layout.dart';
import 'new_tokshow.dart';

class MyTokshows extends StatelessWidget {
  MyTokshows({super.key}) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      tokShowController.page.value = 'mytokshows';
      tokShowController.hasMoreRooms.value = true;
      tokShowController.getTokshows(
          userid: FirebaseAuth.instance.currentUser!.uid,
          type: "mymanagedtokshows",
          status: "");
    });
  }
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: InkWell(
            child: Icon(Icons.arrow_back_ios),
            onTap: () {
              Get.back();
            },
          ),
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
        ),
        body: Column(
          children: [
            TabBar(
              isScrollable: true,
              indicatorColor: theme.colorScheme.primary,
              labelColor: theme.textTheme.bodyLarge!.color,
              unselectedLabelColor: theme.textTheme.bodyMedium!.color,
              labelPadding: EdgeInsets.symmetric(horizontal: 10),
              onTap: (i) {
                tokShowController.tabIndex.value = i;
                tokShowController.roomsPageNumber.value = 1;
                if (i == 0) {
                  tokShowController.getTokshows(
                      type: "mymanagedtokshows",
                      userid: FirebaseAuth.instance.currentUser!.uid,
                      status: "");
                }
                if (i == 2) {
                  tokShowController.getTokshows(
                      type: "mymanagedtokshows",
                      userid: FirebaseAuth.instance.currentUser!.uid,
                      status: "inactive");
                }
                if (i == 1) {
                  tokShowController.getTokshows(
                      type: "mymanagedtokshows",
                      userid: FirebaseAuth.instance.currentUser!.uid,
                      status: "active");
                }
              },
              padding: EdgeInsets.zero,
              tabAlignment: TabAlignment.start,
              labelStyle: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
              tabs: [
                Tab(text: 'all'.tr),
                Tab(text: 'active'.tr),
                Tab(text: 'inactive'.tr)
              ],
            ),
            Expanded(
                child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: TabBarView(children: [
                Column(
                  children: [
                    SearchLayout(
                      function: (text) => {
                        tokShowController.getTokshows(
                            userid: FirebaseAuth.instance.currentUser!.uid)
                      },
                    ),
                    Expanded(
                        child: TokshopListGrid(
                      rooms: tokShowController.mymanagedtokshows,
                      scrollController:
                          tokShowController.allinventoryroomsScrollController,
                    )),
                  ],
                ),
                Column(
                  children: [
                    SearchLayout(
                      function: (text) => {
                        tokShowController.getTokshows(
                          userid: FirebaseAuth.instance.currentUser!.uid,
                          status: "active",
                        )
                      },
                    ),
                    Expanded(
                        child: TokshopListGrid(
                      rooms: tokShowController.mymanagedtokshows,
                      scrollController: tokShowController
                          .activeinventoryroomsScrollController,
                    )),
                  ],
                ),
                Column(
                  children: [
                    SearchLayout(
                      function: (text) => {
                        tokShowController.getTokshows(
                          userid: FirebaseAuth.instance.currentUser!.uid,
                          status: "inactive",
                        )
                      },
                    ),
                    Expanded(
                        child: TokshopListGrid(
                      rooms: tokShowController.mymanagedtokshows,
                      scrollController: tokShowController
                          .inactiveinventoryroomsScrollController,
                    )),
                  ],
                )
              ]),
            ))
          ],
        ),
        floatingActionButton: Obx(() => tokShowController.manage.isTrue
            ? Container(
                height: 0,
              )
            : FloatingActionButton(
                onPressed: () {
                  Get.to(() => NewTokshow());
                },
                child: Icon(Icons.add),
              )),
      ),
    );
  }
}
