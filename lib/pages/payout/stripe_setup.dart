import 'package:csc_picker_plus/csc_picker_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tokshop/controllers/auth_controller.dart';
import 'package:tokshop/main.dart';
import 'package:tokshop/widgets/text_form_field.dart';

import '../../../utils/utils.dart';

class ConnectBankAccount extends StatefulWidget {
  const ConnectBankAccount({super.key});

  @override
  State<ConnectBankAccount> createState() => _ConnectBankAccountState();
}

class _ConnectBankAccountState extends State<ConnectBankAccount> {
  final _formKey = GlobalKey<FormState>();

  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'add_bank_details'.tr,
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10.h,
                ),
                Text("select_country".tr),
                SizedBox(
                  height: 5.h,
                ),
                CSCPickerPlus(
                  showStates: true,
                  showCities: true,
                  defaultCountry: CscCountry.United_States,
                  flagState: CountryFlag.ENABLE,
                  disableCountry: false,
                  dropdownDecoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      color: Theme.of(context).scaffoldBackgroundColor,
                      border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer
                              .withValues(alpha: 0.5),
                          width: 1)),
                  disabledDropdownDecoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      color: Colors.transparent,
                      border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer
                              .withValues(alpha: 0.5),
                          width: 1)),
                  countrySearchPlaceholder: "Country",
                  stateSearchPlaceholder: "State",
                  citySearchPlaceholder: "City",
                  countryDropdownLabel: "*Country",
                  stateDropdownLabel: "*State",
                  cityDropdownLabel: "*City",
                  selectedItemStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14.sp,
                  ),

                  ///DropdownDialog Heading style [OPTIONAL PARAMETER]
                  dropdownHeadingStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold),
                  dropdownItemStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14.sp,
                  ),
                  dropdownDialogRadius: 10.0,
                  searchBarRadius: 10.0,
                  onCountryChanged: (value) {},
                  onStateChanged: (value) {
                    userController.state.text = value.toString();
                  },
                  onCityChanged: (value) {
                    userController.city.text = value.toString();
                  },
                ),
                SizedBox(
                  height: 5.h,
                ),
                Text("address".tr),
                SizedBox(
                  height: 5.h,
                ),
                CustomTextFormField(
                  hint: "605 W Maude Avenue",
                  controller: userController.addressController,
                  validate: true,
                ),
                SizedBox(
                  height: 5.h,
                ),
                Text("post_code".tr),
                SizedBox(
                  height: 5.h,
                ),
                CustomTextFormField(
                  hint: "12345",
                  controller: userController.postalCodeController,
                  validate: true,
                  txtType: TextInputType.number,
                ),
                SizedBox(
                  height: 5.h,
                ),
                Text("account_number".tr),
                SizedBox(
                  height: 5.h,
                ),
                CustomTextFormField(
                  hint: "000123456789",
                  txtType: TextInputType.number,
                  controller: userController.accountNumberController,
                  validate: true,
                ),
                SizedBox(
                  height: 5.h,
                ),
                Text("routing_number".tr),
                SizedBox(
                  height: 5.h,
                ),
                CustomTextFormField(
                  hint: "110000000",
                  txtType: TextInputType.number,
                  controller: userController.routingNumberController,
                  validate: true,
                ),
                SizedBox(
                  height: 5.h,
                ),
                Text("ssn_last_digits".tr),
                SizedBox(
                  height: 5.h,
                ),
                CustomTextFormField(
                  txtType: TextInputType.number,
                  controller: userController.ssnNumberController,
                  hint: "0000",
                  validate: true,
                ),
                SizedBox(
                  height: 5.h,
                ),
                Text("phone_number".tr),
                SizedBox(
                  height: 5.h,
                ),
                CustomTextFormField(
                  controller: userController.phoneNumberController,
                  hint: "+17297409480",
                  txtType: TextInputType.phone,
                  validate: true,
                ),
                SizedBox(
                  height: 0.015.sh,
                ),
                Text(
                  'date_of_birth'.tr,
                  style: TextStyle(fontSize: 14.sp),
                ),
                SizedBox(
                  height: 0.01.sh,
                ),
                InkWell(
                  onTap: () async {
                    DateTime? d = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900, 5, 5, 20, 50),
                      lastDate: DateTime(2030, 6, 7, 05, 09),
                      builder: (BuildContext context, Widget? child) {
                        return Theme(
                          data: ThemeData.dark().copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: primarycolor,
                              onPrimary: Colors.white,
                              surface: kPrimaryColor,
                              onSurface: Colors.black,
                            ),
                            dialogBackgroundColor: Colors.white,
                          ),
                          child: child!,
                        );
                      },
                    );
                    userController.birthDateHolder.value = d;
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 13, horizontal: 10),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(
                          () => Text(
                            userController.birthDateHolder.value == null
                                ? "DOB"
                                : DateFormat('yyyy-MM-dd').format(
                                    userController.birthDateHolder.value!),
                            style: TextStyle(
                                fontSize: 16.sm, fontWeight: FontWeight.w400),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.grey,
                          size: 20,
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 0.03.sh,
                ),
                Center(
                  child: InkWell(
                    onTap: () async {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }
                      await userController.createStripeConnectAccount(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(
                          child: Text(
                        'connect'.tr,
                        style: TextStyle(color: Colors.white, fontSize: 18.sp),
                      )),
                    ),
                  ),
                ),
                SizedBox(
                  height: 0.03.sh,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} //+17297409480
