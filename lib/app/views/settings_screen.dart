import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../services/localization_service.dart';

class SettingsScreen extends StatelessWidget {
  final SettingsController controller = Get.put(SettingsController());

  SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr), // Localized
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Username Section
            Obx(() {
              return Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      enabled: controller.isEditingName.value,
                      initialValue: controller.username.value,
                      decoration: InputDecoration(
                        labelText: 'username'.tr, // Localized
                        hintText: 'enter_your_name'.tr, // Localized
                      ),
                      onChanged: (value) =>
                          controller.tempUsername.value = value,
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (controller.isEditingName.value) {
                        controller.saveUsername();
                      } else {
                        controller.isEditingName.value = true;
                      }
                    },
                    child: Obx(() => Text(controller.isEditingName.value
                        ? 'save'.tr
                        : 'edit'.tr)), // Localized
                  ),
                  SizedBox(height: 20),
                  // Dark Mode Toggle
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
                  // Auto-Save Image Toggle
                  SizedBox(height: 20),
                  Obx(() => SwitchListTile(
                        title: Text('auto_save_image'.tr), // Localized
                        value: controller.isAutoSaveImage.value,
                        onChanged: (value) =>
                            controller.toggleAutoSaveImage(value),
                      )),
                ],
              );
            }),
            Obx(() {
              final langs = LocalizationService.langs;
              return DropdownButton<String>(
                value: Get.locale?.languageCode == 'ar' ? 'العربية' : 'English',
                onChanged: (value) {
                  LocalizationService().changeLocale(value!);
                },
                items: langs
                    .map((lang) =>
                        DropdownMenuItem(value: lang, child: Text(lang)))
                    .toList(),
              );
            }),
          ],
        ),
      ),
    );
  }
}
