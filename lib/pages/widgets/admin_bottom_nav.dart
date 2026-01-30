import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:rumahsakitapp/routes/app_routes.dart';

class AdminBottomNav extends StatelessWidget {
  final int currentIndex;

  const AdminBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navItem(
            context,
            index: 0,
            icon: Icons.home_rounded,
            route: AppRoutes.adminDashboard,
          ),
          _navItem(
            context,
            index: 1,
            icon: LucideIcons.stethoscope,
            route: AppRoutes.manageDoctor,
          ),
          _navItem(
            context,
            index: 2,
            icon: Icons.person_rounded,
            route: AppRoutes.adminProfile,
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String route,
  }) {
    final bool isActive = currentIndex == index;

    return GestureDetector(
      onTap: () {
        if (!isActive) {
          Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF3F6DF6).withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 26,
              color: isActive ? const Color(0xFF3F6DF6) : Colors.grey,
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 4,
              width: isActive ? 18 : 0,
              decoration: BoxDecoration(
                color: const Color(0xFF3F6DF6),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
