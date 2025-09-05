import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ContentCardOne extends StatelessWidget {
  String? slogan;
  String content;
  IconData icon;
  double? height;
  double? width;
  Color? backgroundColor;
  EdgeInsets? margin;
  TextStyle? sloganStyler;
  TextStyle? textStyle;
  Function? function;
  Alignment? iconAlign;
  CrossAxisAlignment? crossAxisAlignment;
  ContentCardOne(
      {super.key,
      this.backgroundColor,
      this.slogan,
      required this.content,
      required this.icon,
      this.height,
      this.width,
      this.sloganStyler,
      this.textStyle,
      this.margin,
      this.function,
      this.crossAxisAlignment = CrossAxisAlignment.start,
      this.iconAlign = Alignment.topLeft});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      splashColor: Colors.transparent,
      onTap: () {
        function!();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.h),
        width: width ?? MediaQuery.of(context).size.width,
        height: height ?? 70.h,
        margin:
            margin ?? EdgeInsets.only(left: 20, right: 5, bottom: 10, top: 15),
        decoration: BoxDecoration(
            color: backgroundColor ?? theme.colorScheme.onSecondaryContainer,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: theme.dividerColor)),
        child: Column(
          crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: iconAlign ?? Alignment.topLeft,
              child: Icon(
                icon,
                size: 18.w,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: Text(
                content,
                style: textStyle ??
                    theme.textTheme.titleSmall?.copyWith(fontSize: 12.sp),
              ),
            ),
            if (slogan != null)
              SizedBox(
                height: 5,
              ),
            if (slogan != null)
              Text(
                slogan ?? "",
                style: sloganStyler ?? theme.textTheme.bodySmall,
              )
          ],
        ),
      ),
    );
  }
}
