import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/client.dart';

class ShopifyIMportSettigs extends StatefulWidget {
  const ShopifyIMportSettigs({super.key});

  @override
  _ShopifyIMportSettigsState createState() => _ShopifyIMportSettigsState();
}

class _ShopifyIMportSettigsState extends State<ShopifyIMportSettigs> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _secretKeyController = TextEditingController();
  final TextEditingController _consumerKeyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Future<void> generateWooCommerceKeys() async {
    final String url = 'http://wwordppress.fwh.is/wp-json/wc/v3/keys';

    // Encode username & password for Basic Auth
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('admin:uOBXLN85lyT(2wGKe8Ja*6ZP'))}';
    var response =
        await DbBase().databaseRequest(url, DbBase().postRequestType, headers: {
      'Authorization': basicAuth,
      'Content-Type': 'application/json',
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3'
    }, body: {
      "description": "Flutter App Access",
      "permissions": "read_write"
    });
    print(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      String consumerKey = data['consumer_key'];
      String consumerSecret = data['consumer_secret'];

      print("Consumer Key: $consumerKey");
      print("Consumer Secret: $consumerSecret");

      // Save these keys securely (e.g., SharedPreferences, secure storage)
    } else {
      print("Error: ${response.statusCode} - ${response.body}");
    }
  }

  void authenticateUser() async {
    if (_formKey.currentState!.validate()) {
      String baseUrl = _urlController.text.trim();
      //ck_58839d5d2f979c4ba9ee7bddd58b745c594f5040
      //cs_8c48e22445636b88f787592f8b4c01ff424bf94c
      String consumerKey = _consumerKeyController.text.trim();
      String consumerSecret = _secretKeyController.text.trim();

      // final response = await ProductPI.importWcPproducts(
      //     consumerSecret, consumerKey, baseUrl);
      //
      // if (response.statusCode == 200) {
      //   final List<dynamic> products = jsonDecode(response.body);
      //   print("Fetched ${products.length} products");
      // } else {
      //   print(
      //       "Error fetching products: ${response.statusCode} - ${response.body}");
      // }
      // // Ensure URL is correctly formatted
      // // if (!baseUrl.startsWith("http")) {
      // baseUrl = "http://$baseUrl";
      // // }
      //
      // // Call API to fetch WooCommerce Keys
      // bool success = await fetchWooCommerceKeys(baseUrl);
      //
      // if (success) {
      //   Get.snackbar("Success", "Connected to WooCommerce successfully!",
      //       backgroundColor: Colors.green, colorText: Colors.white);
      // } else {
      //   Get.snackbar("Error", "Failed to connect. Check URL & credentials.",
      //       backgroundColor: Colors.red, colorText: Colors.white);
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("import_wc_products".tr)),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("woocommerce_url".tr),
              TextFormField(
                controller: _urlController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "enter_website_url".tr;
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: "example.com",
                  suffixIcon: Icon(Icons.web),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              Text("consumer_key".tr),
              TextFormField(
                controller: _urlController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "enter_consumer_key".tr;
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: "XXXXXXX",
                  suffixIcon: Icon(Icons.web),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              Text("consumer_secret".tr),
              TextFormField(
                controller: _urlController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "enter_consumer_secret".tr;
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: "XXXXX",
                  suffixIcon: Icon(Icons.web),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: generateWooCommerceKeys,
                child: Text("connect_import".tr),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> fetchWooCommerceKeys(String baseUrl) async {
    try {
      // Endpoint to fetch API keys from WooCommerce
      String url = "$baseUrl/wp-json/wc/v3/keys";

      // Replace with the store's admin credentials (Ideally, use OAuth or JWT)
      String username = "admin"; // Ask user to enter this
      String password = "E6Pm%(&os@V818W7RduECw3V"; // Ask user to enter this
      // Encode credentials for Basic Auth
      String basicAuth =
          "Basic ${base64Encode(utf8.encode("$username:$password"))}";
      var response = await DbBase()
          .databaseRequest(url, DbBase().getRequestType, headers: {
        "Authorization": basicAuth,
        "Content-Type": "application/json",
      }, body: {
        "description": "Flutter WooCommerce App",
        "permissions": "read_write"
      });

      if (response.statusCode == 201) {
        var data = jsonDecode(response.body);
        String consumerKey = data["consumer_key"];
        String consumerSecret = data["consumer_secret"];

        print("Consumer Key: $consumerKey");
        print("Consumer Secret: $consumerSecret");

        // TODO: Save to database for future use
        saveKeysToDatabase(baseUrl, consumerKey, consumerSecret);

        return true;
      } else {
        print("Error: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

// Example function to store keys in Firebase or your backend
  void saveKeysToDatabase(String storeUrl, String key, String secret) {
    // Call your backend API to store the keys
    print("Saving API Keys for: $storeUrl");
  }
}
