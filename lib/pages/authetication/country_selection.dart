import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/main.dart';
import 'package:tokshop/pages/authetication/phonenumber_selection.dart';
import 'package:tokshop/widgets/custom_button.dart';

class CountrySelectionPage extends StatelessWidget {
  const CountrySelectionPage({super.key});

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
              "where_do_you_live".tr,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            SizedBox(height: 5.h),
            Text(
              "find_relevant_content".tr,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 20.h),
            InkWell(
              onTap: () {
                showCountryPicker(
                  context: context,
                  showPhoneCode: false,
                  onSelect: (Country country) {
                    authController.selectedCountry.value = country;
                  },
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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
                              authController.selectedCountry.value!.flagEmoji,
                              style: TextStyle(fontSize: 22.sp),
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              authController.selectedCountry.value!.name,
                              style: Theme.of(context).textTheme.bodyLarge,
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
            Spacer(),
            Obx(
              () => CustomButton(
                width: MediaQuery.of(context).size.width,
                height: 45,
                backgroundColor: Theme.of(context).colorScheme.primary,
                textColor: Colors.black,
                function: authController.selectedCountry.value == null
                    ? null
                    : () {
                        if (authController.selectedCountry.value != null) {
                          Get.to(() => PhoneNumberPage());
                        } else {
                          Get.snackbar("Error", "Please select a country",
                              colorText: Colors.white,
                              backgroundColor: Colors.red);
                        }
                      },
                text: "continue".tr,
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
