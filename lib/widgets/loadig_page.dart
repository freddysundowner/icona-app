import 'package:flutter/material.dart';

class LoadingOverlay {
  static final _keyLoader = GlobalKey<State>();

  static Future<void> showLoading(BuildContext context,
      {String? message}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      barrierColor:
          Theme.of(context).scaffoldBackgroundColor, // Transparent background
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Stack(
            children: [
              Container(
                color: Theme.of(context)
                    .scaffoldBackgroundColor, // Semi-transparent overlay
              ),
              Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.secondary),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static void hideLoading(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop(); // Dismiss the dialog
  }
}
