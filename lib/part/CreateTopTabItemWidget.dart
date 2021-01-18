
import 'package:flutter/material.dart';

import 'package:test_roketan/part/Defines.dart' as Defines;


class CreateTopTabItemWidget extends StatelessWidget {
  final String title;
  final bool active;
  final Function onTappedTopTab;

  CreateTopTabItemWidget({this.title, this.active, this.onTappedTopTab});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: active ? 0.0 : 2.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active
                  ? Defines.colorset['highlightcolor']
                  : Defines.colorset['drawcolor'],
              width: active ? 5.0 : 1.0,
            ),
          ),
        ),
        child: Center(
          child: FlatButton(
            child: RichText(
              text: TextSpan(
                text: title,
                style: TextStyle(
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                  color: active
                      ? Defines.colorset['highlightcolor']
                      : Defines.colorset['drawcolor'],
                  fontSize: active ? 20.0 : 16.0,
                ),
              ),
            ),
            onPressed: onTappedTopTab,
          ),
        ),
      ),
    );
  }
}
