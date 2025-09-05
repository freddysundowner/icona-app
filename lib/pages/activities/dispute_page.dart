import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/order_controller.dart';

import '../../models/order.dart';

class RaiseDisputePage extends StatelessWidget {
  final Order order;
  RaiseDisputePage({super.key, required this.order});

  final OrderController controller = Get.find<OrderController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("raise_dispute".tr),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("select_reason".tr,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),

            // Dropdown with Obx
            Obx(() => DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  value: controller.selectedReason.value,
                  items: controller.reasons.map((reason) {
                    return DropdownMenuItem<String>(
                      value: reason['value'], // use string
                      child: Text(reason['label']!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) controller.selectedReason.value = value;
                  },
                )),
            const SizedBox(height: 16),

            Text("additional_details".tr,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),

            TextField(
              controller: controller.detailsController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "describe_issue_here".tr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const Spacer(),

            Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : () => controller.submitDispute(order),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: controller.isSubmitting.value
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            "submit_dispute".tr,
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
