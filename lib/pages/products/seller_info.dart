import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/product_controller.dart';
import 'package:tokshop/main.dart';
import 'package:tokshop/pages/profile/widgets/review_card.dart';

import '../../controllers/chat_controller.dart';
import '../../controllers/user_controller.dart';
import '../../utils/functions.dart';
import '../../widgets/custom_button.dart';
import '../chats/chat_room_page.dart';
import '../chats/messages.dart';
import '../inventory/widgets/product_card.dart';
import '../profile/edit_profile.dart';
import '../profile/followers_following_page.dart';
import '../profile/view_profile.dart';
import '../profile/widgets/user_metrics_card.dart';

class SellerInfo extends StatelessWidget {
  String user;
  SellerInfo({super.key, required this.user});
  final ProductController productController = Get.find<ProductController>();
  final UserController _userController = Get.find<UserController>();
  final ChatController _chatController = Get.find<ChatController>();

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return _userController.profileLoading.isTrue
        ? Center(child: CircularProgressIndicator())
        : Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Center(
                child: CachedNetworkImage(
                  imageUrl:
                      _userController.currentProfile.value.profilePhoto ?? "",
                  imageBuilder: (context, imageProvider) => Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.cover),
                    ),
                  ),
                  placeholder: (context, url) => Container(
                      width: 20,
                      height: 20,
                      child: const CircularProgressIndicator()),
                  errorWidget: (context, url, error) => Image.asset(
                    "assets/icons/profile_placeholder.png",
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                _userController.currentProfile.value.firstName!,
                style: theme.textTheme.titleSmall,
              ),
              UserMetricsCard(
                theme: theme,
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      _userController.getUserFollowing(
                          _userController.currentProfile.value.id!);
                      Get.to(FollowersFollowingPage("Following"));
                    },
                    child: Obx(
                      () => Text(
                        '${getShortForm(_userController.currentProfile.value.following.length.toDouble(), decimal: 0)} ${'following'.tr}'
                            .tr,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontSize: 11.sp),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    "|",
                    style:
                        theme.textTheme.titleSmall?.copyWith(fontSize: 11.sp),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  InkWell(
                    onTap: () {
                      _userController.getUserFollowers(
                          _userController.currentProfile.value.id!);
                      Get.to(FollowersFollowingPage("Followers"));
                    },
                    child: Obx(
                      () => Text(
                        '${getShortForm(_userController.currentProfile.value.followers.length.toDouble(), decimal: 0)} ${'followers'.tr}'
                            .tr,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontSize: 11.sp),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Obx(
                    () => authController.currentuser!.id ==
                            FirebaseAuth.instance.currentUser!.uid
                        ? CustomButton(
                            function: () {
                              Get.to(() => EditProfile());
                            },
                            text: 'edit_profile'.tr,
                            backgroundColor: theme.colorScheme.onSurface,
                            height: 40,
                            borderColor: Colors.grey.withValues(alpha: 0.2),
                            textColor: theme.colorScheme.surface,
                            iconData: Icons.card_giftcard_outlined,
                            iconColor: theme.colorScheme.surface,
                          )
                        : CustomButton(
                            function: () {
                              _userController.followUfollow();
                            },
                            text: _userController.currentProfile.value.followers
                                        .indexWhere((element) =>
                                            element.id ==
                                            FirebaseAuth
                                                .instance.currentUser!.uid) !=
                                    -1
                                ? 'unfollow'.tr
                                : 'follow'.tr,
                            backgroundColor: theme.colorScheme.onSurface,
                            height: 35,
                            textColor: theme.colorScheme.surface,
                            fontSize: 12,
                          ),
                  ),
                  Spacer(),
                  if (authController.currentuser!.id ==
                      FirebaseAuth.instance.currentUser!.uid)
                    CustomButton(
                      function: () {
                        Get.to(AllChatsPage());
                      },
                      text: 'messages'.tr,
                      backgroundColor: Colors.grey.withValues(alpha: 0.2),
                      height: 40,
                      iconData: Icons.message,
                      iconColor: Colors.white,
                    ),
                  if (authController.currentuser!.id !=
                      FirebaseAuth.instance.currentUser!.uid)
                    CustomButton(
                      function: () {
                        _chatController.currentChat.value = [];
                        _chatController.currentChatId.value = "";
                        _chatController.getPreviousChat(
                            _userController.currentProfile.value);
                        Get.to(
                            ChatRoomPage(_userController.currentProfile.value));
                      },
                      text: 'message'.tr,
                      backgroundColor: Colors.transparent,
                      height: 35,
                      borderColor: Colors.grey.withValues(alpha: 0.2),
                      iconData: Icons.message,
                      iconColor: Colors.white,
                      fontSize: 12,
                    ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'seller_feedback'.tr,
                        style: theme.textTheme.titleLarge,
                      ),
                      Spacer(),
                      InkWell(
                        onTap: () {
                          _userController.viewprofileactivetab.value = 2;
                          Get.to(() => ViewProfile(user: user));
                        },
                        child: Text(
                          'view_all'.tr,
                          style: theme.textTheme.titleSmall?.copyWith(
                              fontSize: 11.sp,
                              color: theme.colorScheme.onSurface),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Divider(
                    color: theme.dividerColor,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  _userController.curentUserReview.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(child: Text("no_ratings_yet".tr)),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Obx(
                            () => Wrap(
                              spacing: 0,
                              children: List.generate(
                                _userController.curentUserReview.length,
                                (index) => ReviewCard(
                                    review:
                                        _userController.curentUserReview[index],
                                    theme: theme),
                              ),
                            ),
                          ),
                        )
                ],
              ),
              Row(
                children: [
                  Text(
                    'more_from_this_seller'.tr,
                    style: theme.textTheme.titleLarge,
                  ),
                  Spacer(),
                  InkWell(
                    onTap: () {
                      _userController.viewprofileactivetab.value = 0;
                      Get.to(() => ViewProfile(user: user));
                    },
                    child: Text(
                      'view_all'.tr,
                      style: theme.textTheme.titleSmall?.copyWith(
                          fontSize: 11.sp, color: theme.colorScheme.onSurface),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 220, // Adjust height as needed
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: productController.myIventory.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.only(right: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: AspectRatio(
                                aspectRatio: 0.7,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: productController
                                          .myIventory[index].images!.isEmpty
                                      ? Image.asset(
                                          "assets/images/image_placeholder.jpg",
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        )
                                      : CachedNetworkImage(
                                          imageUrl: productController
                                              .myIventory[index].images!.first,
                                          fit: BoxFit.cover,
                                          width: 10),
                                ),
                              ),
                            ),
                            ...buildProductCardContent(
                                productController.myIventory[index],
                                theme,
                                false,
                                titleSize: 16.sp)
                          ],
                        ),
                      );
                    }),
              ),
              SizedBox(
                height: 10,
              ),
              CustomButton(
                text: "view_profile".tr,
                function: () {
                  Get.to(() => ViewProfile(user: user));
                },
                width: MediaQuery.of(context).size.width * 0.9,
                backgroundColor: theme.colorScheme.onSecondaryContainer,
                fontSize: 12.sp,
              ),
              SizedBox(
                height: 10,
              ),
            ],
          );
  }
}
