import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kids_app_grad/screens/child_profile/child_profile.dart';
import 'package:kids_app_grad/screens/games_screen/shape_game_screen.dart';
import 'package:kids_app_grad/screens/home_screen/home_screen.dart';
import 'package:kids_app_grad/utils/assets_manager.dart';
import 'package:kids_app_grad/utils/colors_manager.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  final List<Widget> screens = const [
    HomeScreen(),
    ShapeGameScreen (),
    ChildProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25)
            ),
            child: BottomNavigationBar(
              backgroundColor: ColorManager.white,
              elevation: 0,
              currentIndex: currentIndex,
              selectedItemColor: ColorManager.brown,
              unselectedItemColor: Colors.grey,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              onTap: (value) {
                setState(() {
                  currentIndex = value;
                });
              },
              items: [
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    AssetsManager.home,
                    width: 24,
                    height: 24,
                    color: currentIndex == 0
                        ? ColorManager.brown
                        : Colors.grey,
                  ),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.videogame_asset_outlined,
                    color: currentIndex == 1
                        ? ColorManager.brown
                        : Colors.grey,
                  ),
                  label: "Games",
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.person_outline,
                    color: currentIndex == 2
                        ? ColorManager.brown
                        : Colors.grey,
                  ),
                  label: "Profile",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}