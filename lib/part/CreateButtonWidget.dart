
import 'package:flutter/material.dart';
import 'package:test_roketan/part/Defines.dart' as Defines;


class CreateButtonWidget extends StatelessWidget {
  final String title;
  final Function onPressed;
  CreateButtonWidget({
    this.title,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: RichText(
        text: TextSpan(
          text: title,
          style: TextStyle(
              color: Defines.colorset['drawcolor'], fontSize: 14.0),
        ),
      ),
      onPressed: onPressed,
    );
  }
}
