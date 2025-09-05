import 'package:country_picker/country_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/main.dart';
import 'package:tokshop/widgets/custom_button.dart';
import 'package:tokshop/widgets/text_form_field.dart';

class SignupEmail extends StatefulWidget {
  const SignupEmail({super.key});

  @override
  State<SignupEmail> createState() => _SignupEmailState();
}

class _SignupEmailState extends State<SignupEmail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          child: Icon(Icons.clear),
          onTap: () => Get.back(),
        ),
        title: Text("sign_up".tr),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  CustomTextFormField(
                    controller: authController.fnameFieldController,
                    hint: "full_name".tr,
                    onChanged: (v) {
                      !authController.validateFields();
                      setState(() {});
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  CustomTextFormField(
                    controller: authController.emailFieldController,
                    txtType: TextInputType.emailAddress,
                    hint: "email".tr,
                    onChanged: (v) {
                      !authController.validateFields();
                      setState(() {});
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  CustomTextFormField(
                      controller: authController.passwordFieldController,
                      hint: "password".tr,
                      suffixIcon: InkWell(
                        child: Obx(() => authController.obscureText.isTrue
                            ? Icon(Icons.remove_red_eye_outlined)
                            : Icon(Icons.remove_red_eye)),
                        onTap: () {
                          authController.obscureText.value =
                              !authController.obscureText.value;
                          setState(() {});
                        },
                      ),
                      onChanged: (v) {
                        !authController.validateFields();
                        setState(() {});
                      },
                      obscureText: authController.obscureText.value),
                  SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {
                      showCountryPicker(
                        context: context,
                        showPhoneCode: false,
                        onSelect: (Country country) {
                          authController.selectedCountry.value = country;
                          !authController.validateFields();
                          setState(() {});
                        },
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 14.h),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      ),
                      child: Obx(
                        () => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (authController.selectedCountry.value != null)
                              Row(
                                children: [
                                  Text(
                                    authController
                                        .selectedCountry.value!.flagEmoji,
                                    style: TextStyle(fontSize: 22.sp),
                                  ),
                                  SizedBox(width: 10.w),
                                  Text(
                                    authController.selectedCountry.value!.name,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ],
                              )
                            else
                              Text(
                                "select_country".tr,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            Icon(Icons.arrow_drop_down, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Transform.scale(
                        scale: 1.5, // Increase the size as needed
                        child: Obx(
                          () => Checkbox(
                            value: authController.agreeterms.value,
                            onChanged: (value) {
                              !authController.validateFields();
                              authController.agreeterms.value = value!;
                              setState(() {});
                            },
                            side: BorderSide(
                                width: 2,
                                color: Colors.blue), // Adds padding inside
                            visualDensity: VisualDensity
                                .compact, // Reduces touch area but keeps padding
                            shape: CircleBorder(),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text.rich(TextSpan(children: [
                          TextSpan(
                            text: "i_agree_to".tr,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          TextSpan(
                            text: "terms_and_conditions".tr,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => Get.toNamed("/terms"),
                          ),
                          TextSpan(
                            text: "confirm_read".tr,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          TextSpan(
                            text: "privacy_policy".tr,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => Get.toNamed("/privacy"),
                          )
                        ])),
                      )
                    ],
                  )
                ],
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Obx(() => authController.resetingpassword.isTrue
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : CustomButton(
                    width: MediaQuery.of(context).size.width * 0.9,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    textColor: Theme.of(context).colorScheme.onPrimary,
                    text: "sign_up".tr,
                    function: () => authController.emailSignUp(context))),
            SizedBox(
              height: 40,
            ),
          ],
        ),
      ),
    );
  }
}
