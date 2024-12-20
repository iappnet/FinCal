import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';

void main() {
  runApp(
    GetMaterialApp(
      title: "Salary Calculator",
      initialRoute: AppPages.INITIAL, // Start with the MAIN route
      debugShowCheckedModeBanner: false,
      getPages: AppPages.routes, // Use the defined routes
      theme: ThemeData.light(), // Optional: Apply light theme globally
    ),
  );
}
