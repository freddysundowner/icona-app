import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/utils.dart';

class CustomTextFormField extends StatelessWidget {
  TextEditingController? controller;
  String? hint;
  bool? obscureText;
  bool? autofocus;
  bool? readOnly;
  bool? validate;
  Function? onTap;
  Function? onChanged;
  String? label;
  Color? txtColor;
  double? fontsize;
  int minLines;
  Widget? suffixIcon;
  Widget? suffix;
  TextInputType? txtType;
  Widget? prefix;
  CustomTextFormField(
      {super.key,
      this.onTap,
      this.minLines = 1,
      this.obscureText,
      this.fontsize,
      this.autofocus,
      this.controller,
      this.onChanged,
      this.suffixIcon,
      this.suffix,
      this.txtType = TextInputType.multiline,
      this.prefix,
      this.txtColor = primarycolor,
      this.hint,
      this.readOnly = false,
      this.validate = false,
      this.label = ""});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label!.isNotEmpty)
          SizedBox(
            height: 0.015.sh,
          ),
        if (label!.isNotEmpty)
          Text(
            label!,
            style: TextStyle(fontSize: 14.sp),
          ),
        if (label!.isNotEmpty)
          SizedBox(
            height: 0.01.sh,
          ),
        TextFormField(
          onTap: readOnly == true && onTap != null
              ? () => onTap!() // Call onTap only if readOnly is true
              : null,
          scrollPadding: const EdgeInsets.all(0),
          obscureText: obscureText ?? false,
          textInputAction: txtType == TextInputType.number
              ? TextInputAction.done
              : (minLines > 1 ? TextInputAction.newline : TextInputAction.done),
          onFieldSubmitted: (_) {
            if (txtType == TextInputType.number) {
              FocusScope.of(context).unfocus();
            }
          },
          readOnly: readOnly ?? false,
          validator: validate == false
              ? null
              : (value) {
                  if (value == null || value.isEmpty) {
                    return 'Field required';
                  }
                  return null;
                },
          controller: controller,
          maxLines: minLines ?? 1,
          onChanged: onChanged == null
              ? null
              : (value) {
                  onChanged!(value);
                },
          minLines: minLines ?? 1,
          autofocus: autofocus ?? false,
          decoration: InputDecoration(
            suffixIcon: suffixIcon,
            suffix: suffix,
            prefix: prefix,
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: 14.sp,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0), // Border radius
              borderSide: BorderSide(
                color: theme.colorScheme.onSecondaryContainer
                    .withValues(alpha: 0.5), // Border color
                width: 1, // Border width
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: theme.colorScheme.onSecondaryContainer
                    .withValues(alpha: 0.5), // Border color when focused
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: theme.colorScheme.onSecondaryContainer
                    .withValues(alpha: 0.5), // Border color when not focused
                width: 1,
              ),
            ),
          ),
          style: TextStyle(
              color: theme.textTheme.bodyMedium?.color,
              fontSize: fontsize ?? 14.sp),
        ),
      ],
    );
  }
}
