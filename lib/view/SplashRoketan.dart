import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:test_roketan/part/DataManager.dart';
import 'package:test_roketan/view/Login.dart';
import 'package:test_roketan/view/MainView.dart';

import 'package:test_roketan/part/Defines.dart' as Defines;


class SplashRoketan extends StatefulWidget {
  @override
  _SplashRoketanState createState() => _SplashRoketanState();
}

class _SplashRoketanState extends State<SplashRoketan> {

  //データマネージャのインスタンス作成
  ActiveAccountDataManager _aadm = new ActiveAccountDataManager();

  @override
  Widget build(BuildContext context) {
    // 画面表示調整用
    double _maxHeight = MediaQuery.of(context).size.height * 0.8;

    return SplashScreen(
      seconds: 4,
      navigateAfterSeconds: _aadm.getAccountData('id')==null ? Login() : MainView(),
      image: Image.asset('assets/splash.png'),
      backgroundColor: Defines.colorset['backgroundcolor'],
      photoSize: _maxHeight * 0.37,
      loaderColor: Defines.colorset['highlightcolor'],
    );
  }
}