import 'package:csc_picker_plus/csc_picker_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/user_controller.dart';

import '../../controllers/checkout_controller.dart';
import '../../main.dart';
import '../../models/ShippingAddress.dart';
import '../../services/user_api.dart';
import '../../utils/functions.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loadig_page.dart';
import '../../widgets/text_form_field.dart';

//ignore: must_be_immutable
class AddressDetailsForm extends StatelessWidget {
  ShippingAddress? addressToEdit;
  bool? showsave = true;

  AddressDetailsForm({this.addressToEdit, this.showsave, super.key}) {
    if (addressToEdit != null) {
      checkOutController.addressReceiverFieldController.text =
          addressToEdit!.name;
      checkOutController.addressLine1FieldController.text =
          addressToEdit!.addrress1;
      checkOutController.addressLine2FieldController.text =
          addressToEdit!.addrress2;
      checkOutController.countryFieldController.text = addressToEdit!.country;
      checkOutController.stateFieldController.text = addressToEdit!.state;
      checkOutController.cityFieldController.text = addressToEdit!.city;
      checkOutController.postalCodeFieldController.text =
          addressToEdit!.zipcode ?? "";
      checkOutController.submitready.value = true;
    } else {
      checkOutController.clearAddressTextControllers();
    }
  }

  CheckOutController checkOutController = Get.find<CheckOutController>();

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text('add_address'.tr),
        leading: InkWell(
          child: Icon(Icons.arrow_back_ios),
          onTap: () => Get.back(),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Form(
          key: checkOutController.formKey,
          child: ListView(
            children: [
              SizedBox(height: 5.h),
              CustomTextFormField(
                hint: "full_name".tr,
                controller: checkOutController.addressReceiverFieldController,
                onChanged: (v) {
                  checkOutController.submitready.value =
                      checkOutController.formKey.currentState!.validate();
                },
                validate: true,
              ),
              SizedBox(height: 20.h),
              CustomTextFormField(
                hint: "address_one".tr,
                controller: checkOutController.addressLine1FieldController,
                onChanged: (v) {
                  checkOutController.submitready.value =
                      checkOutController.formKey.currentState!.validate();
                },
                validate: true,
              ),
              SizedBox(height: 20.h),
              CustomTextFormField(
                hint: "address_two".tr,
                controller: checkOutController.addressLine2FieldController,
                onChanged: (v) {
                  checkOutController.submitready.value =
                      checkOutController.formKey.currentState!.validate();
                },
                validate: false,
              ),
              SizedBox(height: 20.h),
              CSCPickerPlus(
                showStates: true,
                showCities: true,
                defaultCountry: CscCountry.United_States,
                flagState: CountryFlag.ENABLE,
                disableCountry: false,
                currentCountry:
                    checkOutController.countryFieldController.text.isNotEmpty
                        ? checkOutController.countryFieldController.text
                        : null,
                currentState:
                    checkOutController.stateFieldController.text.isNotEmpty
                        ? checkOutController.stateFieldController.text
                        : null,
                currentCity:
                    checkOutController.cityFieldController.text.isNotEmpty
                        ? checkOutController.cityFieldController.text
                        : null,
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
                onCountryChanged: (value) {
                  var code = getCountryCodeFromPickerValue(value);
                  checkOutController.countryCodeFieldController.text = code;
                  checkOutController.countryFieldController.text = value;
                },
                onStateChanged: (value) {
                  checkOutController.stateFieldController.text =
                      value.toString();
                },
                onCityChanged: (value) {
                  checkOutController.cityFieldController.text =
                      value.toString();
                },
              ),
              SizedBox(height: 20.h),
              CustomTextFormField(
                hint: "postal_code".tr,
                controller: checkOutController.postalCodeFieldController,
                onChanged: (v) {
                  checkOutController.submitready.value =
                      checkOutController.formKey.currentState!.validate();
                },
                validate: true,
              ),
              SizedBox(height: 20.h),
              CustomTextFormField(
                hint: "phone_number".tr,
                controller: checkOutController.phoneNumberFieldController,
              ),
              SizedBox(height: 20.h),
              CustomTextFormField(
                hint: "email".tr,
                controller: checkOutController.emailFieldController,
              ),
              SizedBox(height: 20.h),
              Obx(
                () => CustomButton(
                  function: checkOutController.submitready.isFalse
                      ? null
                      : () => _save_address(context),
                  text: addressToEdit == null ? "save".tr : "update".tr,
                  backgroundColor: theme.primaryColor,
                  textColor: theme.colorScheme.surface,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    //return form;
  }

  _save_address(BuildContext context) {
    if (addressToEdit == null) {
      saveNewAddressButtonCallback(context);
    } else {
      saveEditedAddressButtonCallback(context);
    }
  }

  Future<void> saveNewAddressButtonCallback(BuildContext context) async {
    if (checkOutController.formKey.currentState!.validate()) {
      final ShippingAddress newAddress = generateAddressObject();
      try {
        if (checkOutController.emailFieldController.text.isEmpty) {
          Get.showSnackbar(
            GetSnackBar(
                message: "email_required".tr,
                duration: Duration(seconds: 5),
                backgroundColor: Colors.red,
                snackPosition: SnackPosition.TOP),
          );
          return;
        }
        if (checkOutController.phoneNumberFieldController.text.isEmpty) {
          Get.showSnackbar(
            GetSnackBar(
                message: "phone_number_required".tr,
                duration: Duration(seconds: 5),
                backgroundColor: Colors.red,
                snackPosition: SnackPosition.TOP),
          );
          return;
        }
        LoadingOverlay.showLoading(context);
        var response = await UserAPI.addAddressForCurrentUser(newAddress);
        LoadingOverlay.hideLoading(context);
        if (await response["success"] == true) {
          Get.back();
          userController.gettingMyAddrresses();
        } else {
          Get.showSnackbar(
            GetSnackBar(
                message: response["message"],
                duration: Duration(seconds: 5),
                backgroundColor: Colors.red,
                snackPosition: SnackPosition.TOP),
          );
        }
      } catch (e, s) {}
    }
  }

  Future<void> saveEditedAddressButtonCallback(BuildContext context) async {
    if (checkOutController.formKey.currentState!.validate()) {
      final ShippingAddress newAddress =
          generateAddressObject(id: addressToEdit!.id);

      if (checkOutController.emailFieldController.text.isEmpty) {
        Get.showSnackbar(
          GetSnackBar(
              message: "email_required".tr,
              duration: Duration(seconds: 5),
              backgroundColor: Colors.red,
              snackPosition: SnackPosition.TOP),
        );
        return;
      }
      if (checkOutController.phoneNumberFieldController.text.isEmpty) {
        Get.showSnackbar(
          GetSnackBar(
              message: "phone_number_required".tr,
              duration: Duration(seconds: 5),
              backgroundColor: Colors.red,
              snackPosition: SnackPosition.TOP),
        );
        return;
      }
      String snackbarMessage = 'updated_successfully'.tr;
      try {
        LoadingOverlay.showLoading(context);
        var response = UserAPI.updateAddressForCurrentUser(
            newAddress.toJson(), addressToEdit!.id!);
        LoadingOverlay.hideLoading(context);
        if (response["success"] == true) {
          snackbarMessage = 'address_updated_successfully'.tr;
          Get.find<UserController>().gettingMyAddrresses();
        }
      } on FirebaseException catch (e) {
        snackbarMessage = 'something_went_wrong'.tr;
      } catch (e, s) {
        snackbarMessage = 'something_went_wrong'.tr;
      } finally {
        Get.back();
        checkOutController.clearAddressTextControllers();
      }
    }
  }

  ShippingAddress generateAddressObject({String? id}) {
    return ShippingAddress(
      name: checkOutController.addressReceiverFieldController.text,
      addrress1: checkOutController.addressLine1FieldController.text,
      addrress2: checkOutController.addressLine2FieldController.text,
      country: checkOutController.countryFieldController.text,
      city: checkOutController.cityFieldController.text,
      countryCode: checkOutController.countryCodeFieldController.text,
      zipcode: checkOutController.postalCodeFieldController.text,
      state: checkOutController.stateFieldController.text,
      userId: FirebaseAuth.instance.currentUser!.uid,
      phoneNumber: checkOutController.phoneNumberFieldController.text,
      email: checkOutController.emailFieldController.text,
      primary: false,
    );
  }
}
