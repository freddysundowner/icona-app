import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/user_controller.dart';
import '../../widgets/custom_button.dart';

class Guidelines extends StatelessWidget {
  Guidelines({super.key});
  UserController userController = Get.find<UserController>();
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'lets_get_started'.tr,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'subtitle'.tr,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 20),
            _buildGuidelinesList(context),
            InkWell(
              onTap: () {
                userController.guidelinesaccepted.value =
                    !userController.guidelinesaccepted.value;
              },
              child: Row(
                children: [
                  Obx(
                    () => Checkbox(
                      value: userController.guidelinesaccepted.value,
                      onChanged: (value) {
                        userController.guidelinesaccepted.value =
                            !userController.guidelinesaccepted.value;
                      },
                      activeColor: Colors.yellow,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'disclaimer'.tr,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Center(
              child: Obx(
                () => CustomButton(
                  text: 'got_it'.tr,
                  function: userController.guidelinesaccepted.isFalse
                      ? null
                      : () {
                          userController.approveSeller(context);
                        },
                  width: MediaQuery.of(context).size.width * 0.9,
                  backgroundColor: theme.primaryColor,
                  textColor: theme.colorScheme.onPrimary,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildGuidelinesList(BuildContext context) {
    return Expanded(
      child: ListView(
        children: [
          _buildGuideline(
              icon: Icons.shield,
              title: 'honor_purchases'.tr,
              description: 'honor_purchases_desc'.tr,
              context: context),
          _buildGuideline(
              icon: Icons.block,
              title: 'no_counterfeits'.tr,
              description: 'no_counterfeits_desc'.tr,
              context: context),
          _buildGuideline(
              icon: Icons.flag,
              title: 'no_lies'.tr,
              description: 'no_lies_desc'.tr,
              context: context),
          _buildGuideline(
              icon: Icons.local_shipping,
              title: 'ship_quickly'.tr,
              description: 'ship_quickly_desc'.tr,
              context: context),
          _buildGuideline(
              icon: Icons.check_circle,
              title: 'preapproval'.tr,
              description: 'preapproval_desc'.tr,
              context: context),
        ],
      ),
    );
  }

  Widget _buildGuideline(
      {required IconData icon,
      required String title,
      required String description,
      required BuildContext context}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.onSurface),
      title: Text(
        title,
        style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        description,
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}
