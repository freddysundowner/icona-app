import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/pages/live/widgets/tokshop_list_grid.dart';

import '../../controllers/product_controller.dart';
import '../../controllers/user_controller.dart';
import '../../main.dart';
import '../../utils/functions.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/expandable_text.dart';
import '../../widgets/search_layout.dart';
import '../chats/messages.dart';
import '../products_grid.dart';
import 'edit_profile.dart';
import 'followers_following_page.dart';
import 'widgets/user_reviews.dart';

class MyProfilePage extends StatelessWidget {
  MyProfilePage({super.key}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      productController.myIventory.clear();
      productController.getProductsByUserId(
          userId: FirebaseAuth.instance.currentUser!.uid ?? "");
      productController.getAllroducts(
          status: 'active',
          type: "all",
          userid: FirebaseAuth.instance.currentUser!.uid);

      _userController.getUserReviews(FirebaseAuth.instance.currentUser!.uid);
    });
  }
  final UserController _userController = Get.find<UserController>();
  ProductController productController = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 150,
                  automaticallyImplyLeading: false,
                  floating: false,
                  leading: null,
                  pinned: true,
                  flexibleSpace: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      double top = constraints.biggest.height;
                      bool isCollapsed = top <=
                          kToolbarHeight + MediaQuery.of(context).padding.top;

                      return FlexibleSpaceBar(
                        titlePadding:
                            EdgeInsets.only(left: 16, bottom: 8, top: 10),
                        title: isCollapsed
                            ? Obx(
                                () => Row(
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          Get.back();
                                        },
                                        icon: Icon(Icons.arrow_back_ios)),
                                    if (authController
                                                .currentuser!.profilePhoto !=
                                            null &&
                                        authController.currentuser!
                                            .profilePhoto!.isNotEmpty)
                                      CircleAvatar(
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                          authController
                                              .currentuser!.profilePhoto!,
                                        ),
                                      ),
                                    const SizedBox(width: 8),
                                    Text(
                                      authController
                                              .usermodel.value!.firstName ??
                                          "",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Spacer(),
                                    IconButton(
                                        onPressed: () {
                                          _userController.shareProfile(
                                              _userController
                                                  .currentProfile.value);
                                        },
                                        icon: Icon(Icons.share)),
                                  ],
                                ),
                              )
                            : null,
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            Stack(
                              children: [
                                Obx(
                                  () => Container(
                                    height: 120.h,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Colors.white.withOpacity(0.2),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      image: authController.usermodel.value!
                                                      .coverPhoto !=
                                                  null &&
                                              authController.usermodel.value!
                                                      .coverPhoto !=
                                                  ""
                                          ? DecorationImage(
                                              image: NetworkImage(
                                                authController.usermodel.value!
                                                        .coverPhoto ??
                                                    '',
                                              ),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                                // Overlay Container
                                Container(
                                  height: 120.h,
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.black.withOpacity(
                                      0.4), // Adjust overlay color and opacity
                                ),
                              ],
                            ),
                            if (_userController
                                .coverPhotoLocalPath.value.isNotEmpty)
                              Image.memory(
                                File(_userController.coverPhotoLocalPath.value)
                                    .readAsBytesSync(),
                                fit: BoxFit.cover,
                                height: 120.h,
                                width: MediaQuery.of(context).size.width,
                              ),
                            Positioned(
                              bottom: 20,
                              left: 16,
                              child: _buildProfileInfo(theme),
                            ),
                            Positioned(
                              top: 10,
                              left: 8,
                              right:
                                  8, // Add right constraint to ensure proper layout
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      Get.back();
                                    },
                                    icon: Icon(Icons.arrow_back_ios),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          _userController.shareProfile(
                                              _userController
                                                  .currentProfile.value);
                                        },
                                        icon: Icon(Icons.share),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Obx(
                      () => Column(
                        children: [
                          const SizedBox(height: 10),
                          if (_userController.currentProfile.value.bio !=
                                  null &&
                              _userController
                                  .currentProfile.value.bio!.isNotEmpty)
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: ExpandableText(
                                content:
                                    _userController.currentProfile.value.bio ??
                                        "",
                                maxLines: 2,
                              ),
                            ),
                          if (_userController.currentProfile.value.bio !=
                                  null &&
                              _userController
                                  .currentProfile.value.bio!.isNotEmpty)
                            const SizedBox(height: 10),
                          _buildActionButtons(theme),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyTabBarDelegate(
                    TabBar(
                      isScrollable: true,
                      indicatorColor: theme.colorScheme.primary,
                      labelColor: theme.textTheme.bodyLarge!.color,
                      unselectedLabelColor: theme.textTheme.bodyMedium!.color,
                      labelPadding: EdgeInsets.symmetric(horizontal: 10),
                      padding: EdgeInsets.zero,
                      tabAlignment: TabAlignment.start,
                      labelStyle: theme.textTheme.titleMedium,
                      onTap: (i) {
                        if (i == 2) {
                          _userController.getUserReviews(
                              FirebaseAuth.instance.currentUser!.uid);
                        }
                        if (i == 1) {
                          tokShowController.getTokshows(
                              userid: FirebaseAuth.instance.currentUser!.uid,
                              type: 'myshows',
                              status: "active");
                        }
                      },
                      tabs: [
                        Tab(text: 'shop'.tr),
                        Tab(text: 'shows'.tr),
                        Tab(text: 'reviews'.tr),
                      ],
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyHeaderDelegate(
                    child: SearchLayout(
                      function: (text) => {
                        productController.getAllroducts(
                          title: text,
                          type: 'myinventory',
                        )
                      },
                    ),
                  ),
                ),
              ];
            },
            body: Container(
              margin: EdgeInsets.only(top: 10),
              child: TabBarView(
                children: [
                  ProductGrid(from: "myprofile"),
                  TokshopListGrid(
                      rooms: tokShowController.mytokshows,
                      scrollController: tokShowController
                          .activeinventoryroomsScrollController),
                  UserReviews(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                ),
                child: ClipOval(
                  child: Obx(
                    () => CachedNetworkImage(
                      imageUrl: authController.currentuser!.profilePhoto!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.person, size: 30),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.pause, size: 18, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Obx(
                    () => Text(
                      authController.usermodel.value!.firstName ?? "",
                      style: theme.textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.verified,
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
                ],
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
                        style: theme.textTheme.bodySmall!
                            .copyWith(color: Colors.white60),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
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
                        style: theme.textTheme.bodySmall!
                            .copyWith(color: Colors.white60),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          CustomButton(
            function: () {
              Get.to(AllChatsPage());
            },
            text: 'messages'.tr,
            backgroundColor: theme.colorScheme.onSurface,
            height: 40,
            iconData: Icons.message,
            iconColor: theme.colorScheme.surface,
            textColor: theme.colorScheme.surface,
          ),
          Spacer(),
          CustomButton(
            function: () {
              Get.to(() => EditProfile());
            },
            text: 'edit_profile'.tr,
            backgroundColor: Colors.transparent,
            height: 40,
            borderColor: Colors.grey.withValues(alpha: 0.2),
            iconData: Icons.card_giftcard_outlined,
            iconColor: Colors.white,
          ),
        ],
      ),
    );
  }
}

// Sticky Header for ShopHeader
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyHeaderDelegate({required this.child});

  @override
  double get minExtent => child is PreferredSizeWidget
      ? (child as PreferredSizeWidget).preferredSize.height
      : 56;

  @override
  double get maxExtent => minExtent;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      elevation: 4,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

// Sticky TabBar Delegate
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _StickyTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      elevation: 4,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
