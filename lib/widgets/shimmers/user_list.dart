import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget ShimmerUserCard(ThemeData theme) {
  return Shimmer.fromColors(
    baseColor: theme.dividerColor,
    highlightColor: Colors.grey.shade100,
    child: Container(
      margin: const EdgeInsets.only(bottom: 15.0, top: 10),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 150,
                  height: 10,
                  color: Colors.white,
                ),
                SizedBox(height: 5),
                Container(
                  width: 100,
                  height: 10,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          Container(
            width: 80,
            height: 30,
            color: Colors.white,
          ),
        ],
      ),
    ),
  );
}
