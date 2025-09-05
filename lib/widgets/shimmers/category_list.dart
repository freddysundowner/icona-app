import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget ShimmerSloganIconCard(ThemeData theme, BuildContext context) {
  return Shimmer.fromColors(
    baseColor: theme.dividerColor,
    highlightColor: Colors.grey.shade100,
    child: Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      width: MediaQuery.of(context).size.width * 0.9,
      height: 100, // Adjust height as needed
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}
