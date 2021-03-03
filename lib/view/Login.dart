
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_roketan/part/DataManager.dart';
import 'package:test_roketan/part/DataBase.dart';
import 'package:test_roketan/view/MainView.dart';

import 'package:test_roketan/part/Defines.dart' as Defines;

import 'UserResistration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  // 画面表示調整用
  double _loginFieldViewRatio = 0.5;
  double _viewLeftAndRight = 12;

  //データマネージャのインスタンス作成
  ActiveAccountDataManager _aadm = new ActiveAccountDataManager();
  AppDataManager _appdm = new AppDataManager();

  //テキストコントローラー
  final emailInputController = new TextEditingController();
  final passwordInputController = new TextEditingController();

  // メッセージ表示用
  String infoText = '';
  // 入力したメールアドレス・パスワード
  String email = '';
  String password = '';

  //メールアドレスをローカルに保存しておくかどうか
  bool isSaveEmail = false;

  @override
  void initState() {
    load();
    super.initState();
  }


  //メールアドレスを保存しておくためのメソッド
  void save( bool isSave, String email, String password ) async{
    //インスタンス化
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //nameキーを設定し、nameDateを保存
    await prefs.setBool('isSave', isSave);
    await prefs.setString('email', email);
    await prefs.setString('password', password);
  }

  //保存しておいたメールアドレスを読みだすメソッド
  void load() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isSaveEmail = (prefs.getBool('isSave') ?? false);
    email = (prefs.getString('email') ?? '');
    password = (prefs.getString('password') ?? '');
    emailInputController.text = email;
    passwordInputController.text = password;
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(left: _viewLeftAndRight, right: _viewLeftAndRight),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[

              ConstrainedBox(
                constraints: BoxConstraints.loose(
                    Size(
                        MediaQuery.of(context).size.width,
                        MediaQuery.of(context).size.height * (1-_loginFieldViewRatio)
                    )
                ),
                child: Container(
                  // width: MediaQuery.of(context).size.width,
                  // height: MediaQuery.of(context).size.height * _imageViewRatio,
                  //margin: EdgeInsets.only(bottom: 80),
                  child: Image.asset(
                    'assets/splash.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Container(
                //color: Colors.cyan,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * _loginFieldViewRatio,
                child: Column(
                  children: <Widget>[
                    // メールアドレス入力
                    TextFormField(
                      controller: emailInputController,
                      decoration: InputDecoration(labelText: 'メールアドレス'),
                      onChanged: (String value) {
                        setState(() {
                          email = value;
                        });
                      },
                    ),
                    // パスワード入力
                    TextFormField(
                      controller: passwordInputController,
                      decoration: InputDecoration(labelText: 'パスワード'),
                      obscureText: true,
                      onChanged: (String value) {
                        setState(() {
                          password = value;
                        });
                      },
                    ),
                    Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            child: IconButton(
                              icon: Icon(
                                isSaveEmail ? Icons.check_box_outlined : Icons.check_box_outline_blank,
                              ),
                              iconSize: 16,
                              color: Defines.colorset['darkdrawcolor'],
                              onPressed: (){
                                isSaveEmail = !isSaveEmail;
                                setState(() {});
                              },
                            ),
                          ),
                          Container(
                            child: Text(
                              'メールアドレスとパスワードを保存する',
                              style: TextStyle(
                                color: Defines.colorset['darkdrawcolor'],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8),
                      // メッセージ表示
                      child: Text(infoText),
                    ),
                    Container(
                      //margin: EdgeInsets.only(top: 5),
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      width: double.infinity,
                      // ログイン登録ボタン
                      child: OutlineButton(
                        textColor: Defines.colorset['drawcolor'],
                        child: Text('ログイン'),
                        onPressed: () async {
                          await DataBase().author( email, password );
                          if( _aadm.getAccountData('id') == null ){
                            setState(() {
                              infoText = "メールアドレスまたはパスワードが間違っています。";
                            });
                          }
                          if( _aadm.getAccountData('id') != null ){
                            Navigator.of(context).pushReplacement( MaterialPageRoute(builder: (context) => MainView() ));
                            await DataBase().addOperationLog( 'login' );
                            if( isSaveEmail ){
                              save(isSaveEmail, email, password);
                            } else {
                              save(false, '', '');
                            }
                          }
                        },
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.only(top: 10,bottom: 10),
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      width: double.infinity,
                      height: 40,
                      // ユーザー登録ボタン
                      child: RaisedButton(
                        color: Defines.colorset['highlightcolor'],
                        textColor: Colors.white,
                        child: Text('新規登録はコチラ'),
                        onPressed: (){
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) {
                              return UserResistration();
                            }),
                          );
                        },
                      ),
                    ),
                    Text(
                      'ver.1.6.0',
                      //ユーザーの目から見てわからない変更　3けた目
                      //見栄えの変更　2けた目
                      //メジャー変更（リリースバージョン変更　1けた目
                      style: TextStyle(
                        //color: Colors.blueAccent,
                        color: Defines.colorset['drawcolor'],
                      ),
                    ),


                    /*//////////



                    Container(
                      margin: EdgeInsets.only(top: 10,bottom: 10),
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      width: double.infinity,
                      height: 40,
                      // ユーザー登録ボタン
                      child: RaisedButton(
                        color: Defines.colorset['highlightcolor'],
                        textColor: Colors.white,
                        child: Text('デバッグ用'),
                        onPressed: () async{




                          List<Map<String, dynamic>> list = await DataBase().getDBUserData();
                          for( int i=0; i<list.length; i++ ){
                            print( list[i]['email'] );
                          }


                          /*

                          var l = await DataBase().getDBSpotData();
                          var tmp = [];
                          var noPost = [];
                          print( tmp );

                          for( int i=0; i<l.length; i++ ){
                            if( l[i]['PostToLoc'].length == 0 ){
                              noPost.add( l[i]['id'] );
                            }
                            for( int j=i+1; j<l.length; j++ ){
                              if( l[i]['Latitude'] == l[j]['Latitude'] && l[i]['Longitude'] == l[j]['Longitude'] ){
                                tmp.add( l[j]['id'] );
                              }
                            }
                            if( tmp.length != 0 ){
                              print( l[i]['id'] );
                              print( 'Latitude:${l[i]['Latitude']}, Longitude:${l[i]['Longitude']}' );
                              print( tmp );
                              print( '----------------------------------------------------------' );
                            }
                            tmp = [];
                          }
                          print( 'noPost : $noPost' );
                          print('end');


                          for( int i=0; i<l.length; i++ ){
                            //print( l[i]['Latitude']  );
                            if( l[i]['LocName'] == 'null' ){
                              print( l[i]['id'] );
                            }
                          }





                          //DataBase().getOperationLogOnly('zGrzF8nEh09aAX5xlC56');

                          var u = await DataBase().getDBUserData();
                          print( u.length );
                          var s = await DataBase().getDBSpotData();
                          print( s.length );
                          var p = await DataBase().getDBPostData();
                          print( p.length );
                          //DataBase().deletePostInfo('yIvxRjXqa8asWigYXYzQ');
                          //DataBase().deleteSpotInfo( 'nhMYjzlGOlSsKdNdf2jJ' );
                          //DataBase().combineSpotInfo('u7nt0nvojlxNZQrhoYzR', 'ytygququYieC1nMpM55g');





                           */






                        },
                      ),
                    ),


                     *//////////////////


                  ],
                ),
              ),
              Container(
                height: 100,
              ),
            ],
          ),
        ),
      ),
    );
  }
}