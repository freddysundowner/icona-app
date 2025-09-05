import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

class CustomButton extends StatelessWidget {
  final Function? function;
  final String text;
  final Color? borderColor;
  final IoniconsData? ioniconsData;
  final IconData? iconData;
  final Color? textColor;
  final Color? iconColor;
  final Color? backgroundColor;
  final double? borderRadius;
  final double? fontSize;
  final double? height;
  final double? width;
  final EdgeInsets? padding;

  const CustomButton({
    Key? key,
    this.function,
    required this.text,
    this.borderColor,
    this.borderRadius,
    this.fontSize,
    this.textColor,
    this.ioniconsData,
    this.iconData,
    this.iconColor,
    this.backgroundColor,
    this.padding = EdgeInsets.zero,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    print("function: $function");

    return SizedBox(
      width: width ?? MediaQuery.of(Get.context!).size.width * 0.4,
      height: height ?? 40,
      child: ElevatedButton.icon(
        onPressed: function == null ? null : () => function!(),
        style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? Colors.transparent,
            foregroundColor: theme.colorScheme.onPrimary,
            disabledBackgroundColor: theme.colorScheme.primary.withAlpha(100),
            disabledForegroundColor: theme.colorScheme.primary.withAlpha(100),
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 25),
              side: BorderSide(
                color: borderColor ?? Colors.transparent,
                width: 1,
              ),
            ),
            padding: padding),
        icon: _buildIcon(theme),
        label: Text(
          text.tr, // Adds translation support
          style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontFamily: "Silka",
              fontSize: fontSize,
              color: textColor),
        ),
      ),
    );
  }

  Widget _buildIcon(ThemeData theme) {
    if (iconData != null) {
      return Icon(
        iconData,
        color: iconColor ?? theme.colorScheme.onPrimary,
        size: 18,
      );
    } else if (ioniconsData != null) {
      return Icon(
        ioniconsData,
        color: iconColor ?? theme.colorScheme.onPrimary,
        size: 18,
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
