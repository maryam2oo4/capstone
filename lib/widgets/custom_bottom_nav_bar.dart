import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onDestinationSelected;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final destinations = [
      _NavItem(icon: Icons.home, label: 'Home'),
      _NavItem(icon: Icons.sports_esports, label: "Let's Play"),
      _NavItem(icon: Icons.volunteer_activism, label: 'Donate', isCenter: true),
      _NavItem(icon: Icons.contact_mail, label: 'Contact'),
      _NavItem(icon: Icons.person, label: 'Profile'),
    ];

    return Material(
      elevation: 16,
      shadowColor: Colors.black38,
      surfaceTintColor: Colors.white,
      child: Container(
        height: 72,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(destinations.length, (index) {
            final item = destinations[index];
            final isSelected = selectedIndex == index;

            return Expanded(
              child: GestureDetector(
                onTap: () => onDestinationSelected(index),
                child: SizedBox(
                  width: 74,
                  height: 72,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (item.isCenter && isSelected)
                        // Center item highlight circle - RED filled with white icon
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF01010),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(item.icon, size: 24, color: Colors.white),
                        )
                      else
                        Icon(
                          item.icon,
                          size: 24,
                          color: isSelected
                              ? const Color(0xFFF01010)
                              : Colors.grey[600],
                        ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? const Color(0xFFF01010)
                              : Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final bool isCenter;

  _NavItem({required this.icon, required this.label, this.isCenter = false});
}
