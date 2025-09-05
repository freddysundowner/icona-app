import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../models/ShippingAddress.dart';

var imageplaceholder = "assets/images/image_placeholder.jpg";

printOut(data) {
  if (kDebugMode) {
    print(data);
  }
}

getAddress(ShippingAddress customerAddress) {
  return "${customerAddress.addrress1}, ${customerAddress.city},\n ${customerAddress.state}, ${customerAddress.country}";
}

const Map<String, String> isoCountryMap = {
  "United States": "US",
  "Kenya": "KE",
  "Canada": "CA",
  "United Kingdom": "GB",
  "Germany": "DE",
  "France": "FR",
};

String getCountryCodeFromPickerValue(String pickerValue) {
  // Remove emoji flag
  String cleanName = pickerValue.replaceAll(RegExp(r'[^\w\s]'), '').trim();

  return isoCountryMap[cleanName] ?? cleanName; // fallback if not found
}

getShortForm(double number, {int decimal = 1}) {
  var shortForm = "";
  if (number < 1000) {
    shortForm = number.toStringAsFixed(decimal);
  } else if (number >= 1000 && number < 1000000) {
    shortForm = "${(number / 1000).toStringAsFixed(decimal)}K";
  } else if (number >= 1000000 && number < 1000000000) {
    shortForm = "${(number / 1000000).toStringAsFixed(decimal)}M";
  } else if (number >= 1000000000 && number < 1000000000000) {
    shortForm = "${(number / 1000000000).toStringAsFixed(decimal)}B";
  }
  return shortForm;
}

String convertTime(String time) {
  var convertedTime = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
  final f = DateFormat('dd MMM, yyyy hh:mm');
  return f.format(DateTime.fromMillisecondsSinceEpoch(
      convertedTime.millisecondsSinceEpoch));
}
