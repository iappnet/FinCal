import 'package:fincals/app/utils/shared_appbar.dart';
import 'package:flutter/cupertino.dart';
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
      appBar: SharedAppBar(
        title: 'settings'.tr, // Translated title
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        textStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: CupertinoPageScaffold(
        backgroundColor: CupertinoColors.systemGrey6, // Change background color
        child: SafeArea(
          child: ListView(
            children: [
              // Username Section
              CupertinoListSection(
                header: Text(
                  'account_settings'.tr, // Localized
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 7, 0, 7),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) =>
                                UsernameEditScreen(controller: controller),
                          ),
                        );
                      },
                      child: CupertinoFormRow(
                        prefix: Text(
                          'name'.tr, // Localized
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        child: Obx(
                          () {
                            final isArabic =
                                Localizations.localeOf(context).languageCode ==
                                    'ar';

                            return Stack(
                              children: [
                                // The Text widget, dynamically aligned
                                Align(
                                  alignment: isArabic
                                      ? Alignment.centerLeft
                                      : Alignment.centerRight,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      right: isArabic
                                          ? 0
                                          : 18.0, // Add padding for icon
                                      left: isArabic
                                          ? 18.0
                                          : 0, // Add padding for icon
                                    ),
                                    child: Text(
                                      controller.username.value,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: CupertinoColors.inactiveGray,
                                      ),
                                      overflow: TextOverflow
                                          .ellipsis, // Prevent overflow
                                    ),
                                  ),
                                ),
                                // The Icon, fixed to the right
                                // The Icon, perfectly centered horizontally with the text
                                Positioned(
                                  right: isArabic ? null : 0,
                                  left: isArabic ? 0 : null,
                                  top: 0,
                                  bottom: 0,
                                  child: Icon(
                                    CupertinoIcons.forward,
                                    size: 18.0,
                                    color: CupertinoColors.inactiveGray,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Auto-Save Image Section
              CupertinoListSection(
                header: Text(
                  'image_settings'.tr, // Localized
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                children: [
                  CupertinoFormRow(
                    prefix: Text(
                      'auto_save_image'.tr,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: Obx(
                      () => CupertinoSwitch(
                        value: controller.isAutoSaveImage.value,
                        onChanged: (value) =>
                            controller.toggleAutoSaveImage(value),
                        activeTrackColor: CupertinoColors.activeGreen,
                      ),
                    ),
                  ),
                ],
              ),

              // Dark Mode Section
              CupertinoListSection(
                header: Text(
                  'display_settings'.tr, // Localized
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                children: [
                  CupertinoFormRow(
                    prefix: Text(
                      'dark_mode'.tr,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: Obx(
                      () => CupertinoSwitch(
                        value: controller.isDarkMode.value,
                        onChanged: (value) {
                          controller.toggleDarkMode(value);
                          Get.changeTheme(
                            value ? ThemeData.dark() : ThemeData.light(),
                          );
                        },
                        activeTrackColor: CupertinoColors.activeGreen,
                      ),
                    ),
                  ),
                ],
              ),
              // Preferred Language Section
              CupertinoListSection(
                header: Text(
                  'preferred_language'.tr, // Localized
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                children: [
                  CupertinoFormRow(
                    prefix: Row(
                      children: [
                        Icon(CupertinoIcons.globe,
                            color: CupertinoColors.activeBlue, size: 20.0),
                        SizedBox(width: 10.0),
                        Text('language'.tr),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 7, 0, 7),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => _LanguagePickerScreen(),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              LocalizationService.getCurrentLanguage(),
                              style: TextStyle(
                                fontSize: 16.0,
                                color: CupertinoColors.inactiveGray,
                              ),
                            ),
                            Icon(CupertinoIcons.forward,
                                size: 18.0,
                                color: CupertinoColors.inactiveGray),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguagePickerScreen extends StatefulWidget {
  @override
  _LanguagePickerScreenState createState() => _LanguagePickerScreenState();
}

class _LanguagePickerScreenState extends State<_LanguagePickerScreen> {
  late List<String> languages;

  @override
  void initState() {
    super.initState();

    // Reorder the language list based on the current locale
    languages = List<String>.from(LocalizationService.langs);
    final currentLanguage = LocalizationService.getCurrentLanguage();
    languages.remove(currentLanguage);
    languages.insert(0, currentLanguage); // Move current language to the top
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('preferred_language'.tr),
        previousPageTitle: 'settings'.tr,
      ),
      child: SafeArea(
        child: Material(
          color: Colors
              .transparent, // Ensures the background matches Cupertino style
          child: ReorderableListView(
            onReorder: (int oldIndex, int newIndex) {
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                final String item = languages.removeAt(oldIndex);
                languages.insert(newIndex, item);

                // Automatically set the top language as the main language
                LocalizationService.changeLocale(languages.first);

                // Update the app's locale
                Get.updateLocale(
                    LocalizationService.getLocaleFromLanguage(languages.first));
              });
            },
            children: List.generate(
              languages.length,
              (index) {
                final isCurrentLanguage = languages[index] ==
                    LocalizationService.getCurrentLanguage();
                return Container(
                  key: ValueKey(languages[index]), // Essential for reordering
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: CupertinoColors.systemGrey4,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                      languages[index],
                      style: TextStyle(
                        color: CupertinoColors.black,
                      ),
                    ),
                    subtitle: isCurrentLanguage
                        ? Text(
                            'current_language'
                                .tr, // Localized for "Current Language"
                            style: TextStyle(color: CupertinoColors.activeBlue),
                          )
                        : null,
                    trailing: ReorderableDragStartListener(
                      index: index,
                      child: Icon(
                        CupertinoIcons.bars,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class UsernameEditScreen extends StatelessWidget {
  final TextEditingController textController = TextEditingController();
  final SettingsController controller;

  UsernameEditScreen({super.key, required this.controller}) {
    textController.text = controller.username.value;
  }

  @override
  Widget build(BuildContext context) {
    // Helper function to check if the text is Arabic
    bool isArabic(String text) {
      final arabicRegex = RegExp(r'[\u0600-\u06FF]');
      return arabicRegex.hasMatch(text);
    }

    // Detect app language for placeholder alignment
    final isAppArabic = Localizations.localeOf(context).languageCode == 'ar';

    // ValueNotifier for dynamic alignment based on text type
    final ValueNotifier<bool> isArabicNotifier = ValueNotifier<bool>(
      isArabic(textController.text),
    );

    final ValueNotifier<bool> isPlaceholderVisible = ValueNotifier<bool>(
      textController.text.isEmpty,
    );

    return Scaffold(
      backgroundColor: CupertinoColors.systemGrey6,
      appBar: SharedAppBar(
        title: 'name'.tr,
        gradient: const LinearGradient(
          colors: [Colors.blueAccent, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      body: PopScope(
        canPop: true, // Allow navigation pop
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) {
            // Save the username when the pop is confirmed
            final updatedName = textController.text.trim().isNotEmpty
                ? textController.text.trim()
                : 'guest'.tr;
            controller.saveUsername(updatedName);
          }
          // You can optionally return a value or proceed with further logic
          return; // Pass the result back
        },
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Stack(
              children: [
                // CupertinoTextField Container for consistent layout
                CupertinoTextField(
                  controller: textController,
                  autofocus: true,
                  // textAlign:
                  //     isArabicNotifier.value ? TextAlign.right : TextAlign.left,
                  // textDirection:
                  //     isAppArabic ? TextDirection.rtl : TextDirection.ltr,
                  onChanged: (value) {
                    isPlaceholderVisible.value = value.isEmpty;
                    isArabicNotifier.value = isArabic(value);
                    controller.username.value = value;
                  },
                  onSubmitted: (value) {
                    final updatedName =
                        value.trim().isNotEmpty ? value.trim() : 'guest'.tr;
                    controller.saveUsername(updatedName);
                    Navigator.pop(context);
                  },
                  clearButtonMode: OverlayVisibilityMode.editing,
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    // border: Border.all(
                    //   color: CupertinoColors.systemGrey4,
                    //   width: 1.0,
                    // ),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 14.0),
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: CupertinoColors.black,
                  ),
                ),
                // Placeholder with correct alignment
                ValueListenableBuilder<bool>(
                  valueListenable: isPlaceholderVisible,
                  builder: (context, isVisible, child) {
                    return Visibility(
                      visible: isVisible,
                      child: Positioned.fill(
                        child: Align(
                          alignment: isAppArabic
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(
                              'enter_your_name'.tr,
                              style: const TextStyle(
                                color: CupertinoColors.systemGrey3,
                                fontSize: 16.0,
                              ),
                              textAlign: isAppArabic
                                  ? TextAlign.right
                                  : TextAlign.left,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
