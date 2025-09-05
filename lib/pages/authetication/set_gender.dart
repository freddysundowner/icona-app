import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/main.dart';
import 'package:tokshop/pages/authetication/set_user_name.dart';
import 'package:tokshop/widgets/custom_button.dart';

class GenderSelectionPage extends StatefulWidget {
  const GenderSelectionPage({super.key});

  @override
  State<GenderSelectionPage> createState() => _GenderSelectionPageState();
}

class _GenderSelectionPageState extends State<GenderSelectionPage> {
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
              "whats_your_gender".tr,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            SizedBox(height: 5.h),
            Text(
              "suggest_relevant_categories".tr,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 20.h),
            CustomButton(
              width: MediaQuery.of(context).size.width,
              height: 45,
              backgroundColor: authController.selectedGender.text.isNotEmpty &&
                      authController.selectedGender.text == 'female'
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).scaffoldBackgroundColor,
              borderColor: Colors.grey,
              textColor: authController.selectedGender.text.isNotEmpty &&
                      authController.selectedGender.text == 'female'
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
              function: () {
                authController.selectedGender.text = 'female';
                setState(() {});
              },
              text: "female".tr,
            ),
            SizedBox(height: 10.h),
            CustomButton(
              width: MediaQuery.of(context).size.width,
              height: 45,
              backgroundColor: authController.selectedGender.text.isNotEmpty &&
                      authController.selectedGender.text == 'male'
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).scaffoldBackgroundColor,
              borderColor: Colors.grey,
              textColor: authController.selectedGender.text.isNotEmpty &&
                      authController.selectedGender.text == 'male'
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
              function: () {
                authController.selectedGender.text = 'male';
                setState(() {});
              },
              text: "male".tr,
            ),
            Spacer(),
            CustomButton(
              width: MediaQuery.of(context).size.width,
              height: 45,
              backgroundColor: Theme.of(context).colorScheme.primary,
              textColor: Colors.black,
              function: () {
                if (authController.selectedGender.text.isNotEmpty) {
                  Get.to(() => UsernameSelectionPage());
                } else {
                  Get.snackbar("Error", "Please select gender",
                      colorText: Colors.white, backgroundColor: Colors.red);
                }
              },
              text: "continue".tr,
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
