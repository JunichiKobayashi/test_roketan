import 'package:flutter/material.dart';

//ここでは、複数のDartファイルに渡って使う定数を定義する。
//テーマに合わせた色などを変更する場合。
//他ウィジェットから操作されるグローバル変数は置かないこと。

final Map colorset = {
  'backgroundcolor' : Color(0xfff0f0f0),
  'drawcolor'       : Colors.grey[500],
  'darkdrawcolor'   : Colors.black,
  'highlightcolor'  : Color(0xffF4B183),
  'selectedcolor'   : Color(0xffA9D18E),
  'newspotcolor'    : Color(0xffFF3399),
  'keepspotcolor'   : Color(0xffFFCC00),
  'havebeencolor'   : Color(0xff00B0F0),
  'keepusercolor'   : Color(0xffFF6600),
  'nowpointer'      : Colors.blue.withOpacity(0.7),
};




