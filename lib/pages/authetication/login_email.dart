import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tokshop/main.dart';
import 'package:tokshop/widgets/custom_button.dart';
import 'package:tokshop/widgets/text_form_field.dart';

class LoginEmail extends StatefulWidget {
  const LoginEmail({super.key});

  @override
  State<LoginEmail> createState() => _LoginEmailState();
}

class _LoginEmailState extends State<LoginEmail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          child: Icon(Icons.clear),
          onTap: () {
            Get.back();
            authController.showpasswordreset.value = false;
          },
        ),
        title: Text("log_in".tr),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Expanded(
              child: Obx(
                () => ListView(
                  children: [
                    if (authController.showpasswordreset.value == true)
                      Text(
                        "forgot_your_password".tr,
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
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
                    if (authController.showpasswordreset.value == false)
                      SizedBox(
                        height: 20,
                      ),
                    if (authController.showpasswordreset.value == false)
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
                    if (authController.showpasswordreset.value == false)
                      SizedBox(
                        height: 20,
                      ),
                    if (authController.showpasswordreset.value == false)
                      InkWell(
                        onTap: () async {
                          authController.showpasswordreset.value =
                              !authController.showpasswordreset.value;
                        },
                        child: Center(
                            child: Text(
                          "forgot_password".tr,
                          style: Theme.of(context).textTheme.bodyLarge,
                        )),
                      )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Obx(
              () => authController.resetingpassword.isTrue
                  ? CircularProgressIndicator()
                  : CustomButton(
                      width: MediaQuery.of(context).size.width * 0.9,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      textColor: Theme.of(context).colorScheme.onPrimary,
                      text: authController.showpasswordreset.isTrue
                          ? "reseting_passowrd".tr
                          : "log_in".tr,
                      function: () => authController.emailLogin(context)),
            ),
            SizedBox(
              height: 40,
            ),
          ],
        ),
      ),
    );
  }
}
