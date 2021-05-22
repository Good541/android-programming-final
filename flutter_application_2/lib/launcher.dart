import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'home.dart';
import 'add.dart';
import 'profile.dart';
import 'schedule.dart';
import 'lcanime.dart';
 
class Launcher extends StatefulWidget {
    static const routeName = '/';
 
    @override
    State<StatefulWidget> createState() {
        return _LauncherState();
    }
}
 
class _LauncherState extends State<Launcher> {
    int _selectedIndex = 0;
    List<Widget> _pageWidget = <Widget>[
        Home(),
        Add(),
        LicensedAnime(),
        Schedule(),
        Profile(),
    ];
    List<BottomNavigationBarItem> _menuBar
    = <BottomNavigationBarItem>[
        BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.list),
            title: Text('My list'),
        ),
        BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.plusSquare),
            title: Text('Add anime'),
        ),
        BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.info),
            title: Text('Licensed anime'),
        ),
        BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.calendarAlt),
            title: Text('Schedule'),
        ),
        BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.userAlt),
            title: Text('My account'),
        ),
    ];
 
    void _onItemTapped(int index) {
        setState(() {
            _selectedIndex = index;
        });
    }
 
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: _pageWidget.elementAt(_selectedIndex),
            bottomNavigationBar: BottomNavigationBar(
                items: _menuBar,
                currentIndex: _selectedIndex,
                selectedItemColor: Theme
                    .of(context)
                    .primaryColor,
                unselectedItemColor: Colors.grey,
                onTap: _onItemTapped,
            ),
        );
    }
}