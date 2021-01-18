import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test_roketan/part/Defines.dart' as Defines;


class CreateSwitchBoxWidget extends StatelessWidget {
  final Color color;
  final bool active;
  final Function changeSwitch;
  final IconData icon;
  final String title;
  final int number;

  CreateSwitchBoxWidget({
    this.color,
    this.active,
    this.changeSwitch,
    this.icon,
    this.title,
    this.number,
  });

  final formatter = NumberFormat('#,##0', 'ja_JP');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: active ? 0.0 : 2.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? color : Defines.colorset['drawcolor'],
              width: active ? 5.0 : 1.0,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Switch(
              value: active,
              activeColor: color,
              activeTrackColor: color,
              inactiveThumbColor: Defines.colorset['drawcolor'],
              inactiveTrackColor: Defines.colorset['drawcolor'],
              onChanged: changeSwitch,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      icon,
                      color: active
                          ? Defines.colorset['darkdrawcolor']
                          : Defines.colorset['drawcolor'],
                    ),
                    RichText(
                      text: TextSpan(
                        text: title,
                        style: TextStyle(
                          color: active
                              ? Defines.colorset['darkdrawcolor']
                              : Defines.colorset['drawcolor'],
                          fontWeight:
                          active ? FontWeight.bold : FontWeight.normal,
                          fontSize: active ? 16.0 : 14.0,
                        ),
                      ),
                    ),
                  ],
                ),
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: formatter.format(number).toString(),
                      style: TextStyle(
                        color: active
                            ? Defines.colorset['darkdrawcolor']
                            : Defines.colorset['drawcolor'],
                        fontWeight: active ? FontWeight.bold : FontWeight.normal,
                        fontSize: active ? 16.0 : 14.0,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

