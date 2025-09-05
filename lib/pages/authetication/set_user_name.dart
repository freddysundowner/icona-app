import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../main.dart';

class UsernameSelectionPage extends StatefulWidget {
  UsernameSelectionPage({super.key}) {
    // authController.generateUsernameSuggestions();
  }

  @override
  State<UsernameSelectionPage> createState() => _UsernameSelectionPageState();
}

class _UsernameSelectionPageState extends State<UsernameSelectionPage> {
  final TextEditingController usernameController = TextEditingController();
  List<String> suggestedUsernames = [];
  generateUsernameSuggestions() {
    String name = authController.fnameFieldController.text;
    if (name.isEmpty &&
        authController.currentuser?.firstName?.isNotEmpty == true) {
      name = authController.currentuser!.firstName!;
    }
    print(authController.currentuser?.firstName);

    if (name.isEmpty) return; // Prevents infinite loop if name is empty

    final Random random = Random();
    Set<String> suggestions = {};

    // Ensure at least one suggestion is the original name
    suggestions.add(name.toLowerCase());

    // Ensure 2 usernames are without numbers (slightly modified versions)
    int attempts = 0;
    while (suggestions.length < 2 && attempts < 10) {
      String modifiedName = name.replaceAll(RegExp(r'[aeiou]'), '');
      if (modifiedName.isNotEmpty) {
        suggestions.add(modifiedName);
      }
      attempts++;
    }

    // Generate 3 usernames with random numbers
    while (suggestions.length < 5) {
      int randomNumber = random.nextInt(99);
      String newUsername = "${name.toLowerCase()}$randomNumber";

      suggestions.add(newUsername);
    }
    suggestedUsernames = suggestions.toList();
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    generateUsernameSuggestions();
    print(suggestedUsernames);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "choose_your_username".tr,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            SizedBox(height: 5.h),
            Text(
              "username_identity".trParams({'app_name': "app_name".tr}),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 20.h),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: "enter_username".tr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                ),
              ),
              onChanged: (value) {
                authController.usernameFieldController.text =
                    (value.isNotEmpty ? value : null)!;
              },
            ),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: suggestedUsernames.map((username) {
                bool isSelected =
                    authController.usernameFieldController.text == username;
                return GestureDetector(
                  onTap: () {
                    authController.usernameFieldController.text = username;
                    usernameController.text = username;
                    setState(() {});
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.yellow : Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      username,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            Spacer(),
            Obx(() => authController.isLoading.isTrue
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          authController.usernameFieldController.text.isNotEmpty
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      authController.authenticateuser(
                          authController.logintype.value, context);
                    },
                    child: Center(
                      child: Text(
                        "continue".tr,
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
