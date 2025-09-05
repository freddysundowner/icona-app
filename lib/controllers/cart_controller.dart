import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartController extends GetxController {
  // Cart items
  final RxList<Map<String, dynamic>> cartItems = <Map<String, dynamic>>[
    {
      'name': 'Tunic',
      'price': 250,
      'color': Colors.green,
      'size': 'X',
      'imageUrl': 'assets/images/productavatar.jpeg',
      'quantity': 1,
    },
  ].obs;

  final RxDouble shippingCost = 20.0.obs;

  // Calculate subtotal
  double get subtotal => cartItems.fold(
      0, (sum, item) => sum + (item['price'] * item['quantity']));

  // Calculate total
  double get total => subtotal + shippingCost.value;
  RxString selectedsize = "".obs;
  RxString selectedcolor = "".obs;
  // Increase quantity
  void increaseQuantity(int index) {
    cartItems[index]['quantity']++;
    cartItems.refresh();
  }

  // Decrease quantity
  void decreaseQuantity(int index) {
    if (cartItems[index]['quantity'] > 1) {
      cartItems[index]['quantity']--;
      cartItems.refresh();
    }
  }
}
