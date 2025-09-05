import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:country_picker/country_picker.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:tokshop/controllers/payment_controller.dart';
import 'package:tokshop/models/interests.dart';
import 'package:tokshop/pages/homescreen.dart';
import 'package:tokshop/pages/success_page.dart';
import 'package:tokshop/widgets/loadig_page.dart';

import '../main.dart';
import '../models/user.dart';
import '../pages/authetication/additional_userInfo.dart';
import '../pages/authetication/country_selection.dart';
import '../pages/authetication/welcome_screen.dart';
import '../services/user_api.dart';
import '../utils/helpers.dart';

class AuthController extends GetxController {
  Rxn<UserModel> usermodel = Rxn<UserModel>();
  RxList<String> suggestedUsernames = RxList();
  Rxn<Country> selectedCountry = Rxn<Country>();
  UserModel? get currentuser => usermodel.value;
  final TextEditingController emailFieldController = TextEditingController();
  final TextEditingController passwordFieldController = TextEditingController();
  final TextEditingController fnameFieldController = TextEditingController();
  final TextEditingController selectedGender = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController lnameFieldController = TextEditingController();
  final TextEditingController usernameFieldController = TextEditingController();
  final TextEditingController confirmPasswordFieldController =
      TextEditingController();
  final TextEditingController bioFieldController = TextEditingController();
  var supportsAppleSignIn = false.obs;
  RxList<Interests> selectedItemList = RxList([]);

  var obscureText = true.obs;
  var resetingpassword = false.obs;
  var authenticating = false.obs;
  var agreeterms = false.obs;
  var connectionstate = true.obs;
  var gettingStripeBankAccounts = false.obs;
  var deletingStripeBankAccounts = false.obs;

  var error = "".obs;
  var authType = "signup".obs;
  var logintype = "".obs;
  var profileimage = "".obs;
  var isLoading = true.obs;
  var passwordVisible = false.obs;

  final Rx<File> _chosenImage = Rx(File(""));

  File get chosenImage => _chosenImage.value;

  set setChosenImage(File img) {
    _chosenImage.value = img;
  }

  var showpasswordreset = false.obs;
  var renewUpgrade = true.obs;
  var chosenInterests = [].obs;
  var googleLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkAppleAvailability();
  }

  Future authenticateuser(String type, BuildContext context) async {
    authenticating.value = true;
    String email = emailFieldController.text;
    String displayName = fnameFieldController.text;
    String photo = "";
    String country = selectedCountry.value?.name ?? "";
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      email = email.isNotEmpty ? email : user.email ?? "";
      displayName =
          displayName.isNotEmpty ? displayName : user.displayName ?? "";
      photo = user.photoURL ?? "";
      // country =
      //     country.isNotEmpty ? country : authController.currentuser!.country!;
    } else {
      if (type == "google") {
        LoadingOverlay.showLoading(context);
        GoogleSignInAccount? response = await _googleSignIn.signIn();
        LoadingOverlay.hideLoading(context);
        if (response != null) {
          email = response.email;
          displayName = response.displayName!;
          photo = response.photoUrl!;
        }
      }
    }

    Map<String, dynamic> authData = {
      "email": email,
      "firstName": displayName,
      "type": type,
      'country': country,
      'phone': phoneController.text,
      'profilePhoto': photo,
      'gender': selectedGender.text,
      "userName": usernameFieldController.text.isEmpty
          ? emailFieldController.text
          : usernameFieldController.text
    };

    LoadingOverlay.showLoading(context);
    Map<String, dynamic> userData = await UserAPI.authenticate(authData);
    LoadingOverlay.hideLoading(context);
    if (userData["success"] == false) {
      error.value = 'technical_error_happened'.tr;
    } else {
      await _authenticate(userData);
      await callInit();
    }
    authenticating.value = false;
  }

  callInit() async {
    try {
      authController.isLoading.value = true;
      var response = await UserAPI.getUserById();
      authController.isLoading.value = false;
      themeController.isDarkMode.value = await getTheme();
      if (response != null) {
        UserModel userModel = UserModel.fromJson(response);
        usermodel.value = userModel;
        if (usermodel.value!.country!.isEmpty) {
          Get.offAll(() => CountrySelectionPage());
          return;
        }
        usermodel.refresh();
        Get.find<PaymentController>()
            .getPaymentMethodsByUserId(FirebaseAuth.instance.currentUser!.uid);
        userController.getDefaultAddress();
        Get.offAll(() => HomeScreen());
      } else {
        signOut();
      }
    } catch (e) {
      signOut();
    } finally {}
  }

  _authenticate(Map<String, dynamic> userData) async {
    userData["data"]["authtoken"] = userData["authtoken"];
    userData["data"]["accessToken"] = userData["accessToken"];
    await FirebaseAuth.instance
        .signInWithCustomToken(userData["data"]["authtoken"]);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("access_token", userData["data"]["accessToken"]);
  }

  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Map<String, dynamic> parseJwtPayLoad(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid JWT token');
    }

    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    return json.decode(decoded);
  }

  Map<String, dynamic> parseJwtHeader(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('invalid token');
    }

    final payload = _decodeBase64(parts[0]);
    final payloadMap = json.decode(payload);
    if (payloadMap is! Map<String, dynamic>) {
      throw Exception('invalid payload');
    }

    return payloadMap;
  }

  String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');

    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!"');
    }

    return utf8.decode(base64Url.decode(output));
  }

  signInWithApple(BuildContext context) async {
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );
      OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );
      print(appleCredential.identityToken!);

      final Map<String, dynamic> jwt =
          parseJwtPayLoad(appleCredential.identityToken!);
      if (appleCredential.email != null) {
        emailFieldController.text = appleCredential.email ?? "";
      } else {
        if (appleCredential.identityToken != null) {
          emailFieldController.text = jwt["email"];
        }
      }

      if (appleCredential.givenName != null) {
        fnameFieldController.text = appleCredential.givenName ?? "";
        await authenticateuser("apple", context);
      } else {
        var check =
            await UserAPI.getUserCheckByEmail(emailFieldController.text);
        if (check["success"] == true) {
          await authenticateuser("apple", context);
        } else {
          Get.to(() => AddAccountUserInfo());
        }
      }
    } catch (exception) {
      print(exception);
    }
    return null;
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  void _checkAppleAvailability() async {
    if (Platform.isIOS) {
      supportsAppleSignIn.value = await SignInWithApple.isAvailable();
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    // try {
    LoadingOverlay.showLoading(context);
    GoogleSignInAccount? response = await _googleSignIn.signIn();
    if (response != null) {
      fnameFieldController.text = response.displayName!;
      emailFieldController.text = response.email;
      usernameFieldController.text = response.email;
      profileimage.value = response.photoUrl!;
      logintype.value = 'google';
      await authenticateuser("google", context);
    }
    // } catch (error) {
    //   print(e);
    //   Get.back();
    // }
  }

  // Future<void> signInWithFacebook() async {
  //   try {
  //     final LoginResult result = await FacebookAuth.instance
  //         .login(permissions: ["email", "public_profile"]);
  //     switch (result.status) {
  //       case LoginStatus.success:
  //         var respnse = await DbBase().databaseRequest(
  //             'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture&access_token=${result.accessToken!.token}',
  //             DbBase().getRequestType);
  //         var userData = jsonDecode(respnse);
  //         print("facebookCredential ${userData}");
  //
  //         fnameFieldController.text = userData["first_name"];
  //         lnameFieldController.text = userData["last_name"];
  //         emailFieldController.text = userData["email"];
  //         usernameFieldController.text = userData["name"];
  //         profileimage.value = userData["picture"]["data"]["url"];
  //         await loginRegisterSocial("faceboook");
  //         break;
  //       case LoginStatus.cancelled:
  //         print("cancelled");
  //         break;
  //       case LoginStatus.failed:
  //         print("failed");
  //         break;
  //       default:
  //         return null;
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     Get.back();
  //   }
  //
  //   // try {
  //   //   GoogleSignInAccount? response = await _googleSignIn.signIn();
  //   //   if (response != null) {
  //   //     fnameFieldController.text = response.displayName!;
  //   //     emailFieldController.text = response.email;
  //   //     usernameFieldController.text = response.email;
  //   //     profileimage.value = response.photoUrl!;
  //   //     await loginRegisterSocial("google");
  //   //   }
  //   // } catch (error) {
  //   //   Get.back();
  //   // }
  // }

  signOut() async {
    // try {
    //   if (_tokshowcontroller.currentRoom.value!.id != null) {
    //     await _tokshowcontroller.leaveRoom();
    //   }
    //   await UserAPI().updateUser(
    //       {"notificationToken": ""}, FirebaseAuth.instance.currentUser!.uid);
    await _googleSignIn.signOut();
    // if (_googleSignIn.currentUser != null) {
    //   print("signOut");
    //   await _googleSignIn.signOut();
    // }
    // if (Get.find<AuthController>().usermodel.value!.logintype == "facebook") {
    //   await FacebookAuth.instance.logOut();
    // }

    FirebaseAuth.instance.signOut();

    chosenInterests.value = [];
    Get.offAll(const WelcomeScreen());
    // }
  }

  getAccountBalances() async {
    var response = await UserAPI().getUserBalances();
    usermodel.value!.pendingWallet = response["pending"][0]["amount"] / 100;
    usermodel.value!.wallet = response["available"][0]["amount"] / 100;
    usermodel.refresh();
  }

  validateFields() {
    if (emailFieldController.text.isNotEmpty &&
        passwordFieldController.text.isNotEmpty &&
        fnameFieldController.text.isNotEmpty &&
        selectedCountry.value != null &&
        agreeterms.isTrue) {
      return true;
    } else {
      return false;
    }
  }

  emailSignUp(BuildContext context) async {
    if (!validateFields()) {
      Get.snackbar("error".tr, "all_fields_required".tr,
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (!validateEmail(emailFieldController.text)) {
      Get.snackbar("error".tr, "enter_valid_email".tr,
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    resetingpassword.value = true;
    var response = await UserAPI().registerUser({
      "email": emailFieldController.text,
      "password": passwordFieldController.text,
      "firstName": fnameFieldController.text,
      'country': selectedCountry.value?.name,
    });
    if (response['success'] == true) {
      await _authenticate(response);
      await callInit();
      resetingpassword.value = false;
      emailFieldController.clear();
      passwordFieldController.clear();
      fnameFieldController.clear();
      agreeterms.value = false;
    } else {
      resetingpassword.value = false;
      Get.snackbar("error".tr, response['message'],
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  emailLogin(BuildContext context) async {
    try {
      if (authController.showpasswordreset.isTrue) {
        if (!validateEmail(emailFieldController.text)) {
          Get.snackbar("error".tr, "enter_valid_email".tr,
              backgroundColor: Colors.red, colorText: Colors.white);
          return;
        }
        List<String> methods = await FirebaseAuth.instance
            .fetchSignInMethodsForEmail(emailFieldController.text);

        if (methods.isEmpty) {
          Get.snackbar("error".tr, "no_user".tr,
              backgroundColor: Colors.red, colorText: Colors.white);
          return;
        }
        resetingpassword.value = true;
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: emailFieldController.text);

        resetingpassword.value = false;
        Get.to(() => SuccessPage(
              functionbtnone: () {},
              functionbtntwo: () {},
              title: "reset_password_email_set"
                  .trParams({"email": emailFieldController.text}),
            ));
      } else {
        if (emailFieldController.text.isEmpty ||
            passwordFieldController.text.isEmpty) {
          Get.snackbar("error".tr, "all_fields_required".tr,
              backgroundColor: Colors.red, colorText: Colors.white);
          return;
        }
        if (!validateEmail(emailFieldController.text)) {
          Get.snackbar("error".tr, "enter_valid_email".tr,
              backgroundColor: Colors.red, colorText: Colors.white);
          return;
        }
        resetingpassword.value = true;
        var response = await UserAPI().loginUser({
          "email": emailFieldController.text,
          "password": passwordFieldController.text,
        });

        if (response['success'] == true) {
          await _authenticate(response);
          await callInit();
          emailFieldController.clear();
          passwordFieldController.clear();
          agreeterms.value = false;
        } else {
          resetingpassword.value = false;
          Get.snackbar("error".tr, response['message'],
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      }
    } catch (e) {
      print(e.toString());
      Get.snackbar("error".tr, e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
      resetingpassword.value = false;
    } finally {
      resetingpassword.value = false;
    }
  }

  void saveTheme(String s) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("theme", s);
  }

  Future<bool> getTheme() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String theme = sharedPreferences.getString("theme") ?? "dark";
    return theme == 'dark';
  }
}
