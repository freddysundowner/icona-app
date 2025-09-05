import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tokshop/main.dart';
import 'package:tokshop/pages/inventory/my_inventory.dart';

class WcVendorSuccess extends StatelessWidget {
  WcVendorSuccess({super.key}) {
    userController.wcTotalProducts();
    userController.getWcSettings(authController.usermodel.value!.id!);
  }

  void toggleSync(String key, bool v) {
    userController.updateSync(key, v);
  }

  void disconnectWc() {
    userController.disconectWc();
  }

  void importProductsFromWc(BuildContext context) {
    productController.importWc(context);
  }

  @override
  Widget build(BuildContext context) {
    final wcSettings = userController.wcSettigs;
    return Scaffold(
      appBar: AppBar(
        title: Text("woocommerce_setup".tr,
            style: Theme.of(context).textTheme.headlineSmall),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _storeInfoCard(context, "connected_as".tr,
              wcSettings['site_name'] ?? 'Vendor', Icons.check_circle,
              iconColor: Colors.green),
          const SizedBox(height: 24),
          _sectionTitle(context, "overview".tr),
          Divider(
            color: Theme.of(context).dividerColor,
          ),
          Row(
            children: [
              _infoCard(
                  "imported_wc".tr,
                  userController.wcSettigs['tokshopCount'] == null
                      ? "--"
                      : userController.wcSettigs['tokshopCount'].toString()),
              Obx(
                () => _infoCard(
                    "total_wc_products".tr,
                    userController.wcSettigs['publishedProductCount'] == null
                        ? "--"
                        : userController.wcSettigs['publishedProductCount']
                            .toString()),
              ),
              const SizedBox(width: 10),
            ],
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => importProductsFromWc(context),
            icon: Icon(Icons.sync,
                color: Theme.of(context).colorScheme.onPrimary),
            label: Text("sync_products".tr),
          ),
          const SizedBox(height: 24),
          _sectionTitle(context, "settings".tr),
          Divider(
            color: Theme.of(context).dividerColor,
          ),
          // Obx(
          //   () => SwitchListTile(
          //     title: Text("auto_sync_products".tr),
          //     value: userController.wcSettigs['auto_sync_products'],
          //     onChanged: (v) => toggleSync("auto_sync_products", v),
          //   ),
          // ),
          Obx(
            () => SwitchListTile(
              title: Text("auto_sync_orders".tr),
              value: userController.wcSettigs['auto_sync_orders'] == 1 ||
                  userController.wcSettigs['auto_sync_orders'] == '1',
              onChanged: (v) => toggleSync('auto_sync_orders', v),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => disconnectWc(),
          icon: Icon(Icons.logout),
          label: Text("disconnect_woocommerce".tr),
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Expanded(
      child: InkWell(
        splashColor: Colors.transparent,
        onTap: () {
          Get.to(() => MyInventory());
        },
        child: Card(
          color: Colors.yellow.withOpacity(0.2),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
            child: Column(
              children: [
                Text(value,
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(title, style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(title,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _storeInfoCard(
      BuildContext context, String title, String subtitle, IconData icon,
      {Color? iconColor}) {
    return Card(
      elevation: 2,
      child: ListTile(
        title: Text(title, style: Theme.of(context).textTheme.titleSmall),
        subtitle: Text(subtitle),
        trailing: Icon(icon, color: iconColor),
      ),
    );
  }
}
