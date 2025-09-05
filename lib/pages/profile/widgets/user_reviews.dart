import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tokshop/models/UserReview.dart';
import 'package:tokshop/pages/profile/widgets/review_card.dart';
import 'package:tokshop/utils/size_config.dart';

import '../../../controllers/user_controller.dart';

class UserReviews extends StatelessWidget {
  UserReviews({
    super.key,
  });

  final UserController _userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Container(
        height: getProportionateScreenHeight(320),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Obx(
          () => _userController.loadingReview.isTrue
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _userController.curentUserReview.length,
                  itemBuilder: (context, index) {
                    UserReview review = _userController.curentUserReview[index];
                    return ReviewCard(
                      review: review,
                      theme: theme,
                    );
                  },
                ),
        ));
  }
}
