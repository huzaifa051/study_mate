import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final VoidCallback onHome;
  final VoidCallback onInsights;
  final VoidCallback onAdd;

  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onHome,
    required this.onInsights,
    required this.onAdd,
  });

  Widget _navIcon({
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: AnimatedScale(
            scale: active ? 1.15 : 1.0,
            duration: const Duration(milliseconds: 250),
            child: Icon(
              icon,
              size: 28,
              color: active ? AppColors.forest : AppColors.muted,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: SizedBox(
          height: 78,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppColors.hairline),
                  ),
                  child: Row(
                    children: [
                      _navIcon(
                        icon: Icons.home_rounded,
                        active: currentIndex == 0,
                        onTap: onHome,
                      ),
                      const SizedBox(width: 80),
                      _navIcon(
                        icon: Icons.show_chart,
                        active: currentIndex == 1,
                        onTap: onInsights,
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                top: 0,
                child: GestureDetector(
                  onTap: onAdd,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.clay,
                      border: Border.all(color: AppColors.stone, width: 4),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
