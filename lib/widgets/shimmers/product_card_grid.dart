import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

Widget buildShimmerProductCard(ThemeData theme) {
  return Shimmer.fromColors(
    baseColor: theme.dividerColor,
    highlightColor: Colors.grey.shade100,
    child: Column(
      children: [
        Expanded(
          child: Container(
            height: 150.h,
            width: double.infinity,
            color: Colors.grey,
            margin: const EdgeInsets.only(bottom: 10),
          ),
        ),
        Container(
          height: 20.h,
          width: double.infinity,
          color: Colors.grey,
          margin: const EdgeInsets.symmetric(vertical: 4),
        ),
        Container(
          height: 20.h,
          width: 80.w,
          color: Colors.grey,
        ),
      ],
    ),
  );
}
