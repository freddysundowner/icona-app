import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:tokshop/main.dart';
import 'package:tokshop/pages/authetication/set_gender.dart';

import '../../widgets/custom_button.dart';

class PhoneNumberPage extends StatelessWidget {
  const PhoneNumberPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "whats_your_number".tr,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            SizedBox(height: 5.h),
            Text(
              "protect_account".tr,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 20.h),
            IntlPhoneField(
              controller: authController.phoneController,
              decoration: InputDecoration(
                labelText: "enter_phone_number".tr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                ),
              ),
              initialCountryCode: 'KE',
            ),
            Spacer(),
            CustomButton(
              width: MediaQuery.of(context).size.width,
              height: 45,
              backgroundColor: Theme.of(context).colorScheme.primary,
              textColor: Colors.black,
              function: () {
                Get.to(() => GenderSelectionPage());
              },
              text: "continue".tr,
            ),
            SizedBox(height: 20.h),
            CustomButton(
              width: MediaQuery.of(context).size.width,
              height: 45,
              backgroundColor: Colors.transparent,
              textColor: Colors.blue,
              function: () {
                Get.to(() => GenderSelectionPage());
              },
              text: "skip".tr,
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
