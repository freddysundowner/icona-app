import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tokshop/models/tokshow.dart';

import '../../controllers/room_controller.dart';
import '../../pages/live/live_tokshows.dart';

class LiveSellingSection extends StatelessWidget {
  final List<String> liveAvatars = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LiveAvatarsList(),
      ],
    );
  }
}

class LiveAvatarsList extends StatelessWidget {
  final TokShowController tokShowController = Get.find<TokShowController>();
  LiveAvatarsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Obx(
        () => ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: tokShowController.allroomsList.length + 1,
          itemBuilder: (context, index) {
            // If it's the first item, show the "Go Live" button
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: GestureDetector(
                  onTap: () {
                    // Get.to(() => LiveSellingPage());
                    // tokshowcontroller.createRoomView();
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        painter: DashedCirclePainter(),
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            // A gradient background can give it a standout look
                            gradient: const LinearGradient(
                              colors: [Colors.red, Colors.pink],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'shorts'.tr,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'SchibstedGrotesk',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              Tokshow room = tokShowController.allroomsList[index - 1];
              return InkWell(
                splashColor: Colors.transparent,
                onTap: () {
                  Get.to(() => LiveShowPage(roomId: room.id!));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        painter: DashedCirclePainter(),
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: CircleAvatar(
                              radius: 25,
                              backgroundImage:
                                  NetworkImage(room.owner!.profilePhoto!),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class DashedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final double radius = size.width / 2;
    const double dashLength = 5;
    const double gapLength = 3;

    double circumference = 2 * 3.14 * radius;
    double dashGapCount = circumference / (dashLength + gapLength);

    double startAngle = 0;
    final double sweepAngle = (dashLength / radius);

    for (int i = 0; i < dashGapCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(
            center: Offset(size.width / 2, size.height / 2), radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += (dashLength + gapLength) / radius;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
