import 'package:flutter/material.dart';
import 'package:needlinc/needlinc/business-pages/marketplace.dart';
import 'package:needlinc/needlinc/shared-pages/notifications.dart';
import 'package:needlinc/needlinc/business-pages/profile.dart';
import 'package:needlinc/needlinc/needlinc-variables/colors.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:needlinc/needlinc/business-pages/home.dart';
import 'package:needlinc/needlinc/shared-pages/people.dart';

class BusinessMainPages extends StatefulWidget {
  int? currentPage;
  BusinessMainPages({super.key, required this.currentPage});

  @override
  State<BusinessMainPages> createState() => _FreelancerMainPagesState();
}

class _FreelancerMainPagesState extends State<BusinessMainPages> {
  int? _currentPage;
  @override
  void initState() {
    // implement initState
    _currentPage = (widget.currentPage ?? 0);
    super.initState();
  }

  // This List is for Icons that are active
  final List<IconData> _activeIcons = [
    Icons.home,
    Icons.shopping_cart,
    Icons.work,
    Icons.notifications,
    Icons.person,
  ];

  // This List is for Icons that are inactive
  final List<IconData> _inactiveIcons = [
    Icons.home_outlined,
    Icons.shopping_cart_outlined,
    Icons.work_outline,
    Icons.notifications_none,
    Icons.person_outline,
  ];

  // This is widget switches pages on a selected tap
  Widget PageTransition(int currentPage) {
    switch (currentPage) {
      case 0:
        return const HomePage();
      case 1:
        return const MarketplacePage();
      case 2:
        return const PeoplePage();
      case 3:
        return const NotificationsPage();
      case 4:
        return const ProfilePage();
      default:
        return const HomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // This is the Bottom Navigation bar
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: NeedlincColors.black3,
        animationDuration: const Duration(milliseconds: 400),
        onTap: (index) {
          setState(() {});
          _currentPage = index;
        },
        items: List.generate(
          _activeIcons.length,
          (index) {
            return _currentPage == index
                ? Icon((_activeIcons[index]), color: NeedlincColors.blue1)
                : (Icon(_inactiveIcons[index]));
          },
        ),
      ),
      // This is the App Body
      body: PageTransition(_currentPage!),
    );
  }
}
