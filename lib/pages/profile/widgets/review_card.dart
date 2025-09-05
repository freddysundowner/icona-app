import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tokshop/models/UserReview.dart';

import '../../../utils/helpers.dart';

class ReviewCard extends StatelessWidget {
  UserReview review;
  ThemeData theme;
  ReviewCard({super.key, required this.review, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (review.from?.profilePhoto != null)
                CachedNetworkImage(
                  imageUrl: review.from!.profilePhoto!,
                  imageBuilder: (context, imageProvider) => Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.cover),
                    ),
                  ),
                  placeholder: (context, url) => Container(
                      width: 20,
                      height: 20,
                      child: const CircularProgressIndicator()),
                  errorWidget: (context, url, error) => Image.asset(
                    "assets/icons/profile_placeholder.png",
                    width: 20,
                    height: 20,
                  ),
                ),
              if (review.from?.profilePhoto == null)
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      review.from!.firstName!.split("")[0].toUpperCase(),
                      style: TextStyle(
                          color: theme.colorScheme.onPrimary, fontSize: 10.sp),
                    ),
                  ),
                ), //sho
              SizedBox(
                width: 4,
              ), // w on  letter
              Text(
                review.from!.firstName!,
                style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.normal),
              ),
            ],
          ),
          SizedBox(
            height: 5,
          ), //
          Row(
            children: [
              Icon(Icons.star, color: Colors.orange, size: 15.sp),
              SizedBox(
                width: 4,
              ),
              Text(
                review.rating.toString(),
                style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.normal),
              ),
              Text("  |  "),
              Text(dateFormat(review.date!),
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.normal))
            ],
          ),
          Text(
            review.feedback ?? "",
            style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }
}
