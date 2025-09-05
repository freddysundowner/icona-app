import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class NoItems extends StatelessWidget {
  Widget? content;
  double? iconSize;
  NoItems({super.key, this.content, this.iconSize});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Icon(
              Icons.hourglass_empty,
              size: iconSize ?? 80.h,
              color: Theme.of(context).colorScheme.primary.withAlpha(100),
            ),
          ),
          Expanded(
            child: content ??
                Text('items_found'.tr,
                    style: Theme.of(context).textTheme.headlineMedium),
          ),
        ],
      ),
    );
  }
}
