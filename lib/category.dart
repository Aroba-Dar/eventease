import 'package:flutter/material.dart';

// A button widget to represent a category
class CategoryButton extends StatelessWidget {
  final IconData icon; // Icon to display in the button
  final String text; // Text label for the category
  final bool selected; // Indicates if the category is selected
  final VoidCallback? onTap; // Callback when the button is tapped
  final Color selectedColor; // Color for the selected state
  final Color unselectedColor; // Color for the unselected state

  const CategoryButton({
    super.key,
    required this.icon,
    required this.text,
    this.selected = false,
    this.onTap,
    this.selectedColor =
        const Color.fromARGB(255, 156, 39, 176), // Default purple color
    this.unselectedColor = Colors.grey, // Default grey color
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Trigger the callback when tapped
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 8), // Button padding
        decoration: BoxDecoration(
          color: selected
              ? selectedColor
                  .withOpacity(0.2) // Light background for selected state
              : Colors
                  .grey.shade200, // Light grey background for unselected state
          borderRadius: BorderRadius.circular(20), // Rounded corners
          border: Border.all(
            color: selected
                ? selectedColor
                : Colors.transparent, // Border color for selected state
            width: 1.5, // Border width
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Minimize the row size
          children: [
            Icon(
              icon, // Display the category icon
              size: 18,
              color: selected
                  ? selectedColor
                  : Colors.black, // Icon color based on selection
            ),
            const SizedBox(width: 8), // Space between icon and text
            Text(
              text, // Display the category text
              style: TextStyle(
                color: selected
                    ? selectedColor
                    : Colors.black, // Text color based on selection
                fontWeight: selected
                    ? FontWeight.bold
                    : FontWeight.normal, // Bold text for selected state
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// A horizontal bar to display multiple category buttons
class CategoryBar extends StatelessWidget {
  final String selectedCategory; // Currently selected category
  final Function(String)
      onCategorySelected; // Callback when a category is selected
  final Color selectedColor; // Color for the selected category

  const CategoryBar({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.selectedColor = const Color.fromARGB(255, 156, 39, 176),
  });

  @override
  Widget build(BuildContext context) {
    // List of categories with their icons and labels
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
      scrollDirection: Axis.horizontal, // Enable horizontal scrolling
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: 4), // Vertical padding for the bar
        child: Row(
          children: [
            const SizedBox(width: 8), // Left padding
            ...categories.map((category) {
              final text = category['text'] as String; // Extract category text
              return Padding(
                padding:
                    const EdgeInsets.only(right: 8), // Space between buttons
                child: CategoryButton(
                  icon: category['icon'] as IconData, // Category icon
                  text: text, // Category text
                  selected: selectedCategory ==
                      text, // Check if the category is selected
                  onTap: () =>
                      onCategorySelected(text), // Trigger callback on tap
                  selectedColor: selectedColor, // Pass the selected color
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
