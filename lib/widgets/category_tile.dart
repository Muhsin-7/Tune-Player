import 'package:flutter/material.dart';

class CategoryTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color borderColor;
  final Color iconColor;
  final VoidCallback onTap;

  const CategoryTile({
    super.key,
    required this.title,
    required this.icon,
    required this.borderColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        height: 90,
        margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 6),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 30),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(color: iconColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}