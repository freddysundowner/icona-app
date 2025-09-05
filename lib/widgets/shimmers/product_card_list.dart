import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget ProductCardShimme(ThemeData theme) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16.0),
    child: Shimmer.fromColors(
      baseColor: theme.dividerColor,
      highlightColor: Colors.grey.shade100,
      child: Row(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 16,
                  color: Colors.grey,
                ),
                const SizedBox(height: 8),
                Container(
                  width: 80,
                  height: 16,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
