import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:tokshop/controllers/auction_controller.dart';
import 'package:tokshop/controllers/auth_controller.dart';
import 'package:tokshop/controllers/checkout_controller.dart';
import 'package:tokshop/controllers/product_controller.dart';
import 'package:tokshop/controllers/room_controller.dart';
import 'package:tokshop/pages/homescreen.dart';
import 'package:tokshop/pages/live/widgets/pinned_products.dart';
import 'package:tokshop/utils/configs.dart';
import 'package:tokshop/utils/dialog.dart';
import 'package:tokshop/utils/helpers.dart';
import 'package:tokshop/widgets/shippping_payment_method_alert.dart';
import 'package:tokshop/widgets/show_image.dart';

import '../../controllers/socket_controller.dart';
import '../../main.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/live/action_product_widget.dart';
import '../../widgets/live/chats_widget.dart';
import '../../widgets/live/draggable_widget.dart';
import '../../widgets/live/float_hearts_optimized.dart';
import '../../widgets/live/giveaway_live_widget.dart';
import '../../widgets/video_player_preview.dart';
import '../products/product_detail.dart';
import '../profile/view_profile.dart';

class LiveShowPage extends StatefulWidget {
  String roomId;
  LiveShowPage({super.key, required this.roomId});

  @override
  State<LiveShowPage> createState() => _LiveShowPageState();
}

class _LiveShowPageState extends State<LiveShowPage>
    with WidgetsBindingObserver {
  final TokShowController _tokshowcontroller = Get.find<TokShowController>();
  final AuctionController auctionController = Get.find<AuctionController>();
  final CheckOutController checkOutController = Get.find<CheckOutController>();

  final AuthController authController = Get.find<AuthController>();

  final TextEditingController messageController = TextEditingController();
  String connnectionError = "";
  final socketController = Get.put(SocketController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    socketController.initSocket(
      serverUrl: baseUrl,
      defaultRoomId: widget.roomId,
      defaultUserId: FirebaseAuth.instance.currentUser!.uid,
      defaultUserName:
          authController.currentuser?.firstName ?? "", // For example
    );
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        socketController.joinRoom();
      }
    });
    _tokshowcontroller.initRoom(widget.roomId);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App is minimized → Enable PiP mode
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    socketController.disconnectSocket();
  }

  Row _liveProfileInfo(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            InkWell(
              onTap: () {
                Get.to(() => ViewProfile(
                    user: _tokshowcontroller.currentRoom.value!.owner!.id!));
              },
              child: ShowImage(
                image:
                    _tokshowcontroller.currentRoom.value!.owner!.profilePhoto!,
                width: 30,
              ),
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Get.to(() => ViewProfile(
                        user:
                            _tokshowcontroller.currentRoom.value!.owner!.id!));
                  },
                  child: Text(
                    _tokshowcontroller.currentRoom.value!.owner!.firstName!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                    softWrap: true,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "followerscount".trParams({
                        "count": _tokshowcontroller
                            .currentRoom.value!.owner!.followersCount!
                            .toString()
                      }),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontSize: 12, color: Colors.white),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    SizedBox(width: 8),
                    if (checkOwner() == false)
                      InkWell(
                        onTap: () async {
                          await _followuser();
                        },
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _tokshowcontroller
                                        .currentRoom.value!.owner!.followers
                                        .indexWhere((u) =>
                                            u.id ==
                                            FirebaseAuth
                                                .instance.currentUser?.uid) !=
                                    -1
                                ? "unfollow".tr
                                : "follow".tr,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.surface,
                                ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
        Column(
          children: [
            Row(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.remove_red_eye,
                      color: Colors.red,
                    ),
                    SizedBox(width: 4),
                    Obx(() => Text(
                          "viewers_count".trParams({
                            "count": _tokshowcontroller
                                .currentRoom.value!.viewers!.length
                                .toString()
                          }),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.white),
                        )),
                  ],
                ),
                SizedBox(width: 5),
                IconButton(
                  onPressed: () async {
                    _tokshowcontroller.timer.value?.cancel();
                    if (_tokshowcontroller.currentRoom.value!.started! ==
                        false) {
                      Get.to(() => HomeScreen());
                      return;
                    }
                    if (_tokshowcontroller.currentRoom.value!.owner!.id !=
                        FirebaseAuth.instance.currentUser!.uid) {
                      await _tokshowcontroller.leaveTokshow(
                          userController.currentProfile.value,
                          _tokshowcontroller.currentRoom.value!);
                    } else {
                      showConfirmationDialog(
                          context, "sure_want_to_end_tokshow".tr,
                          function: () async {
                        Get.back();
                        await _tokshowcontroller.leaveTokshow(
                            authController.currentuser!,
                            _tokshowcontroller.currentRoom.value!);
                      });
                    }
                  },
                  icon: Icon(
                    Icons.keyboard_arrow_down_sharp,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
            Obx(() => _tokshowcontroller.currentRoom.value!.giveAway != null &&
                    giveAwayController.expanded.isFalse &&
                    giveAwayController.isTimeRemaining(
                        _tokshowcontroller.currentRoom.value!.giveAway!)
                ? GiveawayWidget(
                    giveAway: _tokshowcontroller.currentRoom.value!.giveAway!)
                : SizedBox.shrink()),
          ],
        )
      ],
    );
  }

  Future<void> _followuser() async {
    socketController.followUser();
  }

  @override
  Widget build(BuildContext context) {
    // return HlsVideoPlayer(
    //   url:
    //       "https://storage.googleapis.com/app-hls-streams/68bc03140e6c21c35f9594b4/mf84itvb/live.m3u8",
    // );
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    return PopScope(
      onPopInvokedWithResult: (b, v) {
        tokShowController.timer.value?.cancel();
        // enablePiP();
      },
      child: Scaffold(
        body: GestureDetector(
          behavior: HitTestBehavior
              .opaque, // Ensures taps are detected even on empty space
          onTap: () {
            FocusScope.of(context)
                .requestFocus(FocusNode()); // Removes focus from TextField
          },
          child: Obx(() {
            return _tokshowcontroller.initializingRoom.isTrue ||
                    _tokshowcontroller.currentRoom.value == null
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      placeHolder(),
                      _live_view(context),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.3),
                                Colors.black.withOpacity(0.1),
                                Colors.black.withOpacity(0.1),
                                Colors.black.withOpacity(0.75),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (_tokshowcontroller.currentRoom.value?.ended == true)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black
                                .withOpacity(0.5), // Semi-transparent black
                            child: Center(
                              child: Text(
                                'show_ended'.tr,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (auctionController.showbubble.isTrue)
                        Positioned.fill(
                          child: FloatingHeartsOptimized(),
                        ),
                      Positioned(
                        top: 45,
                        left: 16,
                        right: 16,
                        child:
                            _tokshowcontroller.currentRoom.value?.owner == null
                                ? Container()
                                : _liveProfileInfo(context),
                      ),
                      if (_tokshowcontroller.currentRoom.value!.giveAway !=
                              null &&
                          giveAwayController.expanded.isTrue)
                        Positioned(
                          top: 95,
                          left: 16,
                          right: 16,
                          child: GiveawayExpandedWidget(
                            giveAway:
                                _tokshowcontroller.currentRoom.value!.giveAway!,
                          ),
                        ),
                      Positioned(
                          bottom: 20,
                          left: 16,
                          right: 16,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: ChatsWidget(
                                        isKeyboardVisible: isKeyboardVisible,
                                        chatRoomId: widget.roomId,
                                        currentUserId:
                                            authController.usermodel.value!.id!,
                                      ),
                                    ),
                                    if (!isKeyboardVisible) LiveActions(),
                                  ],
                                ),
                              ),
                              if (!isKeyboardVisible)
                                Flexible(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (_tokshowcontroller.currentRoom.value!
                                              .activeauction !=
                                          null)
                                        AuctionProductWidget(
                                            auction: _tokshowcontroller
                                                .currentRoom
                                                .value!
                                                .activeauction!,
                                            tokshow: _tokshowcontroller
                                                .currentRoom.value!),
                                      _tokshowcontroller.currentRoom.value?.activeauction != null &&
                                              (_tokshowcontroller
                                                          .currentRoom
                                                          .value
                                                          ?.activeauction!
                                                          .ended ==
                                                      false &&
                                                  _tokshowcontroller
                                                          .currentRoom
                                                          .value
                                                          ?.activeauction!
                                                          .started ==
                                                      true) &&
                                              _tokshowcontroller.currentRoom
                                                      .value!.owner!.id !=
                                                  FirebaseAuth.instance
                                                      .currentUser!.uid &&
                                              !tokShowController
                                                  .isDurationOver()
                                          ? BiddingWidget(
                                              auction: _tokshowcontroller
                                                  .currentRoom
                                                  .value!
                                                  .activeauction!,
                                              tokshow: _tokshowcontroller
                                                  .currentRoom.value!,
                                            )
                                          : Container(height: 0),
                                      if (_tokshowcontroller.currentRoom.value
                                                  ?.activeauction !=
                                              null &&
                                          _tokshowcontroller.currentRoom.value!
                                                  .owner!.id ==
                                              FirebaseAuth
                                                  .instance.currentUser!.uid &&
                                          _tokshowcontroller.currentRoom.value!
                                                  .activeauction!.started ==
                                              false &&
                                          _tokshowcontroller
                                              .checkDateGreaterthaNow(
                                                  _tokshowcontroller
                                                      .currentRoom.value) &&
                                          !_tokshowcontroller.isDurationOver())
                                        CustomButton(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.9,
                                            backgroundColor: Colors.amber,
                                            text: 'start_auction'.tr,
                                            function: () {
                                              showConfirmationDialog(
                                                  context,
                                                  "sure_want_to_start_auction"
                                                      .tr, function: () {
                                                Get.back();
                                                socketController.startAuction(
                                                    _tokshowcontroller
                                                        .currentRoom
                                                        .value!
                                                        .activeauction);
                                              });
                                            }),
                                      Obx(() =>
                                          _tokshowcontroller.currentRoom.value != null &&
                                                  _tokshowcontroller
                                                          .currentRoom
                                                          .value!
                                                          .activeauction !=
                                                      null &&
                                                  _tokshowcontroller.currentRoom
                                                          .value!.owner!.id ==
                                                      FirebaseAuth.instance
                                                          .currentUser!.uid &&
                                                  _tokshowcontroller
                                                          .currentRoom
                                                          .value!
                                                          .activeauction!
                                                          .started ==
                                                      true &&
                                                  _tokshowcontroller
                                                          .currentRoom
                                                          .value!
                                                          .activeauction!
                                                          .ended ==
                                                      false &&
                                                  !tokShowController
                                                      .isDurationOver()
                                              ? CustomButton(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.9,
                                                  backgroundColor: Colors.amber,
                                                  text: buildTrParams(),
                                                  function: () {})
                                              : Container(height: 0)),
                                      if (_tokshowcontroller.currentRoom.value
                                                  ?.activeauction !=
                                              null &&
                                          _tokshowcontroller.currentRoom.value
                                                  ?.activeauction!.started ==
                                              false &&
                                          !_tokshowcontroller
                                              .isDurationOver() &&
                                          _tokshowcontroller.currentRoom.value!
                                                  .owner!.id !=
                                              FirebaseAuth
                                                  .instance.currentUser!.uid)
                                        Container(
                                          margin: EdgeInsets.only(
                                              top: 5.h, bottom: 15.h),
                                          child: CustomButton(
                                            text: "auction_will_start_soon".tr,
                                            textColor: Colors.grey,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.9,
                                            height: 35.h,
                                            backgroundColor: Colors.grey
                                                .withValues(alpha: 0.2),
                                            function: () {},
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              Obx(() => !isKeyboardVisible &&
                                      _tokshowcontroller
                                              .currentRoom.value!.pinned !=
                                          null &&
                                      _tokshowcontroller.currentRoom.value!
                                              .activeauction ==
                                          null
                                  ? pinnedProductWidget()
                                  : Container(
                                      height: 0,
                                    )),
                              if (_tokshowcontroller
                                          .currentRoom.value?.owner?.id ==
                                      authController.currentuser?.id &&
                                  _tokshowcontroller
                                          .currentRoom.value!.started ==
                                      false &&
                                  !_tokshowcontroller.checkDateGreaterthaNow(
                                      _tokshowcontroller.currentRoom.value))
                                Container(
                                  margin: EdgeInsets.only(bottom: 10, top: 15),
                                  child: CustomButton(
                                    width: MediaQuery.of(context).size.width *
                                        0.90,
                                    text: "start_show".tr,
                                    function: () {
                                      showConfirmationDialog(
                                          context, "sure_want_to_start_show".tr,
                                          function: () {
                                        Get.back();
                                        _tokshowcontroller.getToken(context);
                                      });
                                    },
                                    backgroundColor: Colors.white,
                                    textColor: Colors.black,
                                    fontSize: 18.sp,
                                  ),
                                ),
                            ],
                          )),
                      if (!isKeyboardVisible &&
                          _tokshowcontroller.currentRoom.value!.started ==
                              false &&
                          !_tokshowcontroller.checkDateGreaterthaNow(
                              _tokshowcontroller.currentRoom.value!))
                        Center(
                          child: Container(
                            padding: EdgeInsets.all(12),
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Show Start Time
                                Text(
                                  "show_starts_at".trParams({
                                    "time": DateFormat('hh:mm a').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            _tokshowcontroller
                                                    .currentRoom.value!.date ??
                                                0))
                                  }),
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Countdown Timer
                                Obx(() => Text(
                                      _tokshowcontroller.remainingTime.value,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                                // Buttons
                                Container(
                                  padding: EdgeInsets.all(12),
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 10),
                                      CustomButton(
                                        text: "share_show".tr,
                                        function: () {
                                          _tokshowcontroller.shareTokshow();
                                        },
                                        backgroundColor: Colors.amber,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        textColor: Colors.black,
                                        iconData: Icons.share,
                                      ),
                                      const SizedBox(height: 10),
                                      if (_tokshowcontroller
                                              .currentRoom.value?.owner?.id !=
                                          authController.currentuser?.id)
                                        _tokshowcontroller.currentRoom.value
                                                    ?.invitedhostIds
                                                    ?.indexWhere((element) =>
                                                        element ==
                                                        authController
                                                            .currentuser!.id) !=
                                                -1
                                            ? Text("saved".tr)
                                            : CustomButton(
                                                text: "save_and_notify_me".tr,
                                                function: () {
                                                  _tokshowcontroller
                                                      .addRemoveToBeNotified(
                                                          _tokshowcontroller
                                                              .currentRoom
                                                              .value!);
                                                },
                                                backgroundColor: Colors.white,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                textColor: Colors.black,
                                                iconData: Icons.save,
                                              ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
          }),
        ),
      ),
    );
  }

  String buildTrParams() {
    return "owner_bids_button".trParams({
      'bids_count': _tokshowcontroller.currentRoom.value!.activeauction == null
          ? "0"
          : _tokshowcontroller.currentRoom.value!.activeauction!.bids!.length
              .toString(),
      "highest_bid": priceHtmlFormat(auctionController
          .getHighestBid(_tokshowcontroller.currentRoom.value!.activeauction))
    });
  }

  Widget _live_view(BuildContext context) {
    if (_tokshowcontroller.currentRoom.value!.started == true) {
      if (!_tokshowcontroller.hostIn()) {
        return Positioned.fill(
          child: Stack(
            children: [
              Positioned.fill(child: placeHolder()),
              Positioned.fill(
                child: Center(
                  child: Text(
                    'waiting_host'.tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
      // return SizedBox.shrink();
    }
    if (_tokshowcontroller.initializingRoom.isTrue) {
      return Center(
          child: CircularProgressIndicator(
        color: Colors.white,
      ));
    }
    final room = _tokshowcontroller.lkRoom.value;
    if (_tokshowcontroller.currentRoom.value!.owner?.id ==
        authController.currentuser?.id) {
      final local = room.localParticipant;
      if (local != null && local.videoTrackPublications.isNotEmpty) {
        final track = local.videoTrackPublications.first.track;
        if (track is VideoTrack) {
          return VideoTrackRenderer(
            track as VideoTrack,
            fit: VideoViewFit.cover,
          );
        }
      }
      return const Center(child: Text("Camera not started"));
    }
    if (room.remoteParticipants.isNotEmpty) {
      final remote = room.remoteParticipants.values.first;
      if (remote.videoTrackPublications.isNotEmpty) {
        final track = remote.videoTrackPublications.first.track;
        if (track is VideoTrack) {
          return VideoTrackRenderer(
            track as VideoTrack,
            fit: VideoViewFit.cover,
          );
        }
      }
      return const Center(child: Text("Waiting for host video..."));
    }

    return const Center(child: Text("No participants yet"));
  }

  pinnedProductWidget() {
    return Container(
      padding: EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              productController.currentProduct.value =
                  _tokshowcontroller.currentRoom.value!.pinned!;
              productController.currentProduct.value?.ownerId =
                  _tokshowcontroller.currentRoom.value!.owner!;
              Get.to(() => ProductDetails(
                  product: _tokshowcontroller.currentRoom.value!.pinned!));
            },
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _tokshowcontroller
                          .currentRoom.value!.pinned!.images!.isEmpty
                      ? Image.asset(
                          "assets/images/image_placeholder.jpg",
                          fit: BoxFit.cover,
                          width: 60,
                          height: 60,
                        )
                      : CachedNetworkImage(
                          imageUrl: _tokshowcontroller
                              .currentRoom.value!.pinned!.images!.first,
                          fit: BoxFit.cover,
                          width: 60,
                          height: 60,
                          placeholder: (context, url) => Center(
                            child:
                                CircularProgressIndicator(), // Placeholder while loading
                          ),
                          errorWidget: (context, url, error) => Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Icon(
                              Icons.person,
                              color: Colors.grey,
                            ),
                          ), // Error icon
                        ),
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _tokshowcontroller.currentRoom.value!.pinned!.name!
                              .capitalizeFirst ??
                          "",
                      style: Theme.of(context).textTheme.headlineSmall,
                      maxLines: 1,
                    ),
                    if (_tokshowcontroller
                            .currentRoom.value!.pinned!.productCategory !=
                        null)
                      Text(
                        _tokshowcontroller.currentRoom.value!.pinned!
                                .productCategory!.name!.capitalizeFirst ??
                            "",
                        style: TextStyle(fontSize: 12),
                      ),
                    Text(
                      "${priceHtmlFormat(shippingController.shippingEstimate["amount"])} Shipping + tax",
                      style: TextStyle(
                          fontSize: 12.sp, fontWeight: FontWeight.normal),
                    )
                  ],
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              if (_tokshowcontroller.currentRoom.value!.owner?.id !=
                  FirebaseAuth.instance.currentUser?.uid) return;
              socketController.pinAuction(null, context,
                  product: _tokshowcontroller.currentRoom.value!.pinned,
                  tokshow: _tokshowcontroller.currentRoom.value);
            },
            child: Column(
              children: [
                Text(
                  priceHtmlFormat(
                      _tokshowcontroller.currentRoom.value!.pinned!.price),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Row(
                  children: [
                    Text("Pinned"),
                    SvgPicture.asset(
                      "assets/icons/pin.svg",
                      color: Colors.white,
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget placeHolder() {
    if ((_tokshowcontroller.currentRoom.value!.previewVideos != null &&
            _tokshowcontroller.currentRoom.value!.previewVideos!.isNotEmpty &&
            _tokshowcontroller.currentRoom.value!.started == false) &&
        !_tokshowcontroller
            .checkDateGreaterthaNow(_tokshowcontroller.currentRoom.value)) {
      return VideoPlayerWidget(
        customImage: CustomImage(
            path: _tokshowcontroller.currentRoom.value!.previewVideos!,
            imgType: ImageType.network),
      );
    }
    if (_tokshowcontroller.currentRoom.value!.started == false &&
        _tokshowcontroller.currentRoom.value!.previewVideos!.isEmpty &&
        _tokshowcontroller.currentRoom.value!.thumbnail != null &&
        _tokshowcontroller.currentRoom.value!.thumbnail!.isNotEmpty) {
      return CachedNetworkImage(
          imageUrl: _tokshowcontroller.currentRoom.value!.thumbnail!,
          fit: BoxFit.cover);
    }
    return Image.asset(
      "assets/images/image_placeholder.jpg",
      fit: BoxFit.cover,
    );
  }
}

checkOwner() =>
    FirebaseAuth.instance.currentUser!.uid ==
    Get.find<TokShowController>().currentRoom.value?.owner?.id;
Widget _videoView(view) {
  return Container(child: view);
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
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Center(
                    child: Text(
                      'to_purchase_live_tokshows_need_payment'.tr,
                      style: TextStyle(fontSize: 18.sp),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'welcome_to_tokshow_in_order_to_bid_on_auctions'.tr,
                    style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {
                      showCustomBottomSheet(context, 'payments_shipping'.tr);
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
                          'add_info'.tr,
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
