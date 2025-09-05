import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SloganIconCard extends StatelessWidget {
  String? title;
  double? topSpacer;
  double? bottomSpacer;
  Color? rightIconStyle;
  String? slogan;
  Function? function;
  IconData? rightIcon;
  Image? leftIconImg;
  SvgPicture? leftIconSvg;
  Widget? sloganWidget;
  Widget? leftWidget;
  IconData? leftIcon;
  Color? borderColor;
  Color? backgroundColor;
  Color? gradientColor1;
  Color? gradientColor2;
  TextStyle? titleStyle;
  EdgeInsets? padding;
  SloganIconCard(
      {super.key,
      this.title,
      this.leftWidget,
      this.gradientColor1,
      this.gradientColor2,
      this.titleStyle,
      this.padding,
      this.rightIconStyle,
      this.slogan,
      this.topSpacer,
      this.bottomSpacer,
      this.sloganWidget,
      this.leftIconSvg,
      this.borderColor,
      this.leftIconImg,
      this.backgroundColor,
      this.function,
      this.leftIcon,
      this.rightIcon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      onTap: function == null
          ? null
          : () {
              function!();
            },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (topSpacer != null)
            SizedBox(
              height: topSpacer,
            ),
          Container(
            padding: padding ??
                const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
                color: backgroundColor ??
                    Theme.of(context).colorScheme.onSecondaryContainer,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    gradientColor1 ??
                        backgroundColor ??
                        Theme.of(context).colorScheme.onSecondaryContainer,
                    gradientColor2 ??
                        backgroundColor ??
                        Theme.of(context).colorScheme.onSecondaryContainer,
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor ?? Colors.transparent)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (leftWidget != null || leftWidget != null) leftWidget!,
                if (leftWidget != null || leftWidget != null)
                  SizedBox(
                    width: 5,
                  ),
                if (leftIcon != null || leftIconImg != null) Icon(leftIcon),
                if (leftIconImg != null)
                  Center(
                    child: leftIconImg,
                  ),
                if (leftIconSvg != null)
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.only(right: 10),
                      child: leftIconSvg,
                    ),
                  ),
                if (leftIcon != null)
                  SizedBox(
                    width: 10,
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (title != null)
                        Text(
                          title ?? "",
                          style: titleStyle ??
                              TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.color,
                                  fontSize: 16.sp),
                        ),
                      if (slogan != null)
                        Text(
                          slogan ?? "",
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                              fontSize: 12.sp),
                        ),
                      if (sloganWidget != null) sloganWidget!,
                    ],
                  ),
                ),
                if (rightIcon != null)
                  Container(
                    margin: EdgeInsets.only(right: 10),
                    child: Icon(
                      rightIcon,
                      size: 20,
                      color: rightIconStyle ??
                          Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
              ],
            ),
          ),
          if (bottomSpacer != null)
            SizedBox(
              height: bottomSpacer,
            )
        ],
      ),
    );
  }
}
