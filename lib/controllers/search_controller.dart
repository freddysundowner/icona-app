import 'package:get/get.dart';

class BrowseController extends GetxController {
  var currentsearchtab = 0.obs;
  RxBool isKeyboardVisible = false.obs;
  RxString searchtext = ''.obs;
  @override
  void onInit() {
    ever(isKeyboardVisible, (_) => update()); // Update UI on change
    super.onInit();
  }

  void checkKeyboard() {
    isKeyboardVisible.value = Get.mediaQuery.viewInsets.bottom > 0;
  }
}
