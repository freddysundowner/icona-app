import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/custom_button.dart';

class SuccessPage extends StatelessWidget {
  String? title;
  Function functionbtnone;
  Function functionbtntwo;
  String? bigtitle;
  String? buttonOnetext;
  String? buttonTwotext;
  SuccessPage(
      {super.key,
      this.title,
      required this.functionbtnone,
      required this.functionbtntwo,
      this.bigtitle,
      this.buttonOnetext,
      this.buttonTwotext});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.close,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: () {
              Get.back();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120, // Adjust to match the screenshot
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          theme.primaryColor,
                          theme.primaryColor,
                          theme.colorScheme.secondary,
                          // Colors.green.withOpacity(0.4),
                          // Colors.green.withOpacity(0.2),
                          // Colors.green,
                        ],
                        stops: [0.1, 0.6, 1.0],
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          size: 50,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Center(
                    child: Text(
                      bigtitle ?? 'congrats'.tr,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    title ?? "",
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 30,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (buttonOnetext != null)
                    Expanded(
                      child: CustomButton(
                        text: buttonOnetext ?? "",
                        function: () {
                          functionbtnone();
                        },
                        backgroundColor: Colors.transparent,
                        borderColor: theme.dividerColor,
                      ),
                    ),
                  SizedBox(width: 16),
                  if (buttonTwotext != null)
                    Expanded(
                      child: CustomButton(
                        text: buttonTwotext ?? "",
                        function: () {
                          functionbtntwo();
                        },
                        backgroundColor: theme.colorScheme.primary,
                        textColor: Colors.black,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
