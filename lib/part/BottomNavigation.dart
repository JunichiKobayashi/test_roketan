import 'package:flutter/material.dart';
import 'package:test_roketan/part/DataManager.dart';
import 'package:test_roketan/part/Defines.dart' as Defines;


class BottomNavigation extends StatelessWidget {
  final Function onItemTapped;
  BottomNavigation({
    Key key,
    this.onItemTapped,
  }): super(key: key);

  ViewDataManager _vdm = ViewDataManager();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      iconSize: 48.0,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Defines.colorset['backgroundcolor'],
      selectedItemColor: Defines.colorset['highlightcolor'],
      unselectedItemColor: Defines.colorset['drawcolor'],
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.location_on),
          title: Text('',style: TextStyle(fontSize: 0.0),),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark),
          title: Text('',style: TextStyle(fontSize: 0.0),),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          title: Text('',style: TextStyle(fontSize: 0.0),),
        ),
      ],
      currentIndex: _vdm.getViewData('selectedBN'),
      onTap: this.onItemTapped,
    );
  }
}
