import 'dart:convert';
import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tokshop/main.dart';
import 'package:tokshop/models/ShippingAddress.dart';
import 'package:tokshop/models/UserReview.dart';
import 'package:tokshop/models/order.dart';

import '../models/bank.dart';
import '../models/payout_method.dart';
import '../models/shipping.dart';
import '../models/user.dart';
import '../pages/inventory/add_edit_product_screen.dart';
import '../pages/success_page.dart';
import '../services/client.dart';
import '../services/dynamic_link_services.dart';
import '../services/end_points.dart';
import '../services/firestore_files_access_service.dart';
import '../services/local_files_access_service.dart';
import '../services/user_api.dart';
import '../utils/helpers.dart';
import '../utils/utils.dart';
import '../widgets/loadig_page.dart';
import 'auth_controller.dart';

enum SingingCharacter { bank, paypal, mobile }

class UserController extends GetxController with GetTickerProviderStateMixin {
  var currentProfile = UserModel().obs;
  var loadingFriends = false.obs;
  var profileLoading = true.obs;
  var guidelinesaccepted = false.obs;
  var updateInterests = false.obs;
  var ordersLoading = false.obs;
  var loadingReview = false.obs;
  RxList userOrders = RxList([]);
  RxList shopOrders = RxList([]);
  var userFollowersFollowing = [].obs;
  var gettingFollowers = false.obs;
  var gettingAddress = false.obs;
  RxList<ShippingAddress> myAddresses = RxList([]);
  final TextEditingController displaynameEditFormField =
      TextEditingController();
  final TextEditingController urlController = TextEditingController();
  final TextEditingController bioEditFormField = TextEditingController();
  final TextEditingController usernameEditFormField = TextEditingController();
  var userOrdersPageNumber = 1.obs;
  var loadingMoreUserOrders = false.obs;
  final userOrdersScrollController = ScrollController();
  var activityTabIndex = 0.obs;
  var viewprofileactivetab = 1.obs;
  var shopOrdersPageNumber = 1.obs;
  var loadingMoreShopOrders = false.obs;
  final shopOrdersScrollController = ScrollController();
  var userRecordings = [].obs;
  Rxn usersummary = Rxn(null);
  var userRecordingsLoading = false.obs;
  var userFollowingIndex = 0.obs;
  var viewproductsfrom = ''.obs;
  var userBeingFollowingId = "".obs;
  var profileImageLocalPath = "".obs;
  var coverPhotoLocalPath = "".obs;
  RxList tipOptions = RxList([1, 5, 10, 20, 50, 100]);
  RxList<Map<String, dynamic>> shippingcosts = RxList([
    {"free_shipping": false, "cost": 0},
    {"custom_shipping": false, "cost": 0}
  ]);
  RxMap<String, dynamic> selectedShipping = RxMap({});
  Rxn averageReviews = Rxn(1);
  Rxn selectedTip = Rxn(1);
  RxList<Shipping> shipping = RxList([]);
  RxList<UserModel> friends = RxList([]);
  RxMap wcSettigs = RxMap();
  RxMap<String, dynamic> notificationsettigs = RxMap({
    'notify_on_follow': true,
    'notify_on_message': true,
    'notify_on_order': true,
    'notify_on_live': true
  });
  RxList<UserReview> curentUserReview = RxList([]);
  Rxn<SingingCharacter> payOutOptions = Rxn(SingingCharacter.bank);
  var page = 1.obs;
  var limit = 15.obs;
  var tabIndex = 0.obs;
  var totalUsers = 0.obs;
  var ratingvalue = 0.obs;
  var ratingError = "".obs;
  TextEditingController review = TextEditingController();

  var moreUsersLoading = false.obs;
  var allUsers = [].obs;
  var friendsToInvite = [].obs;
  var searchedfriendsToInvite = [].obs;
  var searchedUsers = [].obs;
  var canreview = false.obs;
  var allUsersLoading = false.obs;
  TextEditingController searchUsersController = TextEditingController();
  final usersScrollController = ScrollController();
  Rxn<TabController> tabController = Rxn(null);
  var selectedOption = ''.obs;
  var hasMoreUsers = true.obs;
  var creatingStripeAccount = true.obs;
  var accountNumberController = TextEditingController();
  var firstNameController = TextEditingController();
  var counntryController = TextEditingController();
  var businessNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var routingNumberController = TextEditingController();
  var phoneNumberController = TextEditingController();
  var postalCodeController = TextEditingController();
  var ssnNumberController = TextEditingController();
  var bankName = TextEditingController();
  var addressController = TextEditingController();
  var state = TextEditingController();
  var city = TextEditingController();

  Rxn<Country> pickedCountry = Rxn(null);
  Rxn<DateTime> birthDateHolder = Rxn(null);

  var bankCodeController = TextEditingController();
  var countryCodeController = TextEditingController();
  var countriesToPick = ["US", "KE"];

  varlidateStripeFields() {
    if (accountNumberController.text.isEmpty) {
      return "account_number_required".tr;
    }
    if (routingNumberController.text.isEmpty) {
      return "routing_number_required".tr;
    }
    if (phoneNumberController.text.isEmpty) {
      return "phone_number_required".tr;
    }
    if (postalCodeController.text.isEmpty) {
      return "postal_code_required".tr;
    }
    if (ssnNumberController.text.isEmpty) {
      return "ssn_number_required".tr;
    }
    if (addressController.text.isEmpty) {
      return "address_required".tr;
    }
    if (firstNameController.text.isEmpty) {
      return "first_name_required".tr;
    }
  }

  Future<PayoutMethod?> getPayoutMethodByUserId(String userid) async {
    try {
      var response = await UserAPI().getPayoutMethodByUserId(userid);
      List list = response ?? [];
      authController.currentuser!.payoutMethods =
          list.map((e) => PayoutMethod.fromJson(e)).toList();
    } catch (error) {
      return null;
    }
    return null;
  }

  createStripeConnectAccount(BuildContext context) async {
    creatingStripeAccount.value = true;
    // accountNumberController.text = "000123456789";
    // addressController.text = "605 W Maude Avenue";
    // ssnNumberController.text = "0000";
    // routingNumberController.text = "110000000";
    // phoneNumberController.text = "0000000000";
    // postalCodeController.text = "12345";
    // firstNameController.text = "John";
    // businessNameController.text = "John";
    // must be over 18
    if (birthDateHolder.value == null) {
      Get.snackbar("error".tr, 'date_of_birth_required'.tr,
          backgroundColor: Colors.red);
    }
    if ((DateTime.now().year - birthDateHolder.value!.year) < 18) {
      Get.snackbar("error".tr, 'must_be_over_18'.tr,
          backgroundColor: Colors.red);
      return;
    }
    var payload = {
      "country": "US",
      "currency": "usd",
      "account_number": accountNumberController.text,
      "city": city.text,
      "state": state.text,
      "day": birthDateHolder.value!.day.toString(),
      "month": birthDateHolder.value!.month.toString(),
      "year": birthDateHolder.value!.year.toString(),
      "ssn_last_4": ssnNumberController.text,
      "line1": addressController.text,
      "line2": addressController.text,
      "postal_code": postalCodeController.text,
      "phone": phoneNumberController.text,
      "routing_number": routingNumberController.text,
      "email": authController.usermodel.value!.email!,
      'name': authController.usermodel.value!.firstName!,
      'first_name': authController.usermodel.value!.firstName!,
      'last_name': authController.usermodel.value!.firstName!,
      'account_holder_name':
          "${authController.usermodel.value!.firstName!} ${authController.usermodel.value!.lastName!}",
    };
    LoadingOverlay.showLoading(context);
    var respnse = await DbBase().databaseRequest(
        connectStripeBase + FirebaseAuth.instance.currentUser!.uid,
        DbBase().postRequestType,
        body: payload);
    LoadingOverlay.hideLoading(context);
    print(respnse);
    var payoutmethod = jsonDecode(respnse);
    print(payoutmethod);
    if (payoutmethod["success"] == false) {
      creatingStripeAccount.value = false;
      Get.snackbar("Error", payoutmethod["error"],
          snackPosition: SnackPosition.TOP, backgroundColor: Colors.red);
      return;
    }
    if (payoutmethod["success"] == true) {
      authController.usermodel.value!.bank =
          Bank.fromJson(payoutmethod["bank"]);
      authController.usermodel.refresh();
      creatingStripeAccount.value = false;
      Get.back();
      Get.snackbar(
        "",
        'successfully_connected_your_bank_account'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        messageText: Text(
          'successfully_connected_your_bank_account'.tr,
          style: TextStyle(color: Colors.white),
        ),
        colorText: Colors.white,
        margin: const EdgeInsets.all(0),
      );
    } else {
      Get.snackbar(
        "",
        "",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.black,
        duration: const Duration(seconds: 30),
        messageText: Text('error'.tr),
        colorText: Colors.white,
        margin: const EdgeInsets.all(0),
      );
    }
  }

  @override
  void onInit() {
    super.onInit();

    tabController.value = TabController(
      initialIndex: tabIndex.value,
      length: 2,
      vsync: this,
    );
    orderScrollControllerListener();
    usersScrollController.addListener(() {
      // If at the bottom, try to load more
      if (usersScrollController.position.atEdge) {
        bool isTop = usersScrollController.position.pixels == 0;
        if (!isTop) {
          // We are at the bottom
          loadMoreUsers();
        }
      }
    });
  }

  Future<void> updateShippingCost(String value) async {
    selectedOption.value = value;
    var response = await UserAPI.updateShippingCost(value);
    getUserProfile(FirebaseAuth.instance.currentUser!.uid);
  }

  Future<void> getAllUsers({String? text}) async {
    try {
      allUsersLoading.value = true;
      searchedUsers.clear();
      page.value = 1;
      hasMoreUsers.value = true;

      final response = await UserAPI().getAllUsers(
        page.value.toString(),
        title: text ?? "",
      );
      List users = response["users"];
      totalUsers.value = response["total"] ?? 0;

      // Convert JSON to user models
      final fetched = users.map((e) => UserModel.fromJson(e)).toList();
      searchedUsers.addAll(fetched);

      // If fewer than limit, no more pages
      if (fetched.length < limit.value) {
        hasMoreUsers.value = false;
      }
    } finally {
      allUsersLoading.value = false;
    }
  }

  checkCanReview(UserModel userModel) async {
    canreview.value = false;

    if (userModel.id != FirebaseAuth.instance.currentUser!.uid) {
      var response = await UserAPI().checkCanReview(userModel);
      canreview.value = response["canreview"] == true &&
          (curentUserReview.value?.indexWhere((e) =>
                      e.from!.id == FirebaseAuth.instance.currentUser!.uid) ==
                  -1 ||
              curentUserReview.value == null);
    }
  }

  searchUsersWeAreFriends(String text) async {
    if (searchUsersController.text.trim().isNotEmpty) {
      try {
        allUsersLoading.value = true;
        var results = await UserAPI.searchFriends(text);
        searchedfriendsToInvite.assignAll(results);
        allUsersLoading.value = false;
      } catch (e) {
        printOut(e.toString());
        allUsersLoading.value = false;
      }
    }
  }

  Future<void> friendsToInviteCall() async {
    try {
      allUsersLoading.value = true;

      var users = await UserAPI.friendsToInvite();
      var list = [];

      if (users != null) {
        for (var i = 0; i < users.length; i++) {
          if (users.elementAt(i)["_id"] !=
              FirebaseAuth.instance.currentUser!.uid) {
            list.add(users.elementAt(i));
          }
        }
        friendsToInvite.value = list;
      } else {
        friendsToInvite.value = [];
      }
      searchedfriendsToInvite.value = friendsToInvite;

      friendsToInvite.refresh();
      allUsersLoading.value = false;
    } catch (e) {
      printOut(e);
      allUsersLoading.value = false;
    }
  }

  Future<void> loadMoreUsers() async {
    // Don't load if already loading or if no more pages
    if (moreUsersLoading.value || !hasMoreUsers.value) return;

    moreUsersLoading.value = true;
    page.value++;

    try {
      final response = await UserAPI().getAllUsers(page.value.toString());
      List users = response["users"];

      if (users.isEmpty) {
        // No data => no more pages
        hasMoreUsers.value = false;
      } else {
        // Convert JSON to user models
        final fetched = users.map((e) => UserModel.fromJson(e)).toList();
        // Append rather than replace
        searchedUsers.addAll(fetched);

        if (fetched.length < limit.value) {
          // We got less than [limit], so no more
          hasMoreUsers.value = false;
        }
      }
    } finally {
      moreUsersLoading.value = false;
    }
  }

  void orderScrollControllerListener() {
    userOrdersScrollController.addListener(() {
      if (userOrdersScrollController.position.atEdge) {
        bool isTop = userOrdersScrollController.position.pixels == 0;
        if (isTop) {
          printOut('At the top');
        } else {
          userOrdersPageNumber.value = userOrdersPageNumber.value + 1;
          getMoreUserOrders();
        }
      }
    });

    shopOrdersScrollController.addListener(() {
      if (shopOrdersScrollController.position.atEdge) {
        bool isTop = shopOrdersScrollController.position.pixels == 0;
        if (isTop) {
          printOut('At the top');
        } else {
          shopOrdersPageNumber.value = shopOrdersPageNumber.value + 1;
        }
      }
    });
  }

  getUserProfile(String userId) async {
    try {
      profileLoading.value = true;
      var user = await UserAPI().getUserProfile(userId);
      profileLoading.value = false;
      if (user == null) {
        currentProfile.value = UserModel();
      } else {
        print(user['walletPending']);
        UserModel userFromAPi = UserModel.fromJson(user);
        userFromAPi.followers
            .removeWhere((element) => element.accountDisabled == true);
        userFromAPi.following
            .removeWhere((element) => element.accountDisabled == true);
        currentProfile.value = userFromAPi;
      }
      profileLoading.value = false;
    } catch (e) {
      print(e);
      profileLoading.value = false;
    }
  }

  Future<void> followUser(UserModel profile) async {
    int i = profile.followers.indexWhere(
      (element) => element.id == FirebaseAuth.instance.currentUser!.uid,
    );
    if (i != -1) {
      profile.followers.removeAt(i);
      profile.followersCount =
          profile.followersCount == null ? 0 : profile.followersCount! - 1;
      userFollowersFollowing.refresh();
      await UserAPI()
          .unFollowAUser(FirebaseAuth.instance.currentUser!.uid, profile.id!);
    } else {
      profile.followers
          .add(UserModel(id: FirebaseAuth.instance.currentUser!.uid));
      profile.followersCount =
          profile.followersCount == null ? 0 : profile.followersCount! + 1;
      userFollowersFollowing.refresh();
      await UserAPI()
          .followAUser(FirebaseAuth.instance.currentUser!.uid, profile.id!);
    }
    searchedUsers.refresh();
  }

  Future<void> updateUserInterests(List<String> interests) async {
    updateInterests.value = true;
    await UserAPI()
        .updateUserInterests(interests, FirebaseAuth.instance.currentUser!.uid);
    updateInterests.value = false;
  }

  Future<void> updateUser(Map<String, dynamic> data) async {
    updateInterests.value = true;
    var response = await UserAPI()
        .updateUser(data, FirebaseAuth.instance.currentUser!.uid);
    Get.find<AuthController>().usermodel.value = UserModel.fromJson(response);
    Get.find<AuthController>().usermodel.refresh();
    updateInterests.value = false;
  }

  getUserOrders() async {
    try {
      ordersLoading.value = true;
      List response =
          await UserAPI().getUserOrders(FirebaseAuth.instance.currentUser!.uid);

      userOrders.value = response.map((e) => Order.fromJson(e)).toList();

      ordersLoading.value = false;
    } catch (e, s) {
      ordersLoading.value = false;
      printOut("Error getting user orders $e $s");
    }
  }

  getMoreUserOrders() async {
    try {
      loadingMoreUserOrders.value = true;
      var orders = await UserAPI()
          .getOrders("userid=${FirebaseAuth.instance.currentUser!.uid}");
      printOut(orders);

      if (orders != null) {
        userOrders.addAll(orders.map((e) => Order.fromJson(e)).toList());
      }

      loadingMoreUserOrders.value = false;
    } catch (e, s) {
      loadingMoreUserOrders.value = false;
      printOut("Error getting user orders $e $s");
    }
  }

  getOrders([String? filterparams]) async {
    try {
      ordersLoading.value = true;
      var response = await UserAPI().getOrders(filterparams!);

      shopOrders.value =
          response["orders"].map((e) => Order.fromJson(e)).toList();

      ordersLoading.value = false;
    } catch (e, s) {
      ordersLoading.value = false;
      printOut("Error getting user orders $e $s");
    }
  }

  gettingMyAddrresses() async {
    try {
      gettingAddress.value = true;
      var resopnse = await UserAPI.getAddressesFromUserId();
      List address = resopnse;
      myAddresses.value =
          address.map((e) => ShippingAddress.fromJson(e)).toList();
      if (myAddresses.isNotEmpty) {
        authController.usermodel.value!.address = myAddresses.map(
          (e) {
            if (e.primary == true) {
              return e;
            }
          },
        ).first;
        authController.usermodel.refresh();
      } else {
        authController.usermodel.value!.address = null;
        authController.usermodel.refresh();
      }
      myAddresses.refresh();
      gettingAddress.value = false;
    } catch (e, s) {
      print(e);
      gettingAddress.value = false;
    }
  }

  getDefaultAddress() async {
    try {
      gettingAddress.value = true;
      var response = await UserAPI.getDefaultAddress();
      gettingAddress.value = false;
      authController.usermodel.value!.address =
          ShippingAddress.fromJson(response);
      authController.usermodel.refresh();
    } catch (e, s) {
      print(e);
    }
  }

  getUserFollowers(String uid) async {
    try {
      gettingFollowers.value = true;

      userFollowersFollowing.value = [];

      var response = await UserAPI().getUserFollowers(uid);

      if (response == null) {
        userFollowersFollowing.value = [];
      } else {
        List users = response;
        userFollowersFollowing.value =
            users.map((e) => UserModel.fromJson(e)).toList();
      }

      gettingFollowers.value = false;
    } catch (e, s) {
      gettingFollowers.value = false;
    }
  }

  getUserFollowing(String uid) async {
    try {
      gettingFollowers.value = true;

      userFollowersFollowing.value = [];

      var response = await UserAPI().getUserFollowing(uid);

      if (response == null) {
        userFollowersFollowing.value = [];
      } else {
        List users = response;
        userFollowersFollowing.value =
            users.map((e) => UserModel.fromJson(e)).toList();
      }

      gettingFollowers.value = false;
    } catch (e, s) {
      gettingFollowers.value = false;
    }
  }

  void getUserSummary(String shopid) async {
    var response = await UserAPI.getUserSummary(shopid);
    usersummary.value = response;
    usersummary.refresh();
  }

  addUserReview(String userId, String review, int rating, BuildContext context,
      {String reviewType = "", String reviewedItem = ""}) async {
    LoadingOverlay.showLoading(context);
    loadingReview.value = true;
    var response = await UserAPI().addUserReview(userId, review, rating,
        reviewType: reviewType, reviewedItem: reviewedItem);
    // canreview.value = false;
    LoadingOverlay.hideLoading(context);
    getUserReviews(userId);
    loadingReview.value = false;
  }

  getUserReviews(String userId) async {
    loadingReview.value = true;
    curentUserReview.clear();
    var response = await UserAPI().getUserReviews(userId);
    print(response);
    if (response["data"].length > 0) {
      List results = response["data"];
      curentUserReview.value =
          results.map((e) => UserReview.fromMap(e)).toList();

      for (var element in curentUserReview) {
        averageReviews.value = element.rating / curentUserReview.length;
      }
    }

    checkCanReview(currentProfile.value);
    curentUserReview.refresh();
    loadingReview.value = false;
  }

  Future<void> followUfollow() async {
    if (currentProfile.value.followers.indexWhere((element) =>
            element.id == FirebaseAuth.instance.currentUser!.uid) !=
        -1) {
      currentProfile.value.followers.removeWhere(
          (element) => element.id == FirebaseAuth.instance.currentUser!.uid);
      currentProfile.refresh();

      await UserAPI().unFollowAUser(
          FirebaseAuth.instance.currentUser!.uid, currentProfile.value.id!);
    } else {
      currentProfile.value.followers
          .add(UserModel(id: FirebaseAuth.instance.currentUser!.uid));
      currentProfile.refresh();
      await UserAPI().followAUser(
          FirebaseAuth.instance.currentUser!.uid, currentProfile.value.id!);
    }
  }

  Future<void> makeAddressPrimary(ShippingAddress addressData) async {
    try {
      gettingAddress.value = true;
      await UserAPI.makeAddressPrimary(
          {"primary": true, 'userId': authController.usermodel.value?.id},
          addressData.id!);

      gettingMyAddrresses();
    } catch (e, s) {
      print(e);
      gettingAddress.value = false;
    }
  }

  Future<void> deleteAddress(ShippingAddress addressData) async {
    try {
      gettingAddress.value = true;
      await UserAPI.deleteAddress(addressData.id!);
      gettingMyAddrresses();
    } catch (e, s) {
      print(e);
      gettingAddress.value = false;
    }
  }

  Future<void> approveSeller(BuildContext context) async {
    try {
      LoadingOverlay.showLoading(context);
      await UserAPI.approveSeller();
      authController.callInit();
      Get.to(() => SuccessPage(
            title: "approved_seller_info".tr,
            functionbtnone: () async {
              Get.to(() => AddEditProductScreen());
            },
            functionbtntwo: () {},
            buttonOnetext: "start_listing".tr,
            buttonTwotext: "go_live".tr,
          ));
      Get.back();
      LoadingOverlay.hideLoading(context);
    } finally {
      LoadingOverlay.hideLoading(context);
    }
  }

  populateUserFormData() {
    displaynameEditFormField.text =
        '${authController.usermodel.value!.firstName!} ${authController.usermodel.value!.lastName!}';
    usernameEditFormField.text = authController.usermodel.value!.userName!;
    bioEditFormField.text = authController.usermodel.value!.bio!;
  }

  uploadCoverPhoto() async {
    print("uploadCoverPhoto");
    try {
      Map<String, dynamic> payload = {};
      if (profileImageLocalPath.value.isNotEmpty) {
        final profilePhoto = await FirestoreFilesAccess().uploadFileToPath(
            File(profileImageLocalPath.value),
            "users/images/profile/${authController.usermodel.value!.id}");
        payload = {"profilePhoto": profilePhoto};
        profileImageLocalPath.value = "";
      }
      if (coverPhotoLocalPath.value.isNotEmpty) {
        final imgUploadFuture = await FirestoreFilesAccess().uploadFileToPath(
            File(coverPhotoLocalPath.value),
            "users/images/cover/${authController.usermodel.value!.id}");
        payload.addAll({"coverPhoto": imgUploadFuture});
        coverPhotoLocalPath.value = "";
      }
      return payload;
    } catch (e) {
      return {};
    }
  }

  Future<void> addImageButtonCallback(BuildContext context,
      {int? index, ImageSource? imgSource, String? type}) async {
    String path = await choseImageFromLocalFiles(imgSource: imgSource);
    if (type == "cover") {
      coverPhotoLocalPath.value = path;
    } else {
      profileImageLocalPath.value = path;
    }
  }

  Future<void> updateProfile(BuildContext context) async {
    try {
      LoadingOverlay.showLoading(context);
      var imagepayload = {};
      if (coverPhotoLocalPath.value.isNotEmpty ||
          profileImageLocalPath.value.isNotEmpty) {
        imagepayload = await uploadCoverPhoto();
      }

      await UserAPI().updateUser({
        'firstName': displaynameEditFormField.text.isNotEmpty
            ? displaynameEditFormField.text.split(" ")[0]
            : '',
        'lastName': displaynameEditFormField.text.isNotEmpty &&
                displaynameEditFormField.text.split(" ").length > 1
            ? displaynameEditFormField.text.split(" ")[1]
            : '',
        'userName': usernameEditFormField.text,
        'bio': bioEditFormField.text,
        ...imagepayload
      }, authController.usermodel.value!.id!);
      authController.callInit();
      LoadingOverlay.hideLoading(context);
    } catch (e) {
      print(e);
      LoadingOverlay.hideLoading(context);
    }
  }

  shareProfile(UserModel user) async {
    String url = DynamicLinkService().generateShareLink(user.id!);
    await Share.share(url,
        subject: "${'share'.tr} ${user.firstName!} ${'profile'.tr}");
  }

  saveUserTipTransaction(Map<String, dynamic> payload, context,
      {String? user}) async {
    LoadingOverlay.showLoading(context);
    var response = await UserAPI().saveUserTipTransaction(payload);
    LoadingOverlay.hideLoading(context);
    if (response["status"] == true) {
      Get.back();
      Get.to(() => SuccessPage(
            title: "tip_success".trParams({
              "amount":
                  priceHtmlFormat(userController.selectedTip.value.toString()),
              "name": user ?? ""
            }),
            functionbtnone: () {
              Get.back();
            },
            functionbtntwo: () {
              Get.back();
            },
            buttonTwotext: "thank_you".tr,
          ));
    }
  }

  Future<void> getFriends({String? v = ""}) async {
    try {
      loadingFriends.value = true;
      var response = await UserAPI.getFriends(name: v);
      loadingFriends.value = false;
      List list = response;
      friends.value = list.map((e) => UserModel.fromJson(e)).toList();
      friends.refresh();
    } catch (e) {
      loadingFriends.value = false;
      print(e);
    }
  }

  void getShipping() async {
    try {
      var response = await UserAPI.getShipping();
      List list = response;
      shipping.value = list.map((e) => Shipping.fromJson(e)).toList();
      shipping.refresh();
    } catch (e) {
      print(e);
    }
  }

  Future<int?> wcTotalProducts() async {
    var response = await UserAPI().fetchPublishedProductCount();
    if (response.statusCode == 200) {
      final total = response.headers['x-wp-total'];
      wcSettigs['publishedProductCount'] = total;
      return int.tryParse(total ?? '0');
    } else {
      return null;
    }
  }

  void getWcSettings(String id) async {
    var response = await UserAPI.getWcSettigs(id, 'wc');
    if (response == null) return;
    if (response['settings'] == null) return;
    wcSettigs.value = response['settings'];
    wcSettigs.refresh();
  }

  Future<void> disconectWc() async {
    wcSettigs.value = {};
    wcSettigs.refresh();
    Get.back();
    await UserAPI.disconectWc(authController.usermodel.value!.id!, 'wc');
  }

  void updateSync(String key, bool v) async {
    wcSettigs[key] = v;
    wcSettigs.refresh();
    var response = await UserAPI.updateSync('wc', key, v);
    print(response);
  }

  void getnotificationSettings() async {
    try {
      var response = await UserAPI.getnotificationSettings();
      if (response == null) return;
      notificationsettigs.value = response;
      notificationsettigs.refresh();
    } catch (e) {
      print(e);
    }
  }

  void updateNotificationSettings() async {
    try {
      var response =
          await UserAPI.updatenotificationSettings(notificationsettigs);
    } catch (e) {
      print(e);
    }
  }
}
