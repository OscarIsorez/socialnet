import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: false,
      items: [
        BottomNavigationBarItem(
          icon: SvgPicture.asset('assets/earth.svg', height: 24),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset('assets/search.svg', height: 24),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset('assets/scroll.svg', height: 24),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset('assets/send.svg', height: 24),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset('assets/profile.svg', height: 24),
          label: '',
        ),
      ],
    );
  }

  /// Helper method to get the title for each tab index
  static String getTitleForIndex(int index) {
    switch (index) {
      case 0:
        return 'Discover';
      case 1:
        return 'Search';
      case 2:
        return 'Discover';
      case 3:
        return 'Messages';
      case 4:
        return 'Profile';
      default:
        return 'Redemton';
    }
  }
}
