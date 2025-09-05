import 'package:tokshop/models/giveaway.dart';
import 'package:tokshop/models/product.dart';
import 'package:tokshop/models/user.dart';

class Order {
  final int? invoice;
  final String? id;
  final String? status;
  final UserModel? customer;
  final GiveAway? giveaway;
  final UserModel? seller;
  final List<OrderItem>? items;
  final String? servicelevel;
  final String? rate_id;
  final bool? need_label;
  final String? weight;
  final String? labelUrl;
  final int? date;
  final String? height;
  final String? scale;
  final String? length;
  final String? width;
  final String? ordertype;
  final String? tracking_url;
  final String? tracking_number;
  final String? shipment_id;
  final double? totalTax;
  final double? shippingFee;

  Order({
    this.id,
    this.giveaway,
    this.ordertype,
    this.labelUrl,
    this.status,
    this.invoice,
    this.date,
    this.rate_id,
    this.customer,
    this.seller,
    this.items,
    this.need_label,
    this.height,
    this.scale,
    this.width,
    this.weight,
    this.length,
    this.tracking_url,
    this.servicelevel,
    this.tracking_number,
    this.shipment_id,
    this.shippingFee,
    this.totalTax,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] ?? '',
      date: json['date'] ?? 0,
      giveaway:
          json['giveaway'] == null ? null : GiveAway.fromJson(json['giveaway']),
      ordertype: json['ordertype'] ?? '',
      rate_id: json['rate_id'] ?? '',
      labelUrl: json['label'] ?? '',
      height: json['height'] ?? '',
      scale: json['scale'] ?? '',
      width: json['width'] ?? '',
      weight: json['weight'] ?? '',
      tracking_url: json['tracking_url'] ?? '',
      servicelevel: json['servicelevel'] ?? '',
      tracking_number: json['tracking_number'] ?? '',
      shipment_id: json['shipment_id'] ?? '',
      shippingFee: json['shipping_fee'] == null
          ? 0.0
          : isInteger(json['shipping_fee'])
              ? json['shipping_fee'].toDouble()
              : json['shipping_fee'],
      totalTax:
          json['tax'] is int ? json['tax'].toDouble() : json['tax'] ?? 0.0,
      length: json['length'] ?? '',
      need_label: json['need_label'] ?? false,
      invoice: json['invoice'] ?? 0,
      status: json['status'],
      customer: UserModel.fromJson(json['customer']),
      seller: UserModel.fromJson(json['seller']),
      items: (json['items'] as List).map((i) => OrderItem.fromJson(i)).toList(),
    );
  }
  getOrderTotal() {
    return ordertype == 'giveaway'
        ? '0.00'
        : (items!.fold(0.0, (total, item) => total + item.subTotal) +
                (totalTax ?? 0.0) +
                (shippingFee ?? 0.0))
            .toStringAsFixed(2);
  }
}

class OrderItem {
  final String id;
  final String status;
  final String? weight;
  final String? height;
  final String? scale;
  final String? length;
  final String? width;
  final String title;
  final String createdAt;
  final int quantity;
  final double subTotal;
  final Product? product;

  OrderItem({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.title,
    required this.quantity,
    required this.subTotal,
    this.height,
    this.scale,
    this.product,
    this.width,
    this.weight,
    this.length,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['_id'],
      createdAt: json['createdAt'] ?? 0,
      status: json['status'],
      title: json['title'] ?? '',
      quantity: json['quantity'],
      subTotal: (json['price'] as num).toDouble(),
      height: json['height'] ?? '',
      scale: json['scale'] ?? '',
      width: json['width'] ?? '',
      weight: json['weight'] ?? '',
      length: json['length'] ?? '',
      product: Product.fromJson(json['productId']),
    );
  }
}
