import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tokshop/controllers/auction_controller.dart';
import 'package:tokshop/controllers/socket_controller.dart';
import 'package:tokshop/controllers/user_controller.dart';
import 'package:tokshop/models/category.dart';
import 'package:tokshop/pages/authetication/welcome_screen.dart';
import 'package:tokshop/pages/homescreen.dart';
import 'package:tokshop/pages/live/live_tokshows.dart';
import 'package:video_player/video_player.dart';

import '../main.dart';
import '../models/tokshow.dart';
import '../models/user.dart';
import '../services/dynamic_link_services.dart';
import '../services/product_api.dart';
import '../services/room_api.dart';
import '../services/user_api.dart';
import '../utils/utils.dart';
import '../widgets/loadig_page.dart';
import 'auth_controller.dart';
import 'chat_controller.dart';

class TokShowController extends FullLifeCycleController
    with GetTickerProviderStateMixin {
  RtcEngine? engine;
  FirebaseFirestore db = FirebaseFirestore.instance;
  RxList<Tokshow> mymanagedtokshows = RxList([]);
  RxList<Tokshow> mytokshows = RxList([]);
  RxList<int> activeUsers = RxList([]);
  var manage = false.obs;
  var onChatPage = false.obs;
  var currentTokshowIndexSwiper = 0.obs;
  var tabIndex = 0.obs;
  var roomPageInitialPage = 1.obs;
  var custombid = 0.obs;
  late PageController pageController;
  var onTokShowChatPage = false.obs;
  var inAppProducts = [].obs;
  dynamic videoPlayerController;

  dynamic chewieController;
  var initializingRoom = false.obs;
  var isReadyPreview = false.obs;
  var videoPlaying = false.obs;
  var expandableFabOpen = false.obs;
  late AnimationController expandableFabAnimationController;
  Rxn<TabController> tabController = Rxn(null);

  var hideProduct = false.obs;
  var currentProfile = "".obs;
  var profileLoading = false.obs;
  var isLoading = false.obs;
  var isSwitched = false.obs;
  var offchats = false.obs;
  var isCurrentRoomLoading = false.obs;
  RxList<Tokshow> allroomsList = RxList([]);
  RxList<Tokshow> channelRoomsList = RxList([]);
  RxList<Tokshow> myUpcomingEvents = RxList([]);
  RxList<String> repeatRoom =
      RxList(['no repeat', 'hourly', 'daily', 'weekly', 'monnthly']);
  var myChannelRoomList = [].obs;
  Rxn<Tokshow> currentRoom = Rxn<Tokshow>(null);
  Rxn<ProductCategory> category = Rxn<ProductCategory>(null);
  var currentRecordedRoom = Tokshow().obs;
  var isCurrentRecordedRoomLoading = false.obs;
  var isCreatingRoom = false.obs;
  var newRoom = Tokshow().obs;
  var toInviteUsers = [].obs;
  var audioMuted = false.obs;
  var shareSheetLoading = false.obs;
  var shareLinkLoading = false.obs;

  Rxn<Timer> timer = Rxn<Timer>(null);
  Rx<String> remainingTime = "".obs;
  var newRoomTitle = " ".obs;
  Rxn<DateTime> eventDate = Rxn<DateTime>(DateTime.now());
  Rxn<TimeOfDay> timeOfDay = Rxn<TimeOfDay>(null);
  var resourceIdV = "".obs;
  var resourceSid = "".obs;
  var recordinguid = "".obs;
  var errorroomtitle = "".obs;
  var errorRoomDiscount = "".obs;
  var visibility = "public".obs;
  var selectedEvents = "all".obs;
  var allowrecording = false.obs;
  var agoraToken = "".obs;
  var users = [].obs;
  var commentFieldFocus = false.obs;
  var roomChatViewInFocus = false.obs;

  var roomShopId = "".obs;
  var roomProductImages = [].obs;

  var userJoinedRoom = false.obs;
  var isSearching = false.obs;
  var roomsPageNumber = 0.obs;
  final allinventoryroomsScrollController = ScrollController();
  final inactiveinventoryroomsScrollController = ScrollController();
  final activeinventoryroomsScrollController = ScrollController();
  final roomsScrollController = ScrollController();

  var roomPickedImages = [].obs;
  var peopleTalkingInRoom = 0.obs;
  var userBeingMoved = "".obs;

  TextEditingController roomTitleController = TextEditingController();
  TextEditingController eventTitleController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController eventDateController = TextEditingController();
  TextEditingController roomCategoryController = TextEditingController();
  TextEditingController roomRepeatController = TextEditingController();
  TextEditingController eventDescriptiion = TextEditingController();
  RxString selectedRepeat = "none".obs;
  TextEditingController roomProductDiscount = TextEditingController();

  final ChatController _chatController =
      Get.put<ChatController>(ChatController());
  final UserController userController =
      Get.put<UserController>(UserController());
  final AuctionController auctionController =
      Get.put<AuctionController>(AuctionController());
  var hasMoreRooms = true.obs;
  var page = ''.obs;

  void onResumed() async {
    if (currentRoom.value!.id != null &&
        currentRoom.value!.owner!.id ==
            FirebaseAuth.instance.currentUser!.uid) {
      engine?.muteLocalVideoStream(false);
      engine?.enableLocalVideo(true);
      engine?.enableVideo();
    }
  }

  dynamic headers;
  @override
  void onClose() {
    roomsScrollController.dispose();
    disposeVideoPlayer();
    super.onClose();
  }

  @override
  void onInit() {
    tabController.value = TabController(
      initialIndex: tabIndex.value,
      length: 3,
      vsync: this,
    );
    super.onInit();

    // Listen for scroll near the bottom
    roomsScrollController.addListener(() {
      if (roomsScrollController.position.pixels >=
              roomsScrollController.position.maxScrollExtent - 200 &&
          !isLoading.value &&
          hasMoreRooms.value) {
        // Move to next page
        roomsPageNumber.value++;
        // Fetch next batch
        getTokshows(page: roomsPageNumber.value);
      }
    });

    // Listen for scroll near the bottom
    allinventoryroomsScrollController.addListener(() {
      if (allinventoryroomsScrollController.position.pixels >=
              allinventoryroomsScrollController.position.maxScrollExtent -
                  200 &&
          !isLoading.value &&
          hasMoreRooms.value) {
        // Move to next page
        roomsPageNumber.value++;
        getTokshows(
            page: roomsPageNumber.value,
            userid: FirebaseAuth.instance.currentUser!.uid,
            type: "mymanagedtokshows",
            status: "");
      }
    });
    activeinventoryroomsScrollController.addListener(() {
      if (activeinventoryroomsScrollController.position.pixels >=
              activeinventoryroomsScrollController.position.maxScrollExtent -
                  200 &&
          !isLoading.value &&
          hasMoreRooms.value) {
        // Move to next page
        roomsPageNumber.value++;
        getTokshows(
            page: roomsPageNumber.value,
            userid: FirebaseAuth.instance.currentUser!.uid,
            type: "mymanagedtokshows",
            status: "active");
      }
    });
    inactiveinventoryroomsScrollController.addListener(() {
      if (inactiveinventoryroomsScrollController.position.pixels >=
              inactiveinventoryroomsScrollController.position.maxScrollExtent -
                  200 &&
          !isLoading.value &&
          hasMoreRooms.value) {
        // Move to next page
        roomsPageNumber.value++;
        getTokshows(
            page: roomsPageNumber.value,
            userid: FirebaseAuth.instance.currentUser!.uid,
            type: "mymanagedtokshows",
            status: "inactive");
      }
    });
  }

  Future<void> startRtmpStream() async {
    await engine?.startRtmpStreamWithoutTranscoding(
        "rtmp://a.rtmp.youtube.com/live2/ykfj-m892-g1t0-cfvs-8jtg");
    // setState(() {
    //   isStreaming = true;
    // });
  }

  Future<void> initAgora() async {
    print("🔄 Initializing Agora...");
    initializingRoom.value = true;
    try {
      if (currentRoom.value!.owner?.id == authController.usermodel.value!.id) {
        await [Permission.microphone, Permission.camera].request();
      }

      if (engine != null) {
        initializingRoom.value = false;
        print("⚠️ Agora engine already exists, cleaning up...");
        // await leaveAgoraEngine();
      } else {
        initializingRoom.value = false;
        engine = createAgoraRtcEngine();
      }
      await engine?.initialize(RtcEngineContext(
        appId: agoraAppID.trim(),
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ));

      print("✅ Agora Engine Initialized");

      if (currentRoom.value!.owner?.id == authController.usermodel.value!.id) {
        await engine?.startPreview();
        await engine?.enableVideo();
      } else {
        await engine?.enableVideo();
        await engine?.startPreview();
      }
      await engine?.enableAudio();
      await engine?.setDefaultAudioRouteToSpeakerphone(true);
      await engine?.setVideoEncoderConfiguration(
        const VideoEncoderConfiguration(
          dimensions: VideoDimensions(width: 640, height: 360),
          frameRate: 30,
          bitrate: 0,
          orientationMode: OrientationMode.orientationModeFixedPortrait,
        ),
      );

      print("✅ Video Preview Started");

      // Set Role
      if (currentRoom.value!.owner!.id == authController.usermodel.value!.id) {
        await engine?.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
        print("🎤 Role: Broadcaster");
      } else {
        await engine?.setClientRole(role: ClientRoleType.clientRoleAudience);
        print("🎧 Role: Audience");
      }

      isReadyPreview.value = true;
      await engine?.adjustRecordingSignalVolume(100);

      // Register Event Handlers
      engine?.registerEventHandler(
        RtcEngineEventHandler(
          onRtmpStreamingStateChanged: (String url,
              RtmpStreamPublishState state, RtmpStreamPublishReason reason) {
            print("RTMP Stream State: $state, Reason: $reason, URL: $url");

            if (state == RtmpStreamPublishState.rtmpStreamPublishStateRunning) {
              print("✅ RTMP stream is LIVE on YouTube!");
            } else if (state ==
                RtmpStreamPublishState.rtmpStreamPublishStateFailure) {
              print("❌ RTMP streaming failed. Reason: $reason");
            } else if (state ==
                RtmpStreamPublishState.rtmpStreamPublishStateIdle) {
              print("⚠️ RTMP stream is idle (no connection yet)");
            }
          },
          onAudioVolumeIndication: (RtcConnection rtc,
              List<AudioVolumeInfo> speakers, int totalVolume, int i) async {
            for (var speaker in speakers) {
              if (speaker.volume! > 20) {
                writeToDbRoomActive();
              }
            }
          },
          onLocalAudioStats: (RtcConnection rtc, LocalAudioStats? stats) {},
        ),
      );

      // Ensure UID is Valid
      int agoraUid = authController.currentuser!.agorauid ?? 0;
      print("📌 Agora UID: $agoraUid");

      // Join Channel
      await engine?.joinChannel(
        token: currentRoom.value!.token,
        channelId: currentRoom.value!.id!,
        options: ChannelMediaOptions(
          clientRoleType:
              currentRoom.value!.owner!.id == authController.usermodel.value!.id
                  ? ClientRoleType.clientRoleBroadcaster
                  : ClientRoleType.clientRoleAudience,
        ),
        uid: agoraUid,
      );

      print("✅ Joined Agora Channel");

      // Ensure Audio is Enabled
      if (FirebaseAuth.instance.currentUser!.uid ==
          currentRoom.value!.owner?.id!) {
        await engine?.enableAudio();
        await engine?.muteLocalAudioStream(false);
      }
      initializingRoom.value = false;

      currentRoom.refresh();
    } catch (e) {
      initializingRoom.value = false;
      print("❌ ERROR AGORA! $e");
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if ((authController.usermodel.value!.address == null ||
                authController.usermodel.value!.defaultpaymentmethod == null) &&
            checkOwner() == false) {
          print("checkOwner() ${checkOwner()}");
          showAlert(Get.context!);
        }
      });
    }
  }

  Future<dynamic> wornUi(BuildContext context, UserModel userModel) async {
    // Show the bottom sheet
    final bottomSheet = showModalBottomSheet(
      isDismissible: false,
      context: context,
      backgroundColor: const Color(0Xff252525),
      builder: (context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/bg1.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return DraggableScrollableSheet(
                initialChildSize: 0.5,
                expand: false,
                builder: (BuildContext productContext,
                    ScrollController scrollController) {
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 0.01.sh,
                          width: 0.15.sw,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        // Example profile image widget
                        Center(
                          child: userModel.profilePhoto == null
                              ? const CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.transparent,
                                  backgroundImage: AssetImage(
                                      "assets/icons/profile_placeholder.png"))
                              : CircleAvatar(
                                  radius: 25,
                                  onBackgroundImageError: (o, s) => Image.asset(
                                      "assets/icons/profile_placeholder.png"),
                                  backgroundColor:
                                      Styles.greenTheme.withOpacity(0.50),
                                  backgroundImage:
                                      NetworkImage(userModel.profilePhoto!),
                                ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "${userModel.firstName!} ${userModel.lastName!}",
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "WON!",
                          style: TextStyle(
                            fontSize: 26.sp,
                            color: kPrimaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );

    // Start a 15-second timer to auto-dismiss the bottom sheet
    Timer(const Duration(seconds: 5), () {
      // Check if we're still able to pop (i.e., sheet hasn't been dismissed yet)
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });

    return bottomSheet;
  }

  Future<void> getTokshows({
    String limit = "15",
    String category = "",
    String status = "active",
    String text = "",
    String userid = "",
    String type = "",
    int page = 1, // <--- pass page in here
  }) async {
    // If we already know no more pages, do nothing
    if (!hasMoreRooms.value && page > 1) return;

    isLoading.value = true;
    try {
      // Make sure your RoomAPI has a way to accept "page"
      // for pagination. Adjust as needed (e.g. pass skip, offset, etc.).
      final response = await RoomAPI().getShows(
        limit: limit,
        category: category,
        userid: userid,
        status: status,
        text: text,
        page: page, // <--- or your parameter name
      );

      final List list = response["rooms"] ?? [];
      final List<Tokshow> rooms = list.map((e) => Tokshow.fromJson(e)).toList();

      // If the API returned fewer items than `limit`, probably no more data
      if (rooms.length < int.parse(limit)) {
        hasMoreRooms.value = false;
      }

      // Decide which list you're updating (allroomsList, mymanagedtokshows, etc.)
      // For example, if type == "", we handle `allroomsList`:
      if (type == "mymanagedtokshows") {
        if (page == 1) {
          mymanagedtokshows.clear();
        }
        mymanagedtokshows.addAll(rooms);
      } else if (type == "myshows") {
        if (page == 1) {
          mytokshows.clear();
        }
        mytokshows.addAll(rooms);
      } else {
        // If no special type, default to `allroomsList`
        if (category.isNotEmpty) {
          // For a specific category
          if (page == 1) channelRoomsList.clear();
          channelRoomsList.addAll(rooms);
        } else if (userid.isEmpty) {
          // The main "all rooms" feed
          if (page == 1) allroomsList.clear();
          allroomsList.addAll(rooms);
        }
      }
    } catch (e) {
      printOut("Error in getTokshows: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUserCurrentRoom() async {
    try {
      isLoading.value = true;

      var room = await RoomAPI()
          .getRoomById(Get.find<AuthController>().usermodel.value!.id!);

      if (room != null) {
        currentRoom.value = Tokshow.fromJson(room);
      }
    } finally {
      isLoading.value = false;
    }
  }

  bool isDurationOver() {
    final auction = currentRoom.value?.activeauction;
    if (auction == null) return false;

    // ✅ Prefer endTime if available
    if (auction.endTime != null) {
      return DateTime.now().isAfter(auction.endTime!);
    }

    // Fallback: calculate using startedTime + duration
    if (auction.startedTime == null || auction.startedTime == 0) return false;

    final started = DateTime.fromMillisecondsSinceEpoch(auction.startedTime!);
    final expectedEnd = started.add(Duration(seconds: auction.duration));
    return DateTime.now().isAfter(expectedEnd);
  }

  bool hostIn() => currentRoom.value!.viewers?.indexWhere(
              (element) => element.id == currentRoom.value!.owner!.id) ==
          -1
      ? false
      : true;
  bool checkDateGreaterthaNow(Tokshow? currentRoom) {
    DateTime now = DateTime.now();
    if (currentRoom!.date == null) {
      return false;
    }
    int ml = currentRoom.date!;
    DateTime date = DateTime.fromMillisecondsSinceEpoch(ml);
    var b;
    if (date.isBefore(now)) {
      b = true;
    } else {
      b = false;
    }
    refresh();
    return b;
  }

  initRoom(roomId) async {
    await fetchRoom(roomId);
    _chatController.currentChatId.value = roomId;
    _chatController.singleRoomChatStream(roomId);
    if (checkDateGreaterthaNow(currentRoom.value!)) {
      initAgora();
    }
  }

  Future<void> fetchRoom(String roomId) async {
    isCurrentRoomLoading.value = true;
    var roomResponse = await RoomAPI().getRoomById(roomId);
    if (roomResponse != null) {
      Tokshow room = Tokshow.fromJson(roomResponse);
      currentRoom.value = room;
      productController.selectedTokshow.value = room;
      tokShowController.timer.value?.cancel();
      if (!checkDateGreaterthaNow(currentRoom.value)) {
        _updateRemainingTime();
        timer.value = Timer.periodic(Duration(seconds: 1), (timer) {
          _updateRemainingTime();
        });
      }
    }
    isCurrentRoomLoading.value = false;
  }

  void _updateRemainingTime() {
    if (currentRoom.value == null || currentRoom.value?.date == null) {
      return;
    }
    final eventTime =
        DateTime.fromMillisecondsSinceEpoch(currentRoom.value?.date! ?? 0);
    final now = DateTime.now();
    final difference = eventTime.difference(now);

    if (difference.isNegative) {
      timer.value?.cancel();
      remainingTime.value = "Event Started";
    } else {
      print("difference not ${difference.isNegative}");
      final int hours = difference.inHours;
      final int minutes = difference.inMinutes % 60;
      final int seconds = difference.inSeconds % 60;
      if (hours == 0 && minutes == 0 && seconds == 0) {
        timer.value?.cancel();
        currentRoom.value?.date = null;
        Get.find<SocketController>().startShow();
      }
      if (hours > 0) {
        remainingTime.value = "$hours h $minutes m $seconds s";
      } else {
        remainingTime.value = "$minutes m $seconds s";
      }
    }
  }

  Future<void> leaveRoom({String? idRoom}) async {
    var roomId = idRoom ?? currentRoom.value!.id.toString();
    if (currentRoom.value!.id != null) {
      if (FirebaseAuth.instance.currentUser!.uid ==
          currentRoom.value!.owner!.id) {
        await RoomAPI().deleteARoom(roomId);
      }
      currentRoom.value = Tokshow();
      currentRoom.refresh();
      try {
        Get.find<ChatController>().roomChatStream.cancel();
      } catch (e) {
        printOut("error removing stream");
      }
      leaveAgoraEngine();
    }
  }

  Future<void> leaveTokshow(UserModel currentUser, Tokshow tokshow) async {
    LoadingOverlay.showLoading(Get.context!);
    Get.put(SocketController()).leaveRoom();
    try {
      if (currentRoom.value!.activeauction != null) {
        auctionController.timer?.cancel();
      }
      await leaveAgoraEngine();
      if (currentUser.id == tokshow.owner!.id) {
        Get.put(SocketController()).endRoom();
        await RoomAPI().deleteARoom(tokshow.id!);
        getTokshows();
      } else {
        await RoomAPI().removeUserFromRoom({
          "roomId": tokshow.id!,
          "users": [FirebaseAuth.instance.currentUser!.uid]
        }, tokshow.id!);
      }

      LoadingOverlay.hideLoading(Get.context!);

      currentRoom.value = Tokshow();
      currentRoom.refresh();
    } catch (e) {
      printOut(e);
      currentRoom.value = Tokshow();
      currentRoom.refresh();
    } finally {
      Get.off(() => HomeScreen());
    }
  }

  Future<void> leaveAgoraEngine() async {
    try {
      if (engine != null) {
        await engine?.leaveChannel();
        await engine?.stopPreview();
        await engine?.release(); // ✅ Fully clean up the Agora engine
        engine = null; // ✅ Reset engine instance
        print("left agora");
      }
    } catch (e) {
      printOut("agoora error $e");
    }
  }

  endRoom(String roomId) async {
    try {
      currentRoom.value = Tokshow();
      currentRoom.refresh();
      await RoomAPI().deleteARoom(roomId);
    } catch (e, s) {
      printOut("Error ending room $e $s");
    }
  }

  Future<void> joinRoom(String roomId, {String type = ""}) async {
    if (FirebaseAuth.instance.currentUser == null) {
      Get.offAll(() => const WelcomeScreen());
    } else {
      if (currentRoom.value!.id != null && currentRoom.value!.id != roomId) {
        var prevRoom = currentRoom.value!.id;
        currentRoom.value!.id = null;
        await leaveRoom(idRoom: prevRoom);
        currentRoom.value = Tokshow();
        currentRoom.refresh();
      }
      Get.back();
      if (type == "notification") {
        Get.back();
      }

      Get.to(() => LiveShowPage(
            roomId: roomId,
          ));
      await addUserToRoom(roomId);
      currentRoom.refresh();
    }
  }

  Future<void> addUserToRoom(String id) async {
    await RoomAPI().addUserrToRoom({
      "users": [FirebaseAuth.instance.currentUser!.uid]
    }, id);
    currentRoom.refresh();
  }

  Future<void> muteUnMute(mute) async {
    try {
      audioMuted.value = !mute;
      engine?.muteRemoteAudioStream(
          uid: currentRoom.value!.owner!.agorauid!, mute: !mute);
      if (checkOwner() == true) {
        engine?.muteLocalAudioStream(!mute);
      }
      Get.find<SocketController>().muteUser();
    } catch (e) {
      printOut("error to speak $e");
    }
  }

  Future<void> writeToDbRoomActive() async {
    var now = DateTime.now();
    if (currentRoom.value!.activeTime != null) {
      var lastUpdated =
          DateTime.fromMillisecondsSinceEpoch(currentRoom.value!.activeTime!);
      var duration = now.difference(lastUpdated);
      if (duration.inMinutes >= 3 || lastUpdated.isAfter(now)) {
        // Only update if 10 minutes have passed or if the stored time is incorrect (in the future)
        await updateActiveTime(now);
      }
    } else {
      await updateActiveTime(now);
    }
  }

  updateActiveTime(DateTime now) async {
    currentRoom.value!.activeTime = now.millisecondsSinceEpoch;
    if (currentRoom.value!.id != null) {
      await RoomAPI().updateRoomById({
        "activeTime": now.millisecondsSinceEpoch,
        "title": currentRoom.value!.title,
        "token": currentRoom.value!.token
      }, currentRoom.value!.id!);
    }
  }

  getUserProfile(String userId) async {
    try {
      profileLoading.value = true;
      var user = await UserAPI().getUserProfile(userId);

      if (user == null) {
        currentProfile.value = "";
      } else {
        currentProfile.value = user;
      }

      profileLoading.value = false;
    } catch (e, s) {
      printOut("Error getting user $userId profile $e $s");
    }
  }

  Future<void> addRemoveToBeNotified(Tokshow eventModel) async {
    int i = eventModel.invitedhostIds!.indexWhere(
        (element) => element == FirebaseAuth.instance.currentUser!.uid);
    if (i == -1) {
      currentRoom.value?.invitedhostIds!
          .add(authController.usermodel.value!.id!);
      GetSnackBar(
        duration: Duration(seconds: 10),
        messageText: Text(
          'noticed_when_event_start'.tr,
          style: TextStyle(color: Colors.white),
        ),
      ).show();
    } else {
      currentRoom.value?.invitedhostIds!.removeAt(i);

      GetSnackBar(
        duration: Duration(seconds: 10),
        messageText: Text(
          'not_noticed_when_event_start'.tr,
          style: TextStyle(color: Colors.white),
        ),
      ).show();
    }
    currentRoom.refresh();
    await RoomAPI().updateRoomId(
        {"invitedhostIds": eventModel.invitedhostIds}, eventModel.id!);
  }

  void _showError(BuildContext context, String messageKey) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          messageKey.tr,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  DateTime? validateShow(BuildContext context) {
    if (eventTitleController.text.isEmpty) {
      _showError(context, 'tokshow_title_is_required');
      return null;
    }

    if (timeOfDay.value == null) {
      _showError(context, 'time_is_required');
      return null;
    }

    if (eventDate.value == null) {
      eventDate.value = DateTime.now();
    }

    if (category.value == null) {
      _showError(context, 'category_is_required');
      return null;
    }

    // ✅ Build correct DateTime from eventDate + timeOfDay
    final selectedTime = timeOfDay.value!;
    final selectedDateTime = DateTime(
      eventDate.value!.year,
      eventDate.value!.month,
      eventDate.value!.day,
      selectedTime.hour, // <-- already 24h safe!
      selectedTime.minute,
    );

    final now = DateTime.now();
    if (selectedDateTime.isBefore(now.add(const Duration(minutes: 15)))) {
      _showError(context, 'date_must_be_greater_than_15_minutes');
      return null;
    }

    return selectedDateTime;
  }

  Future<void> saveShow(BuildContext context, Tokshow? tokshow) async {
    validateShow(context);
    try {
      LoadingOverlay.showLoading(context);
      // if (tokshow != null) {
      //   DateTime fullDateTime = DateTime(
      //     eventDate.value!.year,
      //     eventDate.value!.month,
      //     eventDate.value!.day,
      //     timeOfDay.value!.hour,
      //     timeOfDay.value!.minute,
      //   );
      //   int timeInMilliseconds = fullDateTime.millisecondsSinceEpoch;
      //   // check iff date is greater than now
      //   var ended = checkDateGreaterthaNow(tokshow);
      //   if (fullDateTime.isAfter(DateTime.now())) {
      //     ended = false;
      //   }
      //   await updateShow(tokshow.id!, data: {
      //     "title": eventTitleController.text,
      //     "roomType": visibility.value,
      //     "category": category.value?.id,
      //     "repeat": selectedRepeat.value,
      //     "date": timeInMilliseconds,
      //     'ended': ended
      //   });
      // } else {
      //   await createShow();
      // }
      LoadingOverlay.hideLoading(context);

      // Get.back();
      // if (tokshow != null) {
      //   Get.to(() => LiveShowPage(roomId: tokshow.id!));
      // }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'error_happened'.tr,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } finally {}
  }

  Future<void> createShow(BuildContext context) async {
    final fullDateTime = validateShow(context);
    if (fullDateTime == null) return;

    try {
      LoadingOverlay.showLoading(context);

      final timeInMilliseconds = fullDateTime.millisecondsSinceEpoch;
      final roomData = {
        "title": eventTitleController.text,
        "roomType": visibility.value.isEmpty ? "public" : visibility.value,
        "userId": Get.find<AuthController>().usermodel.value!.id,
        "category": category.value?.id,
        "activeTime": DateTime.now().millisecondsSinceEpoch,
        "status": true,
        "repeat": selectedRepeat.value,
        "date": timeInMilliseconds,
      };

      final rooms = await RoomAPI().createShow(roomData);

      currentRoom.value = Tokshow.fromJson(rooms);

      final updateData = <String, dynamic>{};

      if (productController.selectedVides.isNotEmpty) {
        final urls = await productController.uploadVideosToFirebase(
          rooms['_id'],
          path: 'shows/preview_videos/${rooms['_id']}',
        );
        if (urls.isNotEmpty) {
          updateData['preview_videos'] = urls.first;
        }
      }

      if (productController.selectedImages.isNotEmpty) {
        final urls = await productController.uploadImagesToFirebase(
          rooms['_id'],
          path: 'shows/images/${rooms['_id']}',
        );
        if (urls.isNotEmpty) {
          updateData['thumbnail'] = urls.first;
        }
      }

      await updateShow(rooms['_id'], data: updateData);

      // ✅ Hide loader before navigation
      LoadingOverlay.hideLoading(context);

      // ✅ Replace current page instead of Get.back() + Get.to()
      Get.off(() => LiveShowPage(roomId: rooms['_id']));
    } catch (e, s) {
      LoadingOverlay.hideLoading(context);
      printOut("Error creating room in controller $e $s");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'error_happened'.tr,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    } finally {
      // ✅ Reset states for next show creation
      isCreatingRoom.value = false;
      allowrecording.value = false;
      offchats.value = false;
      category.value = null;
      productController.selectedImages.clear();
      roomCategoryController.clear();
      eventDate.value = null;
      timeOfDay.value = null;
    }
  }

  updateShow(String roomId, {Map<String, dynamic>? data}) async {
    if (productController.selectedImages.isNotEmpty) {
      List<String> urls = await productController.uploadImagesToFirebase(roomId,
          path: 'shows/images/$roomId');
      if (urls.isNotEmpty) {
        data?['thumbnail'] = urls.first;
      }
    }
    if (productController.selectedVides.isNotEmpty) {
      List<String> urls = await productController.uploadVideosToFirebase(roomId,
          path: 'shows/preview_videos/$roomId');
      if (urls.isNotEmpty) {
        data?['preview_videos'] = urls.first;
      }
    }
    getTokshows();

    var r = await RoomAPI().updateRoomId(data ?? {}, roomId);
    Get.back();
  }

  void deleteEvent(String roomId) async {
    Get.defaultDialog(
        title: 'deleting'.tr,
        contentPadding: const EdgeInsets.all(10),
        content: const CircularProgressIndicator(),
        barrierDismissible: false);
    await RoomAPI().deleteARoom(roomId, destroy: true);
    mymanagedtokshows.removeAt(
        mymanagedtokshows.indexWhere((element) => element.id == roomId));
    mymanagedtokshows.refresh();
    Get.back();
  }

  // startrecordingAudio({token, String? channelname}) async {
  //   Map<String, dynamic> response = await RoomAPI().recordRoom(
  //       channelname!, token, currentRoom.value!.owner!.agorauid.toString());
  //   printOut("record response $response");
  //   if (response.containsKey("message")) {
  //     Get.snackbar('', start_recording_failed,
  //         backgroundColor: Colors.red,
  //         colorText: Colors.white,
  //         duration: const Duration(seconds: 2));
  //   } else {
  //     Tokshow roomModel = Tokshow.fromJson(response);
  //     currentRoom.value!.recordingsid = roomModel.recordingsid;
  //     currentRoom.value!.resourceId = roomModel.resourceId;
  //     currentRoom.value!.recordingUid = roomModel.recordingUid;
  //     currentRoom.value!.recordingIds = roomModel.recordingIds;
  //
  //     currentRoom.refresh();
  //
  //     Get.snackbar('', '$recoding_started...',
  //         backgroundColor: kPrimaryColor,
  //         colorText: Colors.white,
  //         duration: const Duration(seconds: 2));
  //   }
  //   return response;
  // }

  // playRecordedRoom(Recording recordingModel) async {
  //   try {
  //     isCurrentRecordedRoomLoading.value = true;
  //
  //     Get.defaultDialog(
  //         title: "$opening_recording...",
  //         contentPadding: const EdgeInsets.all(10),
  //         content: const CircularProgressIndicator(),
  //         barrierDismissible: false);
  //
  //     var recording = Recording.fromJson(
  //         await RecordingsAPI().getRecordingById(recordingModel.id));
  //     var url = audioRecordingsBaseUrl + recordingModel.fileList;
  //     print(url);
  //     await initVideoPlayer(url);
  //
  //     Get.back();
  //
  //     Tokshow room = Tokshow.fromJson(
  //         await RoomAPI().getEndedRoomById(recording.roomId!.id!));
  //
  //     currentRecordedRoom.value = room;
  //     currentRecordedRoom.value.recordedRoom = true;
  //     currentRecordedRoom.refresh();
  //
  //     // _chatController.getRecordingRoomChatById(currentRecordedRoom.value.id!);
  //   } catch (e, s) {
  //     Get.back();
  //     const GetSnackBar(
  //       messageText: Text(
  //         error_getting_recording,
  //         style: TextStyle(color: Colors.white),
  //       ),
  //       backgroundColor: kPrimaryColor,
  //     );
  //     printOut("Error playing record $e $s");
  //   } finally {
  //     isCurrentRecordedRoomLoading.value = false;
  //   }
  // }

  Future initVideoPlayer(String url) async {
    try {
      videoPlayerController = VideoPlayerController.network(url);

      if (videoPlayerController.value.isInitialized == false) {
        await videoPlayerController.initialize();
      }

      chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        autoPlay: true,
        looping: false,
        aspectRatio: 5 / 10,
        showOptions: true,
        fullScreenByDefault: true,
        showControls: true,
        showControlsOnInitialize: true,
        allowPlaybackSpeedChanging: true,
        hideControlsTimer: Duration(days: 1),
        autoInitialize: true,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );
    } catch (e, s) {
      printOut("$e $s");
    }
  }

  void playAudio() {
    chewieController.play();
    videoPlaying.value == true;
  }

  void pauseAudio() {
    chewieController.pause();
    videoPlaying.value == false;
  }

  void seek(Duration position) {
    chewieController.seekTo(position);
  }

  disposeVideoPlayer() async {
    pauseAudio();
    await videoPlayerController.dispose();
    chewieController.videoPlayerController.dispose();
    chewieController.dispose();
  }

  bool checkIfhavebid(UserModel currentUser) {
    var i = currentRoom.value?.activeauction!.bids!
        .indexWhere((element) => element.bidder.id == currentUser.id);
    return i != -1 ? true : false;
  }

  Future<void> shareTokshow() async {
    shareSheetLoading.value = true;
    String url = DynamicLinkService().generateShareLink(currentRoom.value!.id!);
    await Share.share(url);
  }

  Future<void> followCategory(ProductCategory category) async {
    if (category.followers!.indexWhere((element) =>
            element == Get.find<AuthController>().usermodel.value!.id) ==
        -1) {
      category.followers!.add(authController.currentuser!.id!);
      productController.currentCategory.value?.followers = category.followers;
      productController.currentCategory.refresh();
      category.followersCount =
          category.followersCount == null ? 0 : category.followersCount! + 1;
      await ProductPI.followCagory(
          authController.currentuser!.id!, category.id!);
    } else {
      category.followers!
          .removeWhere((element) => element == authController.currentuser!.id!);
      productController.currentCategory.value?.followers = category.followers;
      productController.currentCategory.refresh();
      category.followersCount =
          category.followersCount == null ? 0 : category.followersCount! - 1;
      await ProductPI.unfollowCagory(
          Get.find<AuthController>().usermodel.value!.id!, category.id!);
    }
  }
}
