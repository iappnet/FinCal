import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsController extends GetxController {
  final storage = FlutterSecureStorage();

  var isDarkMode = false.obs;
  var username = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  void loadSettings() async {
    final darkModeValue = await storage.read(key: 'darkMode') ?? 'false';
    final savedUsername = await storage.read(key: 'username') ?? 'User';

    isDarkMode.value = darkModeValue == 'true';
    username.value = savedUsername;
  }

  void toggleDarkMode(bool value) async {
    isDarkMode.value = value;
    await storage.write(key: 'darkMode', value: value.toString());
  }

  void updateUsername(String newUsername) async {
    username.value = newUsername;
    await storage.write(key: 'username', value: newUsername);
  }
}
