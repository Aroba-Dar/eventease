import 'package:flutter/material.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  double _minPrice = 20;
  double _maxPrice = 500;
  // double _minDistance = 5;
  // double _maxDistance = 40;
  String selectedLocation = "New York, United States";

  List<String> categories = [
    "All",
    "Music",
    "Workshops",
    "Art",
    "Food & Drink",
    "Fashion"
  ];
  List<String> selectedCategories = ["All"];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 16),
          Text("Event Category",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8,
            children: categories.map((category) {
              bool isSelected = selectedCategories.contains(category);
              return ChoiceChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (category == "All") {
                      selectedCategories = ["All"];
                    } else {
                      selectedCategories.remove("All");
                      if (selected) {
                        selectedCategories.add(category);
                      } else {
                        selectedCategories.remove(category);
                      }
                    }
                    if (selectedCategories.isEmpty) {
                      selectedCategories = ["All"];
                    }
                  });
                },
              );
            }).toList(),
          ),
          SizedBox(height: 16),
          Text("Ticket Price Range",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          RangeSlider(
            values: RangeValues(_minPrice, _maxPrice),
            min: 20,
            max: 500,
            divisions: 10,
            labels: RangeLabels("$_minPrice", "$_maxPrice"),
            onChanged: (RangeValues values) {
              setState(() {
                _minPrice = values.start;
                _maxPrice = values.end;
              });
            },
          ),
          SizedBox(height: 16),
          Text("Location",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            value: selectedLocation,
            onChanged: (String? newValue) {
              setState(() {
                selectedLocation = newValue!;
              });
            },
            items: ["New York, United States", "Los Angeles, CA", "Chicago, IL"]
                .map((String location) {
              return DropdownMenuItem<String>(
                value: location,
                child: Text(location),
              );
            }).toList(),
          ),
          SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedCategories = ["All"];
                    _minPrice = 20;
                    _maxPrice = 500;
                    // _minDistance = 5;
                    // _maxDistance = 40;
                    selectedLocation = "New York, United States";
                  });
                },
                child: Text("Reset"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Apply"),
              ),
            ],
          )
        ],
      ),
    );
  }
}

void showFilterSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => FilterBottomSheet(),
  );
}
