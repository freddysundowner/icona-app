import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/category.dart';

class RecentCategoryService {
  static const _key = "recent_categories";

  /// Save list of categories
  static Future<void> saveRecents(List<ProductCategory> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = categories.map((c) => c.toMap()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  /// Load list of categories
  static Future<List<ProductCategory>> loadRecents() async {
    print("loadRecents");
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    print(data);
    if (data == null) return [];
    final List list = jsonDecode(data);
    return list.map((e) => ProductCategory.fromJson(e)).toList();
  }

  /// Clear recents (optional helper)
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
