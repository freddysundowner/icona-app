import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../models/product.dart';
import '../services/user_api.dart';

class WishListController extends GetxController {
  RxList<dynamic> favoriteProducts = RxList([]);
  var loading = false.obs;
  var favoritekey = "".obs;

  @override
  void onInit() {
    super.onInit();
    if (FirebaseAuth.instance.currentUser != null) {
      getFavoriteProducts();
    }
  }

  getFavoriteProducts() async {
    loading.value = true;
    var response = await UserAPI.getMyFavorites();
    print("response $response");

    if (response == null || response.isEmpty) {
      favoriteProducts.value = [];
    } else {
      List<Product> allProducts = response.map<Product>((e) {
        return Product.fromJson(e);
      }).toList();
      favoriteProducts.value = allProducts;
    }

    loading.value = false;
  }

  saveFavorite(String productId) async {
    var response = await UserAPI.saveFovite(productId);
    favoritekey.value = response["_id"];
  }

  deleteFavorite(String productId) async {
    await UserAPI.deleteFromFavorite(productId);
  }
}
