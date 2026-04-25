import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kids_app_grad/screens/home_page_parent/chat_ai/chat_ai.dart';
import 'package:kids_app_grad/screens/home_page_parent/dashboard_screen/dashboard_screen.dart';
import 'package:kids_app_grad/utils/assets_manager.dart';
import 'package:kids_app_grad/utils/colors_manager.dart';

class HomePageParent extends StatefulWidget {
  const HomePageParent({super.key});

  @override
  State<HomePageParent> createState() => _HomePageParentState();
}

class _HomePageParentState extends State<HomePageParent> {
  int currentIndex = 0;

  final List<Widget> screens = [
    const DashboardScreen(),
     ChatAi(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentIndex == 0 ? "Dashboard" : "Chat AI",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: screens[currentIndex],

      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, -2)
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,

          showSelectedLabels: false,
          showUnselectedLabels: false,

          currentIndex: currentIndex,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },

          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset(AssetsManager.frame2, height: 24),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(AssetsManager.frame, height: 24),
              label: "",
            ),
          ],
        ),
      ),
    );
  }
}