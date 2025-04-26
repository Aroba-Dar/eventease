import 'package:flutter/material.dart';

class CategoryButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool selected;
  final VoidCallback? onTap;

  const CategoryButton({
    super.key,
    required this.icon,
    required this.text,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: selected ? Colors.white : Colors.black),
            const SizedBox(width: 6),
            Text(text,
                style:
                    TextStyle(color: selected ? Colors.white : Colors.black)),
          ],
        ),
      ),
    );
  }
}

class CategoryBar extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryBar({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'icon': Icons.check, 'text': 'All'},
      {'icon': Icons.music_note, 'text': 'Workshop'},
      {'icon': Icons.palette, 'text': 'Art'},
      {'icon': Icons.build, 'text': 'Sports'},
      {'icon': Icons.build, 'text': 'Festival'},
      {'icon': Icons.build, 'text': 'Music'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final text = category['text'] as String;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CategoryButton(
              icon: category['icon'] as IconData,
              text: text,
              selected: selectedCategory == text,
              onTap: () => onCategorySelected(text),
            ),
          );
        }).toList(),
      ),
    );
  }
}
