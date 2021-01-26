
import 'package:flutter/material.dart';
import 'package:test_roketan/part/Defines.dart' as Defines;


class CreateSearchBoxWidget extends StatelessWidget {
  final String hitText;
  final Function onChanged;
  final Function onSubmitted;
  CreateSearchBoxWidget({
    this.hitText,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(40),
      ),
      child: true
          ? Container(
        alignment: Alignment.center,
        height: 60,
        child: Text(
          '準備中...',
          style: TextStyle(color: Defines.colorset['drawcolor']),
        ),)
          : TextField(
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsetsDirectional.only( start: 10.0 ),
            child: Icon(
              Icons.search,
              color: Defines.colorset['drawcolor'],
              size: 40.0,
            ),
          ),
          hintStyle: TextStyle(fontSize: 20),
          hintText: hitText,
          suffixIcon: Padding(
            padding: EdgeInsetsDirectional.only( end: 20.0 ),
            child: IconButton(
              icon: Icon(
                Icons.highlight_remove,
                color: Defines.colorset['darawcolor'],
                size: 24.0,
              ),
              onPressed: null,
            ),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.fromLTRB(10, 20, 60, 20),
        ),
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      ),
    );
  }
}
