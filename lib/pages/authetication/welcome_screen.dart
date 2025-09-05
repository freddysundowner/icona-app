import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tokshop/main.dart';
import 'package:tokshop/pages/authetication/signup_email.dart';
import 'package:tokshop/widgets/custom_button.dart';

import 'login_email.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary; // Teal
    final Color secondary = Theme.of(context).colorScheme.secondary; // Coral
    final Color background = Theme.of(context).scaffoldBackgroundColor;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Theme.of(context).brightness == Brightness.dark
          ? SystemUiOverlayStyle.light // white status bar text/icons
          : SystemUiOverlayStyle.dark, // black status bar text/icons((
      child: Scaffold(
        backgroundColor: background,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo_transparent.png',
                width: 140.w,
                height: 140.w,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [secondary, primary],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ).createShader(bounds),
                child: Text(
                  "signup_text".tr,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                      ),
                ),
              ),

              if (Platform.isIOS) SizedBox(height: 30.h),

              // Apple Button
              if (Platform.isIOS)
                _socialButton(
                  context,
                  icon: "assets/icons/apple_icon.svg",
                  text: "continue_apple".tr,
                  onTap: () => authController.signInWithApple(context),
                  gradient: LinearGradient(
                    colors: [primary, secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),

              if (Platform.isAndroid) SizedBox(height: 30.h),

              // Google Button
              if (Platform.isAndroid)
                _socialButton(
                  context,
                  icon: "assets/icons/google-icon.svg",
                  text: "continue_google".tr,
                  onTap: () => authController.signInWithGoogle(context),
                  gradient: LinearGradient(
                    colors: [primary, secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),

              SizedBox(height: 10.h),

              // Email Button
              _socialButton(
                context,
                icon: "assets/icons/Mail.svg",
                text: "continue_email".tr,
                onTap: () {
                  authController.logintype.value = 'email';
                  if (authController.authType.value == "login") {
                    Get.to(() => LoginEmail());
                  } else {
                    Get.to(() => SignupEmail());
                  }
                },
                gradient: LinearGradient(
                  colors: [secondary, primary],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),

              SizedBox(height: 30.h),

              // Switch Login/Signup
              TextButton(
                onPressed: () {
                  authController.authType.value =
                      authController.authType.value == "login"
                          ? "signup"
                          : "login";
                },
                child: Obx(
                  () => authController.authType.value == "login"
                      ? Text(
                          "dont_have_account".tr,
                          style: Theme.of(context).textTheme.bodyLarge,
                        )
                      : Text(
                          "already_have_account".tr,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                ),
              ),

              SizedBox(height: 10.h),

              // Terms
              Text(
                "terms_conditions".tr,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialButton(BuildContext context,
      {required String icon,
      required String text,
      required VoidCallback onTap,
      required Gradient gradient}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(30),
        ),
        width: MediaQuery.of(context).size.width * 0.80,
        child: Row(
          children: [
            SvgPicture.asset(icon, color: Colors.white, width: 20.w),
            CustomButton(
              width: MediaQuery.of(context).size.width * 0.60,
              text: text,
              function: onTap,
              backgroundColor: Colors.transparent,
              padding: EdgeInsets.symmetric(vertical: 10),
              textColor: Colors.white,
              height: 45,
            ),
          ],
        ),
      ),
    );
  }
}
