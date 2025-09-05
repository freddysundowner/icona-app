import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../models/product.dart';

Widget inshowBadge(ThemeData theme, Product product) {
  if (product.tokshow == null || product.tokshow!.isEmpty) {
    return Container(
      height: 0,
    );
  }

  return Positioned(
    top: 8,
    left: 8,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            "assets/icons/in_show.svg",
            color: Colors.white,
          ),
          Text(
            'in_show'.tr,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    ),
  );
}
