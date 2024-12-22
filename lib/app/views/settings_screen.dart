import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../services/localization_service.dart';
import '../utils/shared_appbar.dart';

class SettingsScreen extends StatelessWidget {
  final SettingsController controller = Get.put(SettingsController());

  SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final langs = LocalizationService.langs;
    return Scaffold(
      appBar: SharedAppBar(
        title: 'settings'.tr, // Localized
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      // AppBar(
      //   title: Text('settings'.tr), // Localized
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Username Section
            Row(
              children: [
                Expanded(
                  child: Obx(() => TextFormField(
                        enabled: controller.isEditingName.value,
                        initialValue: controller.username.value,
                        decoration: InputDecoration(
                          labelText: 'username'.tr, // Localized
                          hintText: 'enter_your_name'.tr, // Localized
                        ),
                        onChanged: (value) =>
                            controller.tempUsername.value = value,
                      )),
                ),
                SizedBox(width: 8),
                Obx(() => ElevatedButton(
                      onPressed: () {
                        if (controller.isEditingName.value) {
                          controller.saveUsername();
                        } else {
                          controller.isEditingName.value = true;
                        }
                      },
                      child: Text(controller.isEditingName.value
                          ? 'save'.tr
                          : 'edit'.tr), // Localized
                    )),
              ],
            ),
            SizedBox(height: 20),

            // Dark Mode Toggle
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => SwitchListTile(
                      title: Text('dark_mode'.tr), // Localized
                      value: controller.isDarkMode.value,
                      onChanged: (value) {
                        controller.toggleDarkMode(value);
                        Get.changeTheme(
                          value ? ThemeData.dark() : ThemeData.light(),
                        );
                      },
                    )),
                SizedBox(height: 20),

                // Auto-Save Image Toggle
                Obx(() => SwitchListTile(
                      title: Text('auto_save_image'.tr), // Localized
                      value: controller.isAutoSaveImage.value,
                      onChanged: (value) =>
                          controller.toggleAutoSaveImage(value),
                    )),
                SizedBox(height: 20),
              ],
            ),
            // Language Dropdown

            DropdownButton<String>(
              value: LocalizationService.getCurrentLanguage(),
              onChanged: (value) {
                if (value != null) {
                  LocalizationService().changeLocale(value);
                }
              },
              items: langs
                  .map((lang) =>
                      DropdownMenuItem(value: lang, child: Text(lang)))
                  .toList(),
            )
          ],
        ),
      ),
    );
  }
}
