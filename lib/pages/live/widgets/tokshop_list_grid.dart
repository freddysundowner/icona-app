import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../main.dart';
import '../../../models/tokshow.dart';
import '../../../widgets/live/no_items.dart';
import '../../../widgets/slogan_icon_card.dart';
import '../../home/widget/tokshow_card.dart';
import '../live_tokshows.dart';
import '../new_tokshow.dart';

class TokshopListGrid extends StatelessWidget {
  List<Tokshow> rooms;
  ScrollController scrollController;
  double? aspectRatio;
  double verticalMargin;
  TokshopListGrid(
      {super.key,
      required this.rooms,
      this.aspectRatio = 0.55,
      required this.scrollController,
      this.verticalMargin = 20});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        // Show loader if we’re getting the *very first* page
        if (tokShowController.isLoading.value && rooms.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (rooms.isEmpty) {
          return NoItems(content: Text("no_shows".tr));
        }

        // Build grid
        return GridView.builder(
          controller: scrollController,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: aspectRatio ?? 0.55,
            crossAxisSpacing: 25,
          ),
          itemCount:
              rooms.length + (tokShowController.hasMoreRooms.isTrue ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < rooms.length) {
              final tokShow = rooms[index];
              return InkWell(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: () => auction_actions(context, tokShow),
                child: TokshowCard(tokShow: tokShow),
              );
            } else {
              // The "extra" loader at the bottom
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
        );
      },
    );
  }

  void auction_actions(BuildContext context, Tokshow tokshow) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (FirebaseAuth.instance.currentUser!.uid == tokshow.owner!.id &&
                  tokshow.ended == false &&
                  tokshow.started == false)
                SloganIconCard(
                  title: "edit".tr,
                  leftIcon: Icons.edit,
                  backgroundColor: Colors.transparent,
                  rightIcon: Icons.arrow_forward_ios_outlined,
                  function: () {
                    Get.back();
                    Get.to(() => NewTokshow(
                          roomModel: tokshow,
                        ));
                  },
                ),
              if (FirebaseAuth.instance.currentUser!.uid == tokshow.owner!.id)
                SloganIconCard(
                  title: tokshow.started == false ? "preview".tr : "resume".tr,
                  leftIcon: Icons.edit,
                  backgroundColor: Colors.transparent,
                  rightIcon: Icons.arrow_forward_ios_outlined,
                  function: () {
                    Get.back();
                    Get.to(() => LiveShowPage(
                          roomId: tokshow.id!,
                        ));
                  },
                ),
              if (FirebaseAuth.instance.currentUser!.uid == tokshow.owner!.id)
                SloganIconCard(
                  title: "delete".tr,
                  backgroundColor: Colors.transparent,
                  leftIcon: Icons.delete,
                  rightIcon: Icons.arrow_forward_ios_outlined,
                  function: () {
                    Get.back();
                    tokShowController.deleteEvent(tokshow.id!);
                  },
                  titleStyle: TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                )
            ],
          ),
        );
      },
    );
  }
}
