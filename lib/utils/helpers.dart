import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:tokshop/main.dart';

String priceHtmlFormat(amount, {String? currency = '\$'}) {
  return "${currency ?? authController.usermodel.value?.currecy!.toUpperCase()}$amount";
}

dateFormat(String isoDate) {
  DateTime dateTime = DateTime.parse(isoDate);
  String formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);
  return formattedDate;
}

validateEmail(String email) {
  RegExp regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (regex.hasMatch(email)) {
    return true;
  } else {
    return false;
  }
}

Widget buildAvatar(dynamic avatar, {double? width, double? height}) {
  return SizedBox(
    width: width ?? 30,
    height: height ?? 30,
    child: CircleAvatar(
      backgroundColor: Colors.grey[700],
      backgroundImage: avatar is String && avatar.startsWith("http")
          ? NetworkImage(avatar)
          : null,
      child: (avatar is String && avatar.startsWith("http"))
          ? null // show image
          : Text(
              avatar.toString().substring(0, 1).toUpperCase(),
              style: TextStyle(color: Colors.white, fontSize: 12.sp),
            ),
    ),
  );
}
