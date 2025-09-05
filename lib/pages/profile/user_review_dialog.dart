import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/order_controller.dart';
import 'package:tokshop/controllers/user_controller.dart';
import 'package:tokshop/utils/size_config.dart';
import 'package:tokshop/widgets/default_button.dart';

import '../../widgets/text_form_field.dart';

class UserReviewDialog extends StatelessWidget {
  final String user;
  String? reviewedItem = "";
  String? reviewType = "";
  UserReviewDialog(
      {super.key, required this.user, this.reviewType, this.reviewedItem});

  final OrderController orderController = Get.find<OrderController>();
  final UserController userController = Get.find<UserController>();
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Center(
        child: Text(
          "rate_seller_action".tr,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 16,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      children: [
        Center(
          child: RatingBar.builder(
            initialRating: 0,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: false,
            itemCount: 5,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              userController.ratingvalue.value = rating.round();
            },
          ),
        ),
        SizedBox(height: getProportionateScreenHeight(20)),
        Center(
          child: CustomTextFormField(
            validate: true,
            minLines: 3,
            controller: userController.review,
            label: 'feedback_optional'.tr,
            onChanged: (value) {
              userController.review.text = value;
            },
          ),
        ),
        SizedBox(height: getProportionateScreenHeight(10)),
        Obx(() => Text(
              userController.ratingError.value.isNotEmpty
                  ? userController.ratingError.value
                  : "",
              style: const TextStyle(color: Colors.red),
            )),
        Center(
          child: DefaultButton(
            text: 'submit'.tr,
            press: () async {
              userController.ratingError.value = "";
              if (userController.review.text.isEmpty) {
                userController.ratingError.value = 'feedback_is_required'.tr;
              } else {
                await userController.addUserReview(
                    user,
                    userController.review.text,
                    userController.ratingvalue.value,
                    context,
                    reviewedItem: reviewedItem!,
                    reviewType: reviewType!);
                Get.back();
                if (reviewType == "order") {
                  orderController.getOrder(orderController.currentOrder.value);
                }
              }
              // Get.back();
            },
          ),
        ),
      ],
    );
  }
}
