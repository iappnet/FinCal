import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  final SettingsController controller = Get.put(SettingsController());

  SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => SwitchListTile(
                  title: Text('Dark Mode'),
                  value: controller.isDarkMode.value,
                  onChanged: (value) => controller.toggleDarkMode(value),
                )),
            SizedBox(height: 20),
            Obx(() => TextFormField(
                  initialValue: controller.username.value,
                  decoration: InputDecoration(labelText: 'Username'),
                  onChanged: (value) => controller.updateUsername(value),
                )),
          ],
        ),
      ),
    );
  }
}
