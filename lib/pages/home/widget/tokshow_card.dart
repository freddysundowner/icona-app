import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tokshop/main.dart';
import 'package:tokshop/pages/profile/my_profile.dart';
import 'package:tokshop/pages/profile/view_profile.dart';

import '../../../controllers/product_controller.dart';
import '../../../controllers/room_controller.dart';
import '../../../models/tokshow.dart';
import '../../../widgets/video_player_preview.dart';

class TokshowCard extends StatelessWidget {
  final Tokshow tokShow;

  const TokshowCard({
    super.key,
    required this.tokShow,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                if (tokShow.owner?.id == authController.currentuser?.id) {
                  Get.to(() => MyProfilePage());
                } else {
                  Get.to(() => ViewProfile(user: tokShow.owner!.id!));
                }
              },
              child: Row(
                children: [
                  tokShow.owner != null && tokShow.owner!.profilePhoto != ""
                      ? CircleAvatar(
                          radius: 10,
                          backgroundImage:
                              NetworkImage(tokShow.owner!.profilePhoto!),
                        )
                      : const CircleAvatar(
                          radius: 10,
                          backgroundImage: AssetImage(
                              "assets/icons/profile_placeholder.png"),
                        ),
                  SizedBox(
                    width: 0.02.sw,
                  ),
                  Expanded(
                    child: Text(
                      "${tokShow.owner!.firstName!} ${tokShow.owner!.lastName!}",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 5,
            ),
            if (tokShow.previewVideos!.isNotEmpty)
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: VideoPlayerWidget(
                  customImage: CustomImage(
                      path: tokShow.previewVideos!, imgType: ImageType.network),
                  volume: 0.0,
                ),
              ),
            if (tokShow.previewVideos!.isEmpty && tokShow.thumbnail!.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                height: 220,
                child: AspectRatio(
                  aspectRatio: 1.1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    child: CachedNetworkImage(
                        imageUrl: tokShow.thumbnail ?? "",
                        fit: BoxFit.cover,
                        width: 10),
                  ),
                ),
              ),
            if (tokShow.previewVideos!.isEmpty && tokShow.thumbnail!.isEmpty)
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                height: 220,
                child: AspectRatio(
                  aspectRatio: 1.1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    child: Image.asset("assets/images/image_placeholder.jpg",
                        fit: BoxFit.cover),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tokShow.title!.capitalizeFirst ?? "",
                    style: Theme.of(context).textTheme.bodyLarge,
                    maxLines: 2,
                  ),
                  SizedBox(height: 2),
                  Text(
                    tokShow.category?.name ?? "",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          top: 30,
          left: 10,
          child: tokShow.ended == true
              ? SizedBox(
                  width: 60,
                  height: 20,
                )
              : Get.find<TokShowController>().checkDateGreaterthaNow(tokShow)
                  ? Container(
                      width: 60,
                      height: 20,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: Colors.red),
                      child: Center(
                        child: Text(
                          "live_viewers".trParams({
                            "viewers": tokShow.viewers?.length.toString() ?? "0"
                          }),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.white),
                        ),
                      ),
                    )
                  : Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: Colors.white),
                      child: Text(
                        getWhenItsHappening(tokShow),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.black),
                      ),
                    ),
        ),
      ],
    );
  }

  String getWhenItsHappening(Tokshow tokShow) {
    DateTime now = DateTime.now();
    DateTime startDate = DateTime.fromMillisecondsSinceEpoch(tokShow.date!);
    Duration difference = startDate.difference(now);
    //if today, show like "Today at 10:00 AM"
    if (difference.inDays == 0) {
      return "today".trParams({"time": DateFormat.jm().format(startDate)});
    } else if (difference.inDays == 1) {
      return "tomorrow".trParams({"time": DateFormat.jm().format(startDate)});
    } else {
      return DateFormat.yMd().format(startDate);
    }
  }
}
