
import 'package:flutter/material.dart';
import 'package:test_roketan/view/Login.dart';
import 'package:test_roketan/view/SplashRoketan.dart';
import 'package:test_roketan/part/Defines.dart' as Defines;

//********************
//***main関数ここから***
void main(){
  runApp(MaterialApp(
    theme: ThemeData(
      primaryColor: Defines.colorset['backgroundcolor'],
    ),
    home:SplashRoketan(),
  ));
}
//***main関数ここまで***
//********************