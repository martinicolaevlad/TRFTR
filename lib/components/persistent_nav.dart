import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:sh_app/screens/favourites/favourites_screen.dart';
import 'package:sh_app/screens/home/home_screen.dart';
import 'package:sh_app/screens/inbox/inbox_screen.dart';
import 'package:sh_app/screens/profile/profile_screen.dart';
import 'package:sh_app/screens/search/search_screen.dart';
import '';

class PersistentTabScreen extends StatefulWidget {
  const PersistentTabScreen({super.key});

  @override
  State<PersistentTabScreen> createState() => _PersistentTabScreenState();
}

class _PersistentTabScreenState extends State<PersistentTabScreen> {

  late PersistentTabController _controller;

  List<Widget> _buildScreens() {
    return [
      Home(),
      Search(),
      Favourites(),
      Inbox(),
      ProfileScreen()
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: FaIcon(FontAwesomeIcons.house),
        title: "Home",
        activeColorPrimary: Colors.red.shade900,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: FaIcon(FontAwesomeIcons.magnifyingGlassDollar),
        title: "Search",
        activeColorPrimary: Colors.red.shade900,
        inactiveColorPrimary: Colors.grey,
      ),
     PersistentBottomNavBarItem(
        icon: FaIcon(FontAwesomeIcons.crown),
        title: "Favourites",
       activeColorPrimary: Colors.red.shade900,
        inactiveColorPrimary: Colors.grey,
      ),
     PersistentBottomNavBarItem(
        icon: FaIcon(FontAwesomeIcons.solidBell),
        title: "Inbox",
       activeColorPrimary: Colors.red.shade900,
        inactiveColorPrimary: Colors.grey,
      ),
     PersistentBottomNavBarItem(
        icon: FaIcon(FontAwesomeIcons.userSecret),
        title: "Profile",
        activeColorPrimary: Colors.red.shade900,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }
  @override
  void initState() {
    _controller = PersistentTabController(initialIndex: 0);
    super.initState();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'TRFTR',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        backgroundColor: Colors.red.shade900,
        elevation: 100,
      ),

      body: PersistentTabView(
        context,
        controller: _controller,
        screens: _buildScreens(),
        items: _navBarsItems(),
        confineInSafeArea: true,
        backgroundColor: Colors.grey.shade300, // Default is Colors.white.
        handleAndroidBackButtonPress: true, // Default is true.
        resizeToAvoidBottomInset: true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
        stateManagement: true, // Default is true.
        hideNavigationBarWhenKeyboardShows: true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
        decoration: NavBarDecoration(
          borderRadius: BorderRadius.circular(10.0),
          colorBehindNavBar: Colors.white,
        ),
        popAllScreensOnTapOfSelectedTab: true,
        popActionScreens: PopActionScreensType.all,
        itemAnimationProperties: ItemAnimationProperties( // Navigation Bar's items animation properties.
          duration: Duration(milliseconds: 200),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: ScreenTransitionAnimation( // Screen transition animation on change of selected tab.
          animateTabTransition: true,
          curve: Curves.ease,
          duration: Duration(milliseconds: 400),
        ),
        navBarStyle: NavBarStyle.style12, // Choose the nav bar style with this property.
      ),
    );
  }
}

