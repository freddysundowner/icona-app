import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tokshop/main.dart';
import 'package:tokshop/models/category.dart';
import 'package:tokshop/models/giveaway.dart';
import 'package:tokshop/models/interests.dart';
import 'package:tokshop/models/shippingProfile.dart';
import 'package:tokshop/models/tokshow.dart';
import 'package:tokshop/services/give_away_api.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/product.dart';
import '../pages/success_page.dart';
import '../services/dynamic_link_services.dart';
import '../services/firestore_files_access_service.dart';
import '../services/local_files_access_service.dart';
import '../services/product_api.dart';
import '../services/recently_used_categories.dart';
import '../services/user_api.dart';
import '../utils/configs.dart';
import '../widgets/choose_category.dart';
import '../widgets/loadig_page.dart';
import 'auction_controller.dart';

enum ImageType {
  local,
  network,
}

class CustomImage {
  ImageType imgType;
  final String path;
  CustomImage({this.imgType = ImageType.local, required this.path});
  @override
  String toString() {
    return "Instance of Custom Image: {imgType: $imgType, path: $path}";
  }
}

class ProductController extends GetxController
    with GetTickerProviderStateMixin {
  Rxn<Product> currentProduct = Rxn();
  Rxn<Product> productObservable = Rxn();
  RxList<Product> relatedProducts = RxList([]);
  RxList<Product> marketplaceProducts = RxList([]);
  RxInt productdetailsTabIndex = RxInt(0);
  RxInt inventoryTabIndex = RxInt(0);
  RxInt allProductsCount = RxInt(0);
  RxInt currentProductIndexSwiper = RxInt(0);
  RxInt liveactivetab = RxInt(0);
  RxList<Product> allproducts = RxList([]);
  RxList<Product> homeallproducts = RxList([]);
  RxList<Product> roomallproducts = RxList([]);
  RxList<Product> profileproducts = RxList([]);
  RxList<Product> interestsProducts = RxList([]);
  RxList<Product> favoriteProducts = RxList([]);
  RxList<Product> channelProducts = RxList([]);
  Rxn<ProductCategory> currentCategory = Rxn();
  RxList<ProductCategory> categories = RxList([]);
  RxList<Interests> subcategories = RxList([]);

  RxBool showsearch = RxBool(false);
  var searchEnabled = false.obs;
  var products = [].obs;
  var loading = false.obs;
  var productTab = "buy_now".obs;
  final forFieldsKey = GlobalKey<FormState>();
  var loadingRelatedProducts = false.obs;
  var reserve = false.obs;
  var manage = false.obs;
  var loadingSingleProduct = false.obs;
  var loadingcateries = false.obs;
  var isGridView = true.obs;
  var loadingproducts = false.obs;
  var showingCategories = false.obs;
  RxList<Interests> pickedProductCategories = RxList([]);

  var availableColors = [
    {"name": "Red", "color": Colors.red},
    {"name": "Blue", "color": Colors.blue},
    {"name": "Green", "color": Colors.green},
    {"name": "Yellow", "color": Colors.yellow},
    {"name": "Black", "color": Colors.black},
    {"name": "White", "color": Colors.white},
    {"name": "Purple", "color": Colors.purple},
    {"name": "Orange", "color": Colors.orange},
    {"name": "Gray", "color": Colors.grey},
  ].map<Map<String, dynamic>>((e) => e as Map<String, dynamic>).toList().obs;

  var selectedColors = <String>[].obs;

  var availableSizes = ["XS", "S", "M", "L", "XL", "XXL", "XXXL"].obs;
  var selectedSizes = <String>[].obs;

  RxList<Product> inventorySelectedProducts = RxList([]);
  RxList<Product> myIventory = RxList([]);
  var userProductsLoading = false.obs;
  RxInt selectedPage = 0.obs;
  RxInt selectedFilterCategory = 0.obs;
  RxString selectedFilterCategoryTab = "".obs;
  Rxn<ProductCategory> expanded = Rxn(null); //for filter>
  Rxn<Interests> selectedInterest = Rxn(null);
  Rxn<ProductCategory> selectedCategory = Rxn(null);
  Rxn<ShippingProfile> shippingprofile = Rxn(null);
  Rxn<Tokshow> selectedTokshow = Rxn(null);
  var error = "".obs;
  Product get product => productObservable.value!;
  set product(Product value) => productObservable.value = value;
  TextEditingController searchText = TextEditingController();

  final TextEditingController colorFieldController = TextEditingController();
  final TextEditingController qtyFieldController = TextEditingController();
  final TextEditingController discoountedPrice = TextEditingController();
  final TextEditingController shippingprofileFieldController =
      TextEditingController();
  final TextEditingController categoryFieldController = TextEditingController();
  final TextEditingController selectedshowController = TextEditingController();
  final TextEditingController startingPriceFieldController =
      TextEditingController();
  final TextEditingController titleFieldController = TextEditingController();
  final TextEditingController discountPriceFieldController =
      TextEditingController();
  final TextEditingController originalPriceFieldController =
      TextEditingController();
  final TextEditingController variantFieldController = TextEditingController();
  final TextEditingController sellerFieldController = TextEditingController();
  final TextEditingController highlightsFieldController =
      TextEditingController();
  final TextEditingController desciptionFieldController =
      TextEditingController();
  Rxn<TabController> tabController = Rxn(null);
  var page = ''.obs;
  var tabIndex = 0.obs;

  var isScrroll = true.obs;
  var searchPageNumber = 1.obs;
  final homepageScroller = ScrollController();
  final searchController = ScrollController();
  final marketplacecontroller = ScrollController();
  RxList<CustomImage> selectedImages = RxList([]);
  RxList<CustomImage> selectedVides = RxList([]);
  final _selectedImages = [].obs;
  final ScrollController listActiveScrollController = ScrollController();
  final ScrollController listScrollController = ScrollController();
  final ScrollController gridScrollController = ScrollController();
  set initialSelectedImages(List<CustomImage> images) {
    _selectedImages.value = images;
  }

  void setSelectedImageAtIndex(CustomImage image, int index) {
    if (index < selectedImages.length) {
      selectedImages[index] = image;
    }
  }

  void addNewSelectedImage(CustomImage image) {
    _selectedImages.add(image);
  }

  final ScrollController categoriesScrollController = ScrollController();
  var categoriesPageNumber = 1.obs;
  var hasMoreCategories = true.obs;

  final RxList<ProductCategory> recentCategories = <ProductCategory>[].obs;

  Future<void> addRecent(ProductCategory cat) async {
    // prevent duplicates
    int i = recentCategories.indexWhere((c) => c.id == cat.id);
    if (i != -1) {
      recentCategories.removeAt(i);
    }
    recentCategories.insert(0, cat);

    // limit to last 5
    if (recentCategories.length > 5) {
      recentCategories.removeLast();
    }
    await RecentCategoryService.saveRecents(recentCategories);
  }

  Future<void> loadRecents() async {
    recentCategories.value = await RecentCategoryService.loadRecents();
  }

  @override
  void onInit() {
    super.onInit();
    tabController.value = TabController(
      initialIndex: tabIndex.value,
      length: 2,
      vsync: this,
    );
    categoriesScrollController.addListener(() {
      // If at (or near) the bottom, attempt to load more
      if (categoriesScrollController.position.pixels >=
              categoriesScrollController.position.maxScrollExtent - 200 &&
          !loadingcateries.value &&
          hasMoreCategories.value) {
        // Increment page, then fetch again
        categoriesPageNumber.value++;
        getCategories(page: categoriesPageNumber.value.toString());
      }
    });
    listScrollController.addListener(() {
      final position = listScrollController.position;
      if (position.pixels >= position.maxScrollExtent - 200 &&
          !loading.value &&
          isScrroll.isTrue) {
        loadMoreProducts();
      }
    });
    listActiveScrollController.addListener(() {
      final position = listActiveScrollController.position;
      if (position.pixels >= position.maxScrollExtent - 200 &&
          !loading.value &&
          isScrroll.isTrue) {
        loadMoreProducts();
      }
    });
    gridScrollController.addListener(() {
      final position = gridScrollController.position;
      if (position.pixels >= position.maxScrollExtent - 200 &&
          !loading.value &&
          isScrroll.isTrue) {
        loadMoreProducts();
      }
    });
  }

  @override
  void onClose() {
    categoriesScrollController.dispose();
    gridScrollController.dispose();
    listScrollController.dispose();
    super.onClose();
  }

  Future<void> loadMoreProducts() async {
    // Don’t fetch if we’re already loading or there’s no more data
    if (!isScrroll.value || loading.value) return;

    try {
      loading.value = true;
      var response;
      // Replace with whatever arguments you need
      if (page.value == "myinventory") {
        response = await ProductPI.getAllroducts(
            searchPageNumber.value.toString(),
            userid: FirebaseAuth.instance.currentUser!.uid,
            status: productController.inventoryTabIndex.value == 0
                ? "active"
                : "inactive");
      } else {
        response = await ProductPI.getAllroducts(
          searchPageNumber.value.toString(),
        );
      }

      // Convert the response to Product objects
      final List list = response["products"] ?? [];
      final List<Product> fetched =
          list.map((e) => Product.fromJson(e)).toList();

      // Append new items
      myIventory.addAll(fetched);

      // If fewer than 15 items, probably no more pages
      if (fetched.length < 15) {
        isScrroll.value = false; // no more data
      } else {
        // otherwise, increment page so next load is the next page
        searchPageNumber.value++;
      }
    } catch (e) {
      print("Error loading more inventory: $e");
    } finally {
      loading.value = false;
    }
  }

  Future<void> addVideoButtonCallback(BuildContext context,
      {int? index, ImageSource? imgSource}) async {
    String path =
        await choseImageFromLocalFiles(imgSource: imgSource, isVideo: true);
    selectedVides.add(CustomImage(imgType: ImageType.local, path: path));
  }

  Future<void> addImageButtonCallback(BuildContext context,
      {int? index, ImageSource? imgSource}) async {
    String path = await choseImageFromLocalFiles(imgSource: imgSource);
    if (index == null) {
      selectedImages.add(CustomImage(imgType: ImageType.local, path: path));
    } else {
      if (index < selectedImages.length) {
        selectedImages[index] =
            CustomImage(imgType: ImageType.local, path: path);
      }
    }
  }

  Future<void> getCategories({
    String page = "1",
    String type = "",
    String title = "",
    String limit = "15",
  }) async {
    if (page == "1") {
      categories.clear();
      hasMoreCategories.value = true;
      categoriesPageNumber.value = 1; // reset page number
    }

    loadingcateries.value = true;

    var response = await ProductPI.getCategories(
      page: page,
      type: type,
      title: title,
      limit: limit,
    );
    List list = response['categories'] ?? [];
    final fetchedCategories =
        list.map((e) => ProductCategory.fromJson(e)).toList();
    categories.addAll(fetchedCategories);
    if (fetchedCategories.length < int.parse(limit)) {
      hasMoreCategories.value = false;
    }
  }

  deleteProduct(List<String?> product, BuildContext context) async {
    try {
      LoadingOverlay.showLoading(context);
      await ProductPI.deleteProduct(product);
      Get.back();
      LoadingOverlay.hideLoading(context);
    } catch (e) {
      LoadingOverlay.hideLoading(context);
    } finally {
      inventorySelectedProducts.clear();
    }
  }

  addToFavorite(Product product) async {
    int? i = product.favorited?.indexWhere(
        (element) => element == FirebaseAuth.instance.currentUser!.uid);

    if (i != -1) {
      product.favorited?.removeAt(i!);
      UserAPI.deleteFromFavorite(product.id!);
    } else {
      product.favorited?.add(FirebaseAuth.instance.currentUser!.uid);
      UserAPI.saveFovite(product.id!);
    }
    myIventory.refresh();
  }

  getProductsByUserId({String userId = "", String status = "active"}) async {
    try {
      loading.value = true;
      isScrroll.value = true;
      var response =
          await ProductPI.getAllroducts("1", userid: userId, status: status);
      loading.value = false;
      List list = response["products"];
      List<Product> products = list.map((e) => Product.fromJson(e)).toList();
      myIventory.value = products;
    } catch (e) {
      print(e);
    }
  }

  getAllroducts(
      {String page = "1",
      String category = "",
      String saletype = "",
      String auction = "",
      String roomid = "",
      String userid = "",
      String status = "",
      String type = "",
      String title = "",
      String limit = "15",
      bool featured = false}) async {
    try {
      searchPageNumber.value = 1;
      allProductsCount.value = 0;
      isScrroll.value = true;
      loading.value = true;
      var response = await ProductPI.getAllroducts(page,
          title: title,
          saletype: saletype,
          roomid: roomid,
          featured: featured,
          category: category,
          userid: userid,
          limit: limit,
          status: status);
      List list = response["products"];
      List<Product> products = list.map((e) => Product.fromJson(e)).toList();
      if (type == "home") {
        homeallproducts.clear();
        homeallproducts.value = products;
        homeallproducts.refresh();
      } else if (type == "room") {
        roomallproducts.clear();
        roomallproducts.value = products;
        roomallproducts.refresh();
      } else {
        myIventory.value = products;
        myIventory.refresh();
      }
      if (response["totalDoc"] > allproducts.length) {
        searchPageNumber.value++;
      } else {
        isScrroll.value = false;
      }
      allProductsCount.value = response["totalDoc"];
    } finally {
      loading.value = false;
    }
  }

  getProductCategories({String page = "1", String title = ""}) async {
    try {
      allproducts.clear();
      searchPageNumber.value = 1;
      isScrroll.value = true;
      loadingproducts.value = true;
      var response = await ProductPI.getAllroducts(page, title: title);

      List list = response["products"];
      allproducts.value = list.map((e) => Product.fromJson(e)).toList();
      if (response["totalDoc"] > allproducts.length) {
        searchPageNumber.value++;
      }
      loadingproducts.value = false;
      refresh();
    } catch (e) {
      loadingproducts.value = false;
    }
  }

  Future<void> fetchUserProducts() async {
    try {
      userProductsLoading.value = true;
      myIventory.value = [];
      var response = await ProductPI.getAllroducts("1",
          userid: FirebaseAuth.instance.currentUser!.uid);
      List products = response["products"];
      if (products.isNotEmpty) {
        for (var i = 0; i < products.length; i++) {
          myIventory.add(products.elementAt(i));
        }
      } else {
        myIventory.value = [];
      }
      myIventory.refresh();
      userProductsLoading.value = false;

      update();
    } catch (e) {
      userProductsLoading.value = false;
    }
  }

  _validateProduct() {
    print(shippingprofile.value);
    if (titleFieldController.text.isEmpty) {
      return "please_enter_title".tr;
    } else if (desciptionFieldController.text.isEmpty) {
      return "please_enter_description".tr;
    } else if (originalPriceFieldController.text.isEmpty &&
        productTab.value == "buy_now") {
      return "please_enter_a_price".tr;
    } else if (qtyFieldController.text.isEmpty) {
      return "please_enter_quantity".tr;
    } else if (shippingprofile.value == null) {
      return "please_select_shipping_profile".tr;
    }

    return null;
  }

  Map<String, dynamic> _populateProductData(type, {String? tokshow = ""}) {
    return {
      "name": titleFieldController.text,
      "price": originalPriceFieldController.text,
      'reserved': reserve.isTrue ? 'private' : "public",
      'tokshow': tokshow!.isNotEmpty ? tokshow : selectedTokshow.value?.id,
      "quantity": qtyFieldController.text,
      "discountedPrice": discoountedPrice.text,
      "description": desciptionFieldController.text,
      'shipping_profile': shippingprofile.value?.id,
      "userId": FirebaseAuth.instance.currentUser!.uid,
      'colors': selectedColors.map((e) => e).toList(),
      'sizes': selectedSizes.map((e) => e).toList(),
      'startingPrice': originalPriceFieldController.text,
      'sudden': Get.find<AuctionController>().suddentAuction.value,
      'duration': Get.find<AuctionController>().selectedSeconds.value,
      "status": type,
      "listing_type": productTab.value,
      "category": selectedCategory.value?.id
    };
  }

  saveProductAuction(Product? product, BuildContext context) async {
    try {
      String error = "";
      if (titleFieldController.text.isEmpty) {
        return "please_enter_title".tr;
      } else if (originalPriceFieldController.text.isEmpty &&
          productTab.value == "buy_now") {
        return "please_enter_a_price".tr;
      } else if (qtyFieldController.text.isEmpty) {
        return "please_enter_quantity".tr;
      }
      if (error.isNotEmpty) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: Text(
              _validateProduct(),
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      reserve.value = true;
      Map<String, dynamic> productdata = _populateProductData('active',
          tokshow: tokShowController.currentRoom.value!.id!);
      var resppose;
      LoadingOverlay.showLoading(context);
      if (product != null) {
        if (product.listing_type == "auction") {
          productdata['auction'] = product.auction?.id;
        }
        resppose = await ProductPI.updateProduct(productdata, product.id!);
      } else {
        resppose = await ProductPI.saveProduct(productdata);
      }
      reserve.value = false;
      print(resppose);
      if (resppose != null && resppose["data"] != null) {
        await uploadImages(resppose["data"]['_id'], context);
        Get.back();
        getAllroducts(
            roomid: tokShowController.currentRoom.value!.id!,
            type: 'room',
            saletype: "auction");
        clearProductFields();
        LoadingOverlay.hideLoading(context);
      } else {
        LoadingOverlay.hideLoading(context);
      }
    } catch (e) {
      clearProductFields();
    }
  }

  _saveProduct(type, Product? product) async {
    if (_validateProduct() == null) {
      Map<String, dynamic> productdata = _populateProductData(type);
      if (productTab.value == "giveaway") {
        productdata['user'] = FirebaseAuth.instance.currentUser!.uid;
        productdata['whocanenter'] = giveAwayController.whocanenter.value;
        productdata['duration'] = 300;
        if (giveAwayController.giveawayid.isNotEmpty) {
          productdata['id'] = giveAwayController.giveawayid.value;
          giveAwayController.giveawayid.value = "";
          return await GiveAwayApi.updateGiveAway(productdata);
        }
        return await GiveAwayApi.saveGiveAway(productdata);
      }
      if (product != null) {
        return await ProductPI.updateProduct(productdata, product.id!);
      } else {
        return await ProductPI.saveProduct(productdata);
      }
    } else {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text(
            _validateProduct(),
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  uploadImages(id, context) async {
    List<String> urls = await uploadImagesToFirebase(id);
    if (urls.isNotEmpty) {
      if (productTab.value == "giveaway") {
        return await GiveAwayApi.updateGiveAwayImages(id, urls);
      }
      final updateProductFuture =
          await ProductPI.updateProductsImages(id, urls);
      return updateProductFuture;
    }
  }

  shareProduct(Product product) async {
    String url = DynamicLinkService().generateShareLink(product.id!);
    await Share.share(url, subject: "Share ${product.name!}");
  }

  Future<void> saveProduct(BuildContext context, type, Product? product,
      {String? from}) async {
    if (productTab.value != "buy_now" && selectedTokshow.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'add_at_least_one_tokshow'.tr,
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (selectedImages.isEmpty && productTab.value == "buy_now") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'add_atleast_one_image'.tr,
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (selectedCategory.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'add_at_least_one_category'.tr,
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    LoadingOverlay.showLoading(context);
    var response = await _saveProduct(type, product);
    if (response == null) {
      LoadingOverlay.hideLoading(context);
      return;
    }

    if (response != null) {
      if (productTab.value == "giveaway") {
        if (response["data"] is List) {
          List ids = response["data"];

          for (var id in ids) {
            await uploadImages(id, context);
          }
        } else {
          if (response["data"]['_id'] == null) {
            return;
          }
          await uploadImages(response["data"]['_id'], context);
        }
      } else {
        await uploadImages(
            product != null ? product.id! : response["data"]['_id'], context);
      }
    }
    if (productTab.value == "giveaway" && selectedTokshow.value!.id != null) {
      giveAwayController.getGiveAways(room: selectedTokshow.value!.id!);
    }
    if (productTab.value == "buy_now" && selectedTokshow.value != null) {
      getAllroducts(
        roomid: selectedTokshow.value!.id!,
        type: 'room',
        saletype: "buy_now",
      );
    }
    clearProductFields();
    LoadingOverlay.hideLoading(context);
    Get.back();
    if (from != 'room') {
      getAllroducts(
          page: '1',
          userid: FirebaseAuth.instance.currentUser!.uid,
          type: 'myinventory',
          status: type);
      Get.to(() => SuccessPage(
            title: type == 'active' ? 'item_listed'.tr : "drafted".tr,
            functionbtnone: () {
              Get.back();
            },
            functionbtntwo: () {
              Get.back();
            },
            buttonOnetext: "view_listing".tr,
            buttonTwotext: "add_another".tr,
          ));
    }
  }

  deleteImageFromFirebase(int index) {
    if (selectedImages[index].imgType == ImageType.network) {
      FirestoreFilesAccess().deleteFileFromPath(
          ProductPI.getPathForProductImage(
              productObservable.value!.id!, index));
    }
  }

  Future<List<String>> uploadImagesToFirebase(String id, {String? path}) async {
    List<String> urls = [];
    for (int i = 0; i < selectedImages.length; i++) {
      if (selectedImages[i].imgType == ImageType.local) {
        final imgUploadFuture = await FirestoreFilesAccess().uploadFileToPath(
            File(selectedImages[i].path),
            path ?? ProductPI.getPathForProductImage(id, i));
        urls.add(imgUploadFuture);
      } else {
        urls.add(selectedImages[i].path);
      }
    }
    return urls;
  }

  Future<List<String>> uploadVideosToFirebase(String id, {String? path}) async {
    List<String> urls = [];
    for (int i = 0; i < selectedVides.length; i++) {
      if (selectedVides[i].imgType == ImageType.local) {
        final imgUploadFuture = await FirestoreFilesAccess().uploadFileToPath(
            File(selectedVides[i].path),
            path ?? ProductPI.getPathForProductImage(id, i));
        urls.add(imgUploadFuture);
      }
    }
    return urls;
  }

  getProductById(Product product) async {
    loadingSingleProduct.value = true;
    var response = await ProductPI().getProductById(product.id!);
    currentProduct.value = Product.fromJson(response);
    currentProduct.value!.images = product.images;
    currentProduct.refresh();
    loadingSingleProduct.value = false;
  }

  getRelatedProductByInterest(Product product) async {
    loadingRelatedProducts.value = true;
    var response = await ProductPI.getAllroducts(
      "1",
      limit: "15",
    );
    List list = response["products"];
    relatedProducts.value = list.map((e) => Product.fromJson(e)).toList();
    relatedProducts.refresh();
    loadingRelatedProducts.value = false;
  }

  void clearProductFields() {
    titleFieldController.text = '';

    variantFieldController.text = '';

    originalPriceFieldController.text = '';

    qtyFieldController.text = '';
    desciptionFieldController.text = "";
    selectedCategory.value = null;
    categoryFieldController.text = '';
    discoountedPrice.text = "";
    selectedSizes.value = [];
    selectedColors.value = [];
    selectedImages.value = [];
  }

  void populateProductFields({Product? product, GiveAway? giveaway}) {
    if (giveaway != null) {
      productTab.value = "giveaway";
      product = Product(
          id: giveaway.id,
          name: giveaway.name,
          quantity: giveaway.quantity?.toInt(),
          description: giveaway.description,
          productCategory: giveaway.category,
          listing_type: "giveaway",
          shipping_profile: giveaway.shipping_profile,
          images: giveaway.images);
      giveAwayController.whocanenter.value = giveaway.whocanenter ?? "everyone";
      giveAwayController.giveawayid.value = giveaway.id!;
    }
    titleFieldController.text = product!.name!;

    originalPriceFieldController.text = product.price.toString();

    qtyFieldController.text = product.quantity.toString();
    desciptionFieldController.text = product.description ?? "";
    shippingprofileFieldController.text = product.shipping_profile?.name ?? "";
    reserve.value = product.reserved == "private" ? true : false;
    selectedCategory.value = product.productCategory;
    productTab.value = product.listing_type!;
    shippingprofile.value = product.shipping_profile;
    categoryFieldController.text = product.productCategory?.name != null
        ? product.productCategory!.name!
        : "";
    if (product.discountedPrice != null) {
      discoountedPrice.text =
          product.discountedPrice != null || product.discountedPrice! <= 0
              ? product.discountedPrice.toString()
              : "";
    }
    selectedSizes.value = product.sizes != null ? product.sizes! : [];
    selectedColors.value = product.colors ?? [];
    selectedImages.value = product.images!
        .map((e) => CustomImage(path: e, imgType: ImageType.network))
        .toList();
  }

  void assingLiveShow(BuildContext context, {bool showOptions = false}) {
    ChooseTokshow(context, showOptions: showOptions,
        function: (Tokshow tokshow) {
      List<String?> products =
          inventorySelectedProducts.map((p) => p.id).toList();
      updateManyProducts(products, context,
          {'tokshow': tokshow.id, 'listing_type': productTab.value});
    });
  }

  updateManyProducts(List<String?> list, BuildContext context, payload) async {
    try {
      LoadingOverlay.showLoading(context);
      var response = await ProductPI.updateManyProducts(list, payload);
      Get.back();
      LoadingOverlay.hideLoading(context);
    } catch (e) {
      LoadingOverlay.hideLoading(context);
    } finally {
      inventorySelectedProducts.clear();
    }
  }

  // void importShopify(BuildContext context) async {
  //   try {
  //     LoadingOverlay.showLoading(context);
  //     var response = await ProductPI.importShopify();
  //     print(response);
  //     LoadingOverlay.hideLoading(context);
  //   } catch (e) {
  //     LoadingOverlay.hideLoading(context);
  //   }
  // }

  void importWc(BuildContext context) async {
    try {
      LoadingOverlay.showLoading(context);
      var response = await ProductPI.importWcPproducts();
      userController.getWcSettings(authController.usermodel.value!.id!);
      userController.wcTotalProducts();
      print(response);
      LoadingOverlay.hideLoading(context);
    } catch (e) {
      LoadingOverlay.hideLoading(context);
    }
  }

  void connectWcStore() async {
    var webbaseUrl = userController.urlController.text;
    if (webbaseUrl.isEmpty) {
      Get.showSnackbar(
        GetSnackBar(
          message: 'please_enter_website_url'.tr,
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.TOP,
        ),
      );
      return;
    }
    var siteulr = 'https://$webbaseUrl/wp-json/tokshop/v1/authorize';
    if (userController.wcSettigs["wcConsumerKey"] == null) {
      var uri =
          "$siteulr?id=${authController.usermodel.value!.id}&callback=$baseUrl&app_name=$appName";
      print("connectWcStore $uri");
      launchUrl(Uri.parse(uri));
      Get.back();
      return;
    }
  }
}
