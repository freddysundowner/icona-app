import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/widgets/custom_button.dart';

import '../../controllers/auth_controller.dart';
import '../../widgets/text_form_field.dart';

//ignore: must_be_immutable
class AddAccountUserInfo extends StatelessWidget {
  final _formSingupKey = GlobalKey<FormState>();

  final AuthController authController = Get.put(AuthController());

  AddAccountUserInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'account_information'.tr,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Form(
                        key: _formSingupKey,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 10.0,
                              ),
                              CustomTextFormField(
                                controller: authController.fnameFieldController,
                                hint: "first_name".tr,
                                validate: true,
                              ),
                              SizedBox(height: 15.sp),
                              CustomTextFormField(
                                controller: authController.lnameFieldController,
                                hint: "last_name".tr,
                                validate: true,
                              ),
                              SizedBox(height: 67.sp),
                              Obx(
                                () => authController.authenticating.isTrue
                                    ? const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : CustomButton(
                                        text: "continue".tr,
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        textColor: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10.sp),
                                        height: 35.h,
                                        function: () async {
                                          await authController.authenticateuser(
                                              "apple", context);
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 17.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
