import 'package:flutter/material.dart';
import 'package:law_app/Hire%20Services/sub_options_details.dart';
import 'package:collection/collection.dart';

class HireServices extends StatefulWidget {
  const HireServices({super.key});

  @override
  State<HireServices> createState() => _HireServicesState();
}

class _HireServicesState extends State<HireServices> {
  String selectedCategory = "I.T";
  String? selectedSubOption;

  final List<Category> categories = [
    // Category(
    //   backgroundColor: const Color.fromRGBO(159, 129, 247, 0.15),
    //   labelColor: const Color.fromRGBO(159, 129, 247, 1.0),
    //   icon: Icons.category,
    //   title: 'All',
    //   subOptions: ['General Law', 'All Cases'],
    // ),
    Category(
      backgroundColor: const Color.fromRGBO(25, 103, 210, 0.15),
      labelColor: const Color.fromRGBO(25, 103, 210, 1.0),
      icon: Icons.computer,
      title: 'I.T',
      subOptions: ['Credit Card Claims', 'Software Disputes'],
    ),
    Category(
      backgroundColor: const Color.fromRGBO(255, 0, 0, 0.15),
      labelColor: const Color.fromRGBO(255, 0, 0, 1.0),
      icon: Icons.business,
      title: 'Consulting',
      subOptions: ['Business Contracts', 'Consultant Agreements'],
    ),
    Category(
      backgroundColor: const Color.fromRGBO(249, 171, 0, 0.15),
      labelColor: const Color.fromRGBO(249, 171, 0, 1.0),
      icon: Icons.local_hospital,
      title: 'Healthcare',
      subOptions: ['Medical Malpractice', 'Healthcare Regulations'],
    ),
    Category(
      backgroundColor: const Color.fromRGBO(52, 168, 83, 0.15),
      labelColor: const Color.fromRGBO(52, 168, 83, 1.0),
      icon: Icons.build,
      title: 'Engineering',
      subOptions: ['Construction Claims', 'Patent Disputes'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final Category? category = categories.firstWhereOrNull(
      (cat) => cat.title == selectedCategory,
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Popular Categories',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 159, 129, 247).withOpacity(1),
            ),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 100, // Adjust height as needed
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCategory = cat.title;
                    selectedSubOption =
                        null; // Reset selected sub-option when changing category
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: cat.backgroundColor,
                    border: Border.all(
                      color: selectedCategory == cat.title
                          ? cat.labelColor
                          : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        cat.icon,
                        color: cat.labelColor,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: cat.labelColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (category != null && category.subOptions.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(
              top: 25,
              left: 16,
              right: 16,
            ),
            child: Text(
              'Sub Options For ${category.title}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 159, 129, 247).withOpacity(1),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: category.subOptions.length,
              itemBuilder: (context, index) {
                final subOption = category.subOptions[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(subOption),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubOptionDetail(
                            categoryTitle: category.title,
                            subOptionTitle: subOption,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class Category {
  final Color backgroundColor;
  final Color labelColor;
  final IconData icon;
  final String title;
  final List<String> subOptions;

  Category({
    required this.backgroundColor,
    required this.labelColor,
    required this.icon,
    required this.title,
    required this.subOptions,
  });
}
