import 'package:flutter/material.dart';

class CategoryButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool selected;
  final VoidCallback? onTap;
  final Color selectedColor;
  final Color unselectedColor;

  const CategoryButton({
    super.key,
    required this.icon,
    required this.text,
    this.selected = false,
    this.onTap,
    this.selectedColor = const Color.fromARGB(255, 156, 39, 176),
    this.unselectedColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              selected ? selectedColor.withOpacity(0.2) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? selectedColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? selectedColor : Colors.black,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: selected ? selectedColor : Colors.black,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryBar extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;
  final Color selectedColor;

  const CategoryBar({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.selectedColor = const Color.fromARGB(255, 156, 39, 176),
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'icon': Icons.check, 'text': 'All'},
      {'icon': Icons.work, 'text': 'Workshop'},
      {'icon': Icons.palette, 'text': 'Art'},
      {'icon': Icons.sports_soccer, 'text': 'Sports'},
      {'icon': Icons.celebration, 'text': 'Festival'},
      {'icon': Icons.music_note, 'text': 'Music'},
      {'icon': Icons.food_bank, 'text': 'Food'},
      {'icon': Icons.school, 'text': 'Education'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            const SizedBox(width: 8), // Left padding
            ...categories.map((category) {
              final text = category['text'] as String;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CategoryButton(
                  icon: category['icon'] as IconData,
                  text: text,
                  selected: selectedCategory == text,
                  onTap: () => onCategorySelected(text),
                  selectedColor: selectedColor,
                ),
              );
            }),
            const SizedBox(width: 8), // Right padding
          ],
        ),
      ),
    );
  }
}
