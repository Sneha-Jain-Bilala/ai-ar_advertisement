import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'explore_screen.dart';
import 'home_screen.dart';
import 'offers_screen.dart';
import 'profile_screen.dart';
import 'saved_ads_screen.dart';

class ConsumerMainNav extends StatefulWidget {
  final int initialIndex;

  const ConsumerMainNav({super.key, this.initialIndex = 0});

  @override
  State<ConsumerMainNav> createState() => _ConsumerMainNavState();
}

class _ConsumerMainNavState extends State<ConsumerMainNav> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    HomeScreen(),
    ExploreScreen(),
    OffersScreen(),
    SavedAdsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(top: 24),
        child: FloatingActionButton(
          elevation: 6,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          shape: const CircleBorder(),
          onPressed: () {
            context.push('/scanner');
          },
          child: const Icon(Icons.qr_code_scanner_rounded, size: 28),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: BottomAppBar(
          color: AppColors.surface,
          elevation: 0,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
                _buildNavItem(1, Icons.explore_rounded, Icons.explore_outlined, 'Explore'),
                const SizedBox(width: 44), // Notch gap for floating QR button
                _buildNavItem(2, Icons.local_offer_rounded, Icons.local_offer_outlined, 'Offers'),
                _buildNavItem(3, Icons.bookmark_rounded, Icons.bookmark_border_rounded, 'Saved'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              size: 24,
              color: isSelected ? AppColors.primary : AppColors.textTertiary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textTertiary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
