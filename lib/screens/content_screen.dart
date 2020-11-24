import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zpevnik/constants.dart';
import 'package:zpevnik/utils/platform.dart';
import 'package:zpevnik/screens/home/home_screen.dart';
import 'package:zpevnik/screens/songbooks/songbooks_screen.dart';
import 'package:zpevnik/screens/user/user_screen.dart';

class ContentScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> with PlatformStateMixin {
  Widget _activeWidget;
  Color _activeColor;
  int _currentIndex;

  @override
  void initState() {
    super.initState();

    _activeWidget = const HomeScreen(key: PageStorageKey('home_screen'));
    _activeColor = blue;
    _currentIndex = 0;
  }

  @override
  Widget iOSWidget(BuildContext context) => CupertinoTabScaffold(
        tabBuilder: (context, _) => CupertinoTabView(builder: (context) => _activeWidget),
        tabBar: CupertinoTabBar(
          backgroundColor: CupertinoColors.quaternarySystemFill,
          activeColor: _activeColor,
          items: _tabBarItems,
          onTap: _indexChanged,
        ),
      );

  @override
  Widget androidWidget(BuildContext context) => Scaffold(
        body: _activeWidget,
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: _activeColor,
          items: _tabBarItems,
          currentIndex: _currentIndex,
          onTap: _indexChanged,
        ),
      );

  void _indexChanged(int index) => setState(() {
        _currentIndex = index;

        switch (index) {
          case 0:
            _activeWidget = const HomeScreen(key: PageStorageKey('home_screen'));
            _activeColor = blue;
            break;
          case 1:
            _activeWidget = const SongbooksScreen(key: PageStorageKey('songbooks_screen'));
            _activeColor = green;
            break;
          case 2:
            _activeWidget = const UserScreen(key: PageStorageKey('user_screen'));
            _activeColor = red;
            break;
        }
      });

  List<BottomNavigationBarItem> get _tabBarItems => [
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
