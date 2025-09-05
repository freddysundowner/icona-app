import 'package:tokshop/utils/configs.dart';

class ProductCategory {
  String? name;
  String? icon;
  String? id;
  List<ProductCategory>? sub;
  int? viewersCount;
  int? followersCount;
  List<dynamic>? followers;

  ProductCategory({
    this.id,
    this.name,
    this.followers,
    this.sub,
    this.icon,
    this.viewersCount,
    this.followersCount,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "followers": followers,
      "icon": icon,
      "viewersCount": viewersCount,
      "followersCount": followersCount,
    };
  }

  factory ProductCategory.fromJson(json) {
    return ProductCategory(
      name: json['name'],
      icon: json['icon'],
      followers: json['followers'],
      sub: (json['subCategories'] is List &&
              (json['subCategories'] as List).isNotEmpty)
          ? (json['subCategories'] as List).map((x) {
              if (x is Map<String, dynamic>) {
                return ProductCategory.fromJson(x);
              } else if (x is String) {
                // fallback if API only gives an ID string
                return ProductCategory(
                  id: x,
                  name: null,
                  icon: null,
                  viewersCount: 0,
                  sub: [],
                );
              } else {
                return ProductCategory(
                  id: null,
                  name: null,
                  icon: null,
                  viewersCount: 0,
                  sub: [],
                );
              }
            }).toList()
          : [],
      viewersCount: json['viewersCount'],
      followersCount: json['followersCount'],
      id: json['_id'] ?? json['id'],
    );
  }
  String iconUrl() {
    return "$baseUrl/$icon";
  }
}
