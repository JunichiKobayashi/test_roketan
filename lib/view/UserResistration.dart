
import 'package:flutter/material.dart';
import 'package:test_roketan/part/DataManager.dart';
import 'package:test_roketan/view/Login.dart';

import 'package:test_roketan/part/Defines.dart' as Defines;
import 'package:cloud_firestore/cloud_firestore.dart';


class UserResistration extends StatefulWidget {
  @override
  _UserResistrationState createState() => _UserResistrationState();
}

class _UserResistrationState extends State<UserResistration> {

  //データマネージャのインスタンス作成
  ActiveAccountDataManager _aadm = new ActiveAccountDataManager();
  AppDataManager _appdm = new AppDataManager();

  // メッセージ表示用
  String infoText = '';
  //投稿ボタン連打防止用
  bool _isRegistrationActive = true ;
  // 入力したメールアドレス・パスワード
  String email = '';
  String password = '';
  String passwordConfirm = '';
  String nickname = '';



  //DBにメールアドレスの重複がないかを確認して処理をするメソッド
  //既にメールアドレスが登録してあったら、エラーメッセージを出力
  //新しいメールアドレスなら、DBに登録する処理をする。
  Future<void> AccountResister( String email, String password, String nickname ) async{
    QuerySnapshot querySnapshot = await Firestore.instance.collection("user_info").getDocuments();
    var list = await querySnapshot.documents;
    for( int i=0; i<list.length; i++ ){
      if(  email == await list[i]['email'] ){
        //メールアドレスが既に登録してある場合
        setState(() {
          infoText = "登録済みのメールアドレスです";
        });
        return;
        }
    }
    //新しいメールアドレスの場合
    setState(() {
      infoText = "登録に成功しました。自動でログインページに戻ります。";
    });
    await Firestore.instance
        .collection('user_info') // コレクションID
        .document() // ドキュメントID
        .setData(
        {
          'email': email,
          'password': password,
          'nickname': nickname,
          'is_premium': false,
          'profile_icon': '',
          'introduction': '',
          'profile_hashtag_list': [],
          'narrow_down_hashtag_list0':[],
          'narrow_down_hashtag_list1':[],
          'narrow_down_hashtag_list2':[],
          'user_posts_list': [],
          'keep_user_info_list': [],
          'keep_spot_info_list': [],
          'have_been_spot_info_list': [],
        }
    ); // データ
    await new Future.delayed(new Duration(seconds: 4));
    await Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Login() ));
  }



  //firebaseテスト用
  List<DocumentSnapshot> documentList = [];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 40),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              RichText(
                  text: TextSpan(
                    text: '新規隊員登録',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Defines.colorset['highlightcolor'],
                    ),
                  ),
              ),
              // メールアドレス入力
              Container(
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'メールアドレス'),
                      onChanged: (String value) {
                        setState(() {
                          email = value;
                        });
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'パスワード'),
                      obscureText: true,
                      onChanged: (String value1) {
                        setState(() {
                          password = value1;
                        });
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'パスワード確認'),
                      obscureText: true,
                      onChanged: (String value2) {
                        setState(() {
                          passwordConfirm = value2;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Container(
                height: 60,
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  '隊員名(ニックネーム)を入力してください\n※後から変更できます',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Defines.colorset['highlightcolor'],
                  ),
                ),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: '隊員名'),
                obscureText: false,
                onChanged: (String value3) {
                  setState(() {
                    nickname = value3;
                  });
                },
              ),
              // パスワード入力
              Container(
                padding: EdgeInsets.all(8),
                // メッセージ表示
                child: Text(infoText),
              ),
              Container(
                margin: EdgeInsets.only(top: 20),
                padding: EdgeInsets.symmetric(horizontal: 40),
                width: double.infinity,
                height: 40,
                // ユーザー登録ボタン
                child: RaisedButton(
                  color: Defines.colorset['highlightcolor'],
                  textColor: Colors.white,
                  child: Text('隊員登録'),
                  onPressed: () async {
                    if (_isRegistrationActive) {
                      _isRegistrationActive = false;
                      try {
                        // メール/パスワードでユーザー登録
                        if (email.contains('@')) {
                          if (password == passwordConfirm) {
                            if (password != '') {
                              if (nickname != '') {
                                // 入力チェックOKの場合
                                await AccountResister(email, password, nickname);
                              } else {
                                setState(() {
                                  infoText = "ニックネームを入力してください。";
                                });
                              }
                            } else {
                              setState(() {
                                infoText = "パスワードを入力してください。";
                              });
                            }
                          } else {
                            setState(() {
                              infoText = "パスワードが一致しません。";
                            });
                          }
                        } else {
                          setState(() {
                            infoText = "メールアドレスを入力してください。";
                          });
                        }
                      } catch (e) {
                        // ユーザー登録に失敗した場合
                        setState(() {
                          infoText = "登録に失敗しました";
                        });
                      }
                      }
                    _isRegistrationActive = true;
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20),
                padding: EdgeInsets.symmetric(horizontal: 40),
                width: double.infinity,
                child: OutlineButton(
                  textColor: Defines.colorset['drawcolor'],
                  child: Text('ログインページへ戻る'),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) {
                        return Login();
                      }),
                    );
                  },
                ),
              ),
              // コレクション内のドキュメント一覧を表示
            ],
          ),
        ),
      ),
    );
  }
}
