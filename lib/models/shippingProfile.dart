import 'package:tokshop/models/product.dart';

class ShippingProfile {
  late String id;
  late String name;
  late double weight;
  late String scale;
  late String taxCode;

  ShippingProfile({
    required this.id,
    required this.taxCode,
    required this.name,
    required this.weight,
    required this.scale,
  });

  ShippingProfile.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    taxCode = json['taxCode'] ?? "txcd_99999999";
    name = json['name'];
    weight =
        isInteger(json['weight']) ? json['weight'].toDouble() : json['weight'];
    scale = json['scale'];
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "weight": weight,
        "scale": scale,
        "taxCode": taxCode,
      };
}
