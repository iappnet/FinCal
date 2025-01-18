import 'package:flutter/material.dart';

class CollapsibleSection extends StatelessWidget {
  final String title;
  final Widget child;

  const CollapsibleSection({
    required this.title,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
          vertical: 4.0), // Adjust margins for cleaner spacing
      decoration: BoxDecoration(
        color: Colors.white, // Match the background color
        borderRadius: BorderRadius.circular(8.0), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.1), // Subtle shadow for better visuals
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent), // Remove the divider line
        child: ExpansionTile(
          title: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          tilePadding: EdgeInsets.symmetric(
              horizontal: 16.0, vertical: 8.0), // Adjust padding
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
