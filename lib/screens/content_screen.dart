import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zpevnik/utils/platform_state.dart';
import 'package:zpevnik/screens/home_screen.dart';
import 'package:zpevnik/screens/songbooks_screen.dart';
import 'package:zpevnik/screens/user_screen.dart';

class ContentScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> with PlatformStateMixin {
  int _currentIndex;

  @override
  void initState() {
    super.initState();

    _currentIndex = 0;
  }

  @override
  Widget iOSWidget(BuildContext context) => CupertinoTabScaffold(
        tabBar: CupertinoTabBar(items: _tabBarItems(context)),
        tabBuilder: (BuildContext context, int index) =>
            _activeWidget(context, index),
      );

  @override
  Widget androidWidget(BuildContext context) => Scaffold(
        body: _activeWidget(context, _currentIndex),
        bottomNavigationBar: BottomNavigationBar(
          items: _tabBarItems(context),
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
        ),
      );

  Widget _activeWidget(BuildContext context, int index) {
    switch (index) {
      case 0:
        return HomeScreen();
      case 1:
        return SongbooksScreen();
      case 2:
        return UserScreen();
      default:
        return Container();
    }
  }

  List<BottomNavigationBarItem> _tabBarItems(BuildContext context) => [
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Vyhledávání',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.import_contacts),
          label: 'Zpěvníky',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Já',
          activeIcon: Icon(Icons.person),
        ),
      ];
}