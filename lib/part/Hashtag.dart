import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:test_roketan/part/DataManager.dart';
import 'package:test_roketan/part/Defines.dart' as Defines;

ActionChip hashtagCreator(String hashtagData, [bool deleteFlag]) {
  ActionChip _hashtag;
  bool _deleteFlag = deleteFlag==null ? false : deleteFlag;

  _hashtag = ActionChip(
              label: Text('#' + hashtagData, overflow: TextOverflow.ellipsis),
              onPressed: () {
                if(_deleteFlag) {
                } else {
                  print('action');
                }
              },
            );
  return _hashtag;
}

List<Transform> hashtagListCreator(List<String> hashtagListData) {
  List<Transform> _hashtagList = List<Transform>();

  for(String hashtagData in hashtagListData) {
    ActionChip _hashtag = hashtagCreator(hashtagData, true);

    _hashtagList.add(
        Transform(
          transform: new Matrix4.identity()..scale(0.8),
          child: _hashtag,
        )
    );
  }

  return _hashtagList;
}
