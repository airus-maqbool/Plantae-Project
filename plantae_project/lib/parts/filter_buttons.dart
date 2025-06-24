import 'package:flutter/material.dart';

class FilterButton extends StatelessWidget {
  final IconData icon;
  final String filterName;
  final bool isSelected;
  final VoidCallback onPressed;

  const FilterButton({
    super.key,
    required this.icon,
    required this.filterName,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected 
                ? Color.fromARGB(255, 2, 90, 44)
                : Color.fromARGB(255, 238, 255, 240),
              border: Border.all(
                color: const Color.fromARGB(255, 2, 90, 44),
                width: 0.5,
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 20,
                color: isSelected 
                  ? Colors.white
                  : const Color.fromARGB(255, 2, 90, 44),
              ),
            ),
          ),
          SizedBox(height: 1),
          Text(
            filterName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: const Color.fromARGB(255, 2, 90, 44),
            ),
          ),
        ],
      ),
    );
  }
}
