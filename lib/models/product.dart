import 'package:tokshop/models/Review.dart';
import 'package:tokshop/models/auction.dart';
import 'package:tokshop/models/category.dart';
import 'package:tokshop/models/shippingProfile.dart';

import '../utils/utils.dart';
import 'user.dart';

class Product {
  List<String>? images;
  Auction? auction;
  ProductCategory? productCategory;
  List<String>? favorited;
  List<Review>? reviews;
  String? id;
  ShippingProfile? shipping_profile;
  String? tokshow;
  String? type;
  String? name;
  int? salescount;
  double? price;
  int? favoriteCount;
  int? quantity;
  UserModel? ownerId;
  List<String>? sizes;
  List<String>? colors;
  String? listing_type;
  String? description;
  String? reserved;
  bool? inaction;
  bool? selected;
  bool? deleted;
  double? discountedPrice;

  Product({
    this.images = const [],
    this.productCategory,
    this.shipping_profile,
    this.selected,
    this.id,
    this.name,
    this.colors,
    this.salescount,
    this.price,
    this.auction,
    this.tokshow,
    this.sizes,
    this.discountedPrice,
    this.reserved,
    this.favoriteCount,
    this.quantity,
    this.listing_type,
    this.type,
    this.reviews,
    this.ownerId,
    this.description,
    this.favorited,
    this.inaction,
  });

  htmlPrice(price) {
    return currencySymbol + price.toStringAsFixed(0);
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    print(json["shipping_profile"]);
    return Product(
      images: json["images"] == null
          ? []
          : List<String>.from(json["images"] ?? [].map((x) => x.toString())),
      sizes: json["sizes"] == null
          ? []
          : List<String>.from(json["sizes"] ?? [].map((x) => x.toString())),
      colors: json["colors"] == null
          ? []
          : List<String>.from(json["colors"] ?? [].map((x) => x.toString())),
      id: json["_id"],
      tokshow: json["tokshow"] ?? '',
      salescount: json["salesCount"] ?? 0,
      name: json["name"] ?? "",
      shipping_profile: json["shipping_profile"] is Map
          ? ShippingProfile.fromJson(json["shipping_profile"] ?? {})
          : null,
      selected: false,
      reserved: json['reserved'] ?? 'public',
      price: json["price"] != null && isInteger(json["price"]) == true
          ? json["price"].toDouble()
          : json["price"],
      quantity: json["quantity"] == null
          ? 0
          : isInteger(json["quantity"]) == true
              ? int.parse(json["quantity"].toString())
              : json["quantity"].toInt(),
      favoriteCount: json["favoriteCount"] ?? 0,
      type: json["type"] ?? "tokshop",
      favorited: json["favorited"] == null
          ? []
          : List<String>.from(json["favorited"].map((x) => x.toString())),
      reviews: json["reviews"] == null
          ? []
          : List<Review>.from(json["reviews"].map((x) => Review.fromMap(x))),
      ownerId: json["ownerId"] is Map
          ? UserModel.fromJson(json["ownerId"] ?? {})
          : null,
      description: json["description"],
      listing_type: json["listing_type"] ?? '',
      discountedPrice: json["discountedPrice"] == null
          ? 0
          : json["discountedPrice"] != null
              ? isInteger(json["discountedPrice"]) == true
                  ? json["discountedPrice"].toDouble()
                  : json["discountedPrice"]
              : json["price"].toDouble(),
      productCategory: json['category'] is Map
          ? ProductCategory.fromJson(json['category'])
          : null,
      auction:
          json['auction'] is Map ? Auction.fromJson(json['auction']) : null,
    );
  }

  getReviewsAverage() => reviews!.isEmpty
      ? 0.toDouble()
      : reviews!
              .map((e) => e.rating)
              .toList()
              .reduce((value, element) => value + element) /
          reviews!.length;

  Map<String, dynamic> toJson() => {
        "images": images!.map((e) => e).toList(),
        "_id": id,
        "name": name,
        "deleted": deleted,
        "price": price,
        "quantity": quantity,
        "type": type,
        "reviews":
            reviews == null ? [] : reviews!.map((e) => e.toMap()).toList(),
        "description": description,
        "listing_type": listing_type,
        "discountedPrice": discountedPrice,
      };

  int calculatePercentageDiscount() {
    int discount =
        (((price! - discountedPrice!) * 100) / discountedPrice!).round();
    return discount;
  }
}

bool isInteger(num value) => value is int || value == value.roundToDouble();
