import 'package:flutter/material.dart';

class SharedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Gradient gradient;
  final List<Widget>? actions;
  final TextStyle? textStyle; // Corrected from List<TextStyle> to TextStyle

  const SharedAppBar({
    super.key,
    required this.title,
    this.gradient = const LinearGradient(
      colors: [Colors.blueAccent, Colors.purpleAccent],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    this.actions,
    this.textStyle, // Updated parameter
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: textStyle ??
            Theme.of(context)
                .textTheme
                .headlineMedium, // Default fallback style
      ),
      centerTitle: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          // borderRadius: BorderRadius.only(
          //   bottomLeft: Radius.circular(15),
          //   bottomRight: Radius.circular(15),
          // ),
          boxShadow: [
            BoxShadow(
                color: Colors.black26,
                spreadRadius: 3,
                blurRadius: 8,
                offset: Offset(0, 4)),
          ],
        ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
