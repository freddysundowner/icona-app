import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tokshop/main.dart';
import 'package:tokshop/models/shippingProfile.dart';
import 'package:tokshop/widgets/loadig_page.dart';

import '../services/shipping_profile_api.dart';

class ShippingController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController maxItemsController = TextEditingController();
  final TextEditingController fixedWeightController = TextEditingController();

  RxList<String> scales = ["pound", "kg", "gram", "ounce"].obs;
  RxString selectedScale = "pound".obs;

  RxBool loadingShippingProfile = false.obs;
  RxBool loadingShippingEstimate = false.obs;
  RxBool limitItemsPerPackage = false.obs;
  RxBool fixedWeightForAdditional = false.obs;
  RxList<ShippingProfile> shippigprofiles = <ShippingProfile>[].obs;
  RxMap<dynamic, dynamic> shippingEstimate = <dynamic, dynamic>{
    "amount": "0",
    "currency": "",
    "rate_id": null,
    "servicelevel": ""
  }.obs;
  updateProfile(ShippingProfile profile) async {
    try {
      String name = nameController.text;
      String weight = weightController.text;
      String maxItems = maxItemsController.text;
      String fixedWeight = fixedWeightController.text;
      LoadingOverlay.showLoading(Get.context!);

      await ShipppingProfileAPI.updateShippingProfile(profile.id, body: {
        "name": name,
        "weight": weight,
        "max_items": maxItems,
        "fixed_weight": fixedWeight,
        "scale": selectedScale.value,
        "limit_items_per_package": limitItemsPerPackage.value,
        "fixed_weight_for_additional": fixedWeightForAdditional.value
      });
      LoadingOverlay.hideLoading(Get.context!);
      Get.back();
    } catch (e) {
      Get.back();
    } finally {
      getShippingProfilesByUserId(authController.currentuser!.id!);
    }
  }

  saveProfile() async {
    try {
      String name = nameController.text;
      String weight = weightController.text;
      String maxItems = maxItemsController.text;
      String fixedWeight = fixedWeightController.text;
      LoadingOverlay.showLoading(Get.context!);
      await ShipppingProfileAPI.createShippingProfile(body: {
        "name": name,
        "weight": weight,
        "max_items": maxItems,
        "fixed_weight": fixedWeight,
        "scale": selectedScale.value,
        "limit_items_per_package": limitItemsPerPackage.value,
        "fixed_weight_for_additional": fixedWeightForAdditional.value
      });
      LoadingOverlay.hideLoading(Get.context!);
      Get.back();
    } catch (e) {
      Get.back();
    } finally {
      getShippingProfilesByUserId(authController.currentuser!.id!);
    }
  }

  deleteProfile(id) async {
    try {
      LoadingOverlay.showLoading(Get.context!);
      var response = await ShipppingProfileAPI.deleteShippingProfile(id);
      LoadingOverlay.hideLoading(Get.context!);
      Get.back();
    } catch (e) {
      Get.back();
    } finally {
      getShippingProfilesByUserId(authController.currentuser!.id!);
    }
  }

  updateShippingProfile(id) async {
    String name = nameController.text;
    String weight = weightController.text;
    String maxItems = maxItemsController.text;
    String fixedWeight = fixedWeightController.text;
    LoadingOverlay.showLoading(Get.context!);
    await ShipppingProfileAPI.updateShippingProfile(id, body: {
      "name": name,
      "weight": weight,
      "max_items": maxItems,
      "fixed_weight": fixedWeight,
      "scale": selectedScale.value,
      "limit_items_per_package": limitItemsPerPackage.value,
      "fixed_weight_for_additional": fixedWeightForAdditional.value
    });
    LoadingOverlay.hideLoading(Get.context!);
  }

  getShippingProfilesByUserId(id) async {
    loadingShippingProfile.value = true;
    var response = await ShipppingProfileAPI.getShippingProfilesByUserId(id);
    loadingShippingProfile.value = false;
    if (response.isNotEmpty && response != null) {
      List list = response;
      shippigprofiles.value =
          list.map((e) => ShippingProfile.fromJson(e)).toList();
    } else {
      shippigprofiles.value = [];
    }
    shippigprofiles.refresh();
  }

  Future<void> getShippingEstimate({Map<String, dynamic>? data}) async {
    loadingShippingEstimate.value = true;
    var response =
        await ShipppingProfileAPI.getShippingEstimateData(data: data);
    loadingShippingEstimate.value = false;
    if (response != null) {
      shippingEstimate.value = {
        "amount": response["amount"],
        "currency": response["currency"],
        'rate_id': response["objectId"],
        'servicelevel': response["servicelevel"]['name']
      };
    }
    shippingEstimate.refresh();
  }
}
