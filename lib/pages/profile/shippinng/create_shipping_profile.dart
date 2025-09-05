import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/shipping_controller.dart';
import 'package:tokshop/models/shippingProfile.dart';

class CreateShippingProfilePage extends StatelessWidget {
  ShippingProfile? shippingProfile;
  CreateShippingProfilePage({super.key, this.shippingProfile}) {
    if (shippingProfile != null) {
      shippingController.nameController.text = shippingProfile!.name;
      shippingController.weightController.text =
          shippingProfile!.weight.toDouble().toString();
      shippingController.selectedScale.value = shippingProfile!.scale;
    } else {
      shippingController.nameController.text = "";
      shippingController.weightController.text = "";
      shippingController.selectedScale.value = "pound";
    }
  }
  ShippingController shippingController = Get.find<ShippingController>();

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "create_shipping_profile".tr,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            /// --- Details Section ---
            Text(
              "details".tr,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            /// Name Field
            TextField(
              controller: shippingController.nameController,
              decoration: InputDecoration(
                labelText: "name".tr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: theme.colorScheme.onSecondaryContainer), // default
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: theme.colorScheme.onSecondaryContainer,
                      width: 2), // focus color
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color:
                          theme.colorScheme.onSecondaryContainer), // unfocused
                ),
              ),
            ),
            const SizedBox(height: 16),

            /// Weight + Scale Row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: shippingController.weightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "weight".tr,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: theme
                                .colorScheme.onSecondaryContainer), // default
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: theme.colorScheme.onSecondaryContainer,
                            width: 2), // focus color
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: theme
                                .colorScheme.onSecondaryContainer), // unfocused
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: shippingController.selectedScale.value,
                    items: shippingController.scales
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        shippingController.selectedScale.value = val;
                      }
                    },
                    decoration: InputDecoration(
                      labelText: "scale".tr,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: theme
                                .colorScheme.onSecondaryContainer), // default
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: theme.colorScheme.onSecondaryContainer,
                            width: 2), // focus color
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: theme
                                .colorScheme.onSecondaryContainer), // unfocused
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Text(
              "weight_description".tr,
              style: const TextStyle(fontSize: 12, color: Colors.redAccent),
            ),
            const SizedBox(height: 24),

            // /// --- Bundling Options Section ---
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Text(
            //       "bundling_options".tr,
            //       style: const TextStyle(
            //           fontSize: 16, fontWeight: FontWeight.w600),
            //     ),
            //     Text(
            //       "learn_more".tr,
            //       style: const TextStyle(fontSize: 14, color: Colors.blue),
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 12),
            //
            // /// Switch 1
            // SwitchListTile(
            //   contentPadding: EdgeInsets.zero,
            //   title: Text(
            //     "set_a_limit_on_items_per_package".tr,
            //     style:
            //         const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            //   ),
            //   subtitle: Text(
            //     "bundling_description".tr,
            //     style: const TextStyle(fontSize: 12, color: Colors.black54),
            //   ),
            //   value: shippingController.limitItemsPerPackage.value,
            //   onChanged: (val) =>
            //       shippingController.limitItemsPerPackage.value = val,
            // ),
            //
            // if (shippingController.limitItemsPerPackage.value) ...[
            //   const SizedBox(height: 8),
            //   TextField(
            //     controller: shippingController.maxItemsController,
            //     keyboardType: TextInputType.number,
            //     decoration: InputDecoration(
            //       labelText: "max_items_in_box".tr,
            //       border: OutlineInputBorder(
            //         borderRadius: BorderRadius.circular(12),
            //       ),
            //     ),
            //   ),
            //   const SizedBox(height: 6),
            //   Row(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       const Icon(Icons.info_outline,
            //           size: 18, color: Colors.black54),
            //       const SizedBox(width: 6),
            //       Expanded(
            //         child: Text(
            //           "bundling_helper_text".tr,
            //           style: const TextStyle(
            //             fontSize: 12,
            //             color: Colors.black54,
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            //   const SizedBox(height: 16),
            // ],
            //
            // /// Switch 2
            // SwitchListTile(
            //   contentPadding: EdgeInsets.zero,
            //   title: Text(
            //     "set_a_fixed_weight".tr,
            //     style:
            //         const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            //   ),
            //   subtitle: Text(
            //     "incremental_weight".tr,
            //     style: const TextStyle(fontSize: 12, color: Colors.black54),
            //   ),
            //   value: shippingController.fixedWeightForAdditional.value,
            //   onChanged: (val) =>
            //       shippingController.fixedWeightForAdditional.value = val,
            // ),
            //
            // if (shippingController.fixedWeightForAdditional.value) ...[
            //   const SizedBox(height: 8),
            //   TextField(
            //     controller: shippingController.fixedWeightController,
            //     keyboardType: TextInputType.number,
            //     decoration: InputDecoration(
            //       labelText: "additional_item_weight".tr,
            //       border: OutlineInputBorder(
            //         borderRadius: BorderRadius.circular(12),
            //       ),
            //     ),
            //   ),
            //   const SizedBox(height: 16),
            // ],

            /// Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {
                  if (shippingProfile != null) {
                    shippingController.updateProfile(shippingProfile!);
                  } else {
                    shippingController.saveProfile();
                  }
                },
                child: Text(
                  shippingProfile == null
                      ? "save_profile".tr
                      : "update_profile".tr,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            if (shippingProfile != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () {
                    shippingController.deleteProfile(shippingProfile!.id);
                  },
                  child: Text(
                    "delete".tr,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
