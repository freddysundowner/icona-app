import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/order_controller.dart';
import '../../main.dart'; // for authController
import '../../models/order.dart';

class DisputeProgressPage extends StatelessWidget {
  final Order? order;
  final TextEditingController responseController = TextEditingController();

  DisputeProgressPage({super.key, this.order}) {
    // fetch dispute after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (order != null) {
        orderController.getOrderDispute(order!);
      }
    });
  }

  final OrderController orderController = Get.find<OrderController>();

  // map dispute status into a step index
  int getStepIndex(String? status) {
    switch (status) {
      case "submitted":
        return 0;
      case "seller_response":
        return 1;
      case "reviewing":
        return 2;
      case "resolved":
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("dispute_progress".tr),
      ),
      body: Obx(() {
        final dispute = orderController.dispute.value;

        // when there’s no dispute yet
        if (dispute.id == null) {
          return Center(
            child: Text("no_dispute_found".tr),
          );
        }

        final int currentStep = getStepIndex(dispute.status);

        final steps = [
          Step(
            title: Text("submitted".tr),
            subtitle: Text("your_dispute_has_been_submitted".tr),
            content: Text(
                "We’ve received your dispute for order #${order?.invoice}."),
            isActive: currentStep >= 0,
            state: currentStep > 0 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: Text("seller_response".tr),
            subtitle: Text(dispute.seller_response != null &&
                    dispute.seller_response!.isNotEmpty
                ? dispute.seller_response ?? ""
                : "waiting_for_seller_response".tr),
            content: Text("Order #${order?.invoice}."),
            isActive: currentStep >= 1,
            state: currentStep > 1 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: Text("under_review".tr),
            subtitle: Text("support_agent_reviewing".tr),
            content: Text("Our team is checking the details you provided."),
            isActive: currentStep >= 2,
            state: currentStep > 2 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: Text("resolution".tr),
            subtitle: Text("final_decision_made".tr),
            content: Text(
              "We’ll notify you of the outcome shortly.",
              style: TextStyle(color: Colors.white),
            ),
            isActive: currentStep >= 3,
            state: currentStep == 3 ? StepState.complete : StepState.indexed,
          ),
        ];

        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              // show reason and details from Mongo
              Text(
                "${"reason".tr}: ${orderController.getReasonLabel(dispute.reason, orderController.reasons)}",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                "${"details".tr}: ${dispute.details ?? ''}",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),

              // ✅ Seller response input (only for seller & if still submitted/reviewing)
              if (authController.currentuser?.id == order?.seller?.id &&
                  orderController.dispute.value.status == "submitted")
                Obx(() => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "respond_to_dispute".tr,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: responseController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: "your_response".tr,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: orderController.isSubmitting.value
                              ? null
                              : () => orderController.submitDisputeResponse(
                                    order!.id!,
                                    {
                                      "status": "seller_response",
                                      "seller_response": responseController.text
                                    },
                                  ),
                          child: orderController.isSubmitting.value
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(
                                  "submit".tr,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surface),
                                ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    )),

              Stepper(
                currentStep: currentStep,
                steps: steps,
                physics: const ClampingScrollPhysics(),
                controlsBuilder: (context, _) => const SizedBox.shrink(),
              ),
            ],
          ),
        );
      }),
    );
  }
}
