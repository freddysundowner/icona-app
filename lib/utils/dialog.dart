import 'package:flutter/material.dart';

Future<bool> showConfirmationDialog(
  BuildContext context,
  String message, {
  String positiveResponse = "Yes",
  String negativeResponse = "No",
  Function? function,
}) async {
  var result = await showDialog<bool>(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);

      return AlertDialog(
        content: Text(
          message,
          style: theme.textTheme.headlineSmall,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        actions: [
          TextButton(
            child: Text(
              positiveResponse,
              style: theme.textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            onPressed: () {
              if (function != null) {
                function();
              } else {
                Navigator.pop(context, true);
              }
            },
          ),
          TextButton(
            child: Text(
              negativeResponse,
              style: theme.textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.error,
              ),
            ),
            onPressed: () {
              Navigator.pop(context, false);
            },
          ),
        ],
      );
    },
  );
  return result ?? false;
}
