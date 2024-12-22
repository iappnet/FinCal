import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsController extends GetxController {
  final storage = FlutterSecureStorage();

  var isDarkMode = false.obs;
// Reactive variable for the username
  var username = 'guest'.tr.obs; // Default username using localization key
  var tempUsername = ''.obs; // Temporary storage for username edits
  var isEditingName = false.obs; // Flag to control edit mode
  var isFirstUse = true.obs; // Track if it's the first use
  var isAutoSaveImage = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  // Load settings from secure storage
  void loadSettings() async {
    final darkModeValue = await storage.read(key: 'darkMode') ?? 'false';
    final savedUsername = await storage.read(key: 'username');
    final firstUseValue = await storage.read(key: 'isFirstUse') ?? 'true';
    final autoSaveValue = await storage.read(key: 'autoSaveImage') ?? 'false';

    isDarkMode.value = darkModeValue == 'true';
    // Updating the username value with a fallback to the localized "Guest"
    username.value = savedUsername ?? 'guest'.tr; // Use the translated default
    isFirstUse.value = firstUseValue == 'true';
    isAutoSaveImage.value = autoSaveValue == 'true';
  }

  // Toggle dark mode
  void toggleDarkMode(bool value) async {
    isDarkMode.value = value;
    await storage.write(key: 'darkMode', value: value.toString());
  }

  // Save username
  void saveUsername() async {
    username.value = tempUsername.value.isNotEmpty
        ? tempUsername.value
        : 'guest'.tr; // Use localized "Guest" fallback
    await storage.write(key: 'username', value: username.value);
    isEditingName.value = false;
    // Mark as no longer the first use
    if (isFirstUse.value) {
      isFirstUse.value = false;
      await storage.write(key: 'isFirstUse', value: 'false');
    }
    // Notify user with a localized message
    Get.snackbar('success'.tr, 'username_updated'.tr);
  }

  void toggleAutoSaveImage(bool value) async {
    isAutoSaveImage.value = value;
    await storage.write(key: 'autoSaveImage', value: value.toString());
    // Notify user with a localized message
    Get.snackbar(
      'success'.tr,
      value ? 'auto_save_enabled'.tr : 'auto_save_disabled'.tr,
    );
  }
}
