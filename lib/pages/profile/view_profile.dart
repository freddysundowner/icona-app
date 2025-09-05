import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tokshop/pages/live/widgets/tokshop_list_grid.dart';
import 'package:tokshop/pages/profile/widgets/action_widget.dart';
import 'package:tokshop/pages/profile/widgets/user_metrics_card.dart';
import 'package:tokshop/widgets/live/no_items.dart';

import '../../controllers/product_controller.dart';
import '../../controllers/user_controller.dart';
import '../../main.dart';
import '../../utils/functions.dart';
import '../../widgets/expandable_text.dart';
import '../../widgets/search_layout.dart';
import '../products_grid.dart';
import 'followers_following_page.dart';
import 'widgets/user_actions.dart';
import 'widgets/user_reviews.dart';

class ViewProfile extends StatelessWidget {
  String user;
  ViewProfile({super.key, required this.user}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _userController.getUserProfile(user);

      productController.myIventory.clear();
      productController.getProductsByUserId(userId: user);

      _userController.getUserReviews(user);
      tokShowController.getTokshows(
          limit: '15', status: 'active', userid: user);
    });
  }
  final UserController _userController = Get.find<UserController>();
  ProductController productController = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      initialIndex: _userController.viewprofileactivetab.value,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                automaticallyImplyLeading: false,
                expandedHeight: 150,
                floating: false,
                pinned: true,
                flexibleSpace: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
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
                                        print("back");
                                        Get.back();
                                      },
                                      icon: Icon(Icons.arrow_back_ios)),
                                  CircleAvatar(
                                    backgroundImage: CachedNetworkImageProvider(
                                      _userController
                                          .currentProfile.value.profilePhoto!,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    authController.usermodel.value!.firstName ??
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
                                  IconButton(
                                      onPressed: () {
                                        userActionSheet(context,
                                            user: _userController
                                                .currentProfile.value);
                                      },
                                      icon: Icon(Icons.more_horiz)),
                                ],
                              ),
                            )
                          : null,
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            'assets/images/image_placeholder.jpg',
                            fit: BoxFit.cover,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.8),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            left: 16,
                            child: _buildProfileInfo(theme),
                          ),
                          Positioned(
                            left: 8,
                            right:
                                8, // Add right constraint to ensure proper layout
                            child: SafeArea(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      print("gsdg");
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
                                      IconButton(
                                        onPressed: () {
                                          userActionSheet(context,
                                              user: _userController
                                                  .currentProfile.value);
                                        },
                                        icon: Icon(Icons.more_horiz),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
                    () => _userController.profileLoading.isTrue
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: UserMetricsCard(
                                  theme: theme,
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (_userController.currentProfile.value.bio !=
                                      null &&
                                  _userController
                                      .currentProfile.value.bio!.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: ExpandableText(
                                    content: _userController
                                            .currentProfile.value.bio ??
                                        "",
                                    maxLines: 2,
                                  ),
                                ),
                              const SizedBox(height: 10),
                              ActionWidget(),
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
                      _userController.viewprofileactivetab.value = i;
                      if (i == 2) {
                        _userController.getUserReviews(user);
                      }
                      if (i == 0) {
                        productController.getProductsByUserId(userId: user);
                      }
                      if (i == 1) {
                        tokShowController.getTokshows(
                            userid: user,
                            type: 'mymanagedtokshows',
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
                      if (_userController.viewprofileactivetab.value == 0)
                        {
                          productController.getAllroducts(
                            title: text,
                            userid: _userController.currentProfile.value.id!,
                          )
                        }
                    },
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              ProductGrid(from: "viewprofile"),
              TokshopListGrid(
                  verticalMargin: 0,
                  rooms: tokShowController.mymanagedtokshows,
                  scrollController:
                      tokShowController.activeinventoryroomsScrollController),
              userController.curentUserReview.isEmpty
                  ? NoItems(
                      content: Text(
                      "no_reviews".tr,
                    ))
                  : UserReviews()
            ],
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
                    () => _userController.profileLoading.isTrue
                        ? const Center(child: CircularProgressIndicator())
                        : _userController.currentProfile.value.profilePhoto ==
                                null
                            ? const Icon(
                                Icons.person,
                                size: 30,
                              )
                            : CachedNetworkImage(
                                imageUrl: _userController
                                    .currentProfile.value.profilePhoto!,
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
                        '${_userController.currentProfile.value.firstName} ${_userController.currentProfile.value.lastName}' ??
                            "",
                        style: theme.textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        )),
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
      shadowColor: Colors.transparent,
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
      shadowColor: Colors.transparent,
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
