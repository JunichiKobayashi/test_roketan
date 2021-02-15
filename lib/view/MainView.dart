import 'dart:async';

import 'package:flutter/material.dart';
import 'package:test_roketan/page/EditProfile.dart';
import 'package:test_roketan/page/Post.dart';
import 'package:test_roketan/page/PostDetail.dart';
import 'package:test_roketan/part/BottomNavigation.dart';
import 'package:test_roketan/page/KeepLocation.dart';
import 'package:test_roketan/page/KeepUser.dart';
import 'package:test_roketan/page/NarrowDownByHashtag.dart';
import 'package:test_roketan/page/PremiumUserResister.dart';
import 'package:test_roketan/page/Profile.dart';
import 'package:test_roketan/page/SearchResult.dart';
import 'package:test_roketan/part/CreateSearchBoxWidget.dart';
import 'package:test_roketan/part/DataBase.dart';
import 'package:test_roketan/part/DataManager.dart';
import 'package:test_roketan/part/Defines.dart' as Defines;
import 'package:test_roketan/view/Login.dart';
import 'package:test_roketan/view/SplashRoketan.dart';
import 'package:test_roketan/part/Launcher.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

//****************************
//***基本画面を描写するここから***

enum MainPageName {
  SearchResult,
  KeepLocation,
  KeepUser,
}

enum SubPageName {
  Profile,
  NarrowDownByHashtag,
  PremiumUserResister,
  Post,
  PostDetail,
  EditProfile,
}

class MainView extends StatefulWidget {
  //メインページとサブページのoffstage用bool型のリスト
  List<bool> showMP = new List.generate( MainPageName.values.length, (i) => true );
  List<bool> showSP = new List.generate( SubPageName.values.length, (i) => true );

  final pinsSpotStreamController = StreamController<Map<String, dynamic>>();

  @override
  _MainView createState() => _MainView();
}

class _MainView extends State<MainView> {

  //データマネージャのインスタンス作成
  ViewDataManager _vdm = new ViewDataManager();
  ActiveAccountDataManager _aadm = new ActiveAccountDataManager();
  AppDataManager _appdm = new AppDataManager();


  //Drawerメニュー用のキー
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  //クリップボードにコピーしました　用の変数
  String _completeText = '';
  String _shareText = 'ロケたんをシェア';

  initState() {
    super.initState();
    widget.showMP[_vdm.getViewData('selectedBN')] = false;
  }

  //ボトムナビゲーションアイテムタップ時のメソッド
  void _onTappedBottomNavigation(int index) {
    //データマネージャにセット
    _vdm.setViewData('selectedBN', index);

    setState(() {
      //全てtrue(非表示)で初期化
      for (int i = 0; i < widget.showMP.length; i++) { widget.showMP[i] = true; }
      for (int i = 0; i < widget.showSP.length; i++) { widget.showSP[i] = true; }
      //表示したいページだけをfalse(表示)に反転
      widget.showMP[index] = false;
    });
  }

  //サブページへジャンプする時のメソッド（Drawerメニュー、投稿画面、など）
  void _onTappedToSubpage(int pageIndex) {
    setState(() {
      //全てtrue(非表示)で初期化
      for (int i = 0; i < widget.showSP.length; i++) { widget.showSP[i] = true; }
      //表示したいページだけをfalse(表示)に反転
      widget.showSP[pageIndex] = false;
    });
  }

  //url_launcherを使ってメールを送信
  urlLauncherMail() {
    final Uri _emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'roketan.locexp@gmail.com',
      queryParameters: {
        'subject': 'ロケたんに関する問い合わせ',
        'body': '◆お願い：登録したメールアドレスからお問い合わせください◆\nFrom：${_aadm.getAccountData('email')}\n\n問い合わせ内容：\n'
      },
    );

    return launch(
      _emailLaunchUri.toString(),
    );
  }

  //アプリのトップページをシェア
  shareApp() async{
    final data = ClipboardData(text: "https://go-roketan.s3-ap-northeast-1.amazonaws.com/index.html");
    await Clipboard.setData(data);
    setState(() {
      _shareText = 'クリップボードにコピーしました';
    });
    await new Future.delayed(new Duration(seconds: 1));
    setState(() {
      _shareText = 'ロケたんをシェア';
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawerEdgeDragWidth: 0,
      drawer: Container(
        width: 400.0,
        child: Builder(
          builder: (BuildContext context) => Drawer(
            child: ListView(children: [
              GestureDetector(
                child: Container(
                  //color: Colors.pink,
                  margin: EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        backgroundImage: _aadm.getAccountData('profileIcon') == ''
                            ? Image.network( 'assets/noimage.png' ).image
                            : Image.network( _aadm.getAccountData('profileIcon') ).image,
                        radius: 40,
                      ),
                      Expanded(
                        child: Container(
                          child: RichText(
                            maxLines: 1,
                            text: TextSpan(
                              text: _aadm.getAccountData('nickname'),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                  color: Defines.colorset['darkdrawcolor']),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  _vdm.setViewData('selectedUserInfo', _aadm.getAccountDataAll() );
                  _onTappedToSubpage(SubPageName.Profile.index);
                  Navigator.pop(context);
                  DataBase().addOperationLog( 'open my profile' );
                },
              ),
              CreateDrawerMenuItemWidget(
                  icon: Icons.person_outline,
                  title: 'プロフィール',
                  onItemTapped: () {
                    _vdm.setViewData('selectedUserInfo', _aadm.getAccountDataAll() );
                    _onTappedToSubpage(SubPageName.Profile.index);
                    Navigator.pop(context);
                    DataBase().addOperationLog( 'open my profile' );
                  }
              ),
              CreateDrawerMenuItemWidget(
                  icon: Icons.tag,
                  title: 'ハッシュタグ絞り込み',
                  onItemTapped: () {
                    _onTappedToSubpage( SubPageName.NarrowDownByHashtag.index );
                    Navigator.pop(context);
                    DataBase().addOperationLog( 'open hashtag page' );
                  }
              ),
              CreateDrawerMenuItemWidget(
                  icon: Icons.attach_money,
                  title: 'プレミアム会員登録',
                  onItemTapped: () {
                    Navigator.pop(context);
                    launcherPremium();
                    DataBase().addOperationLog( 'open premium page' );
                  }
              ),
              Container(
                height: 64.0,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Defines.colorset['drawcolor']),
                  ),
                ),
                child: ListTile(
                  leading: Icon(Icons.content_copy),
                  title: Row(
                    children: [
                      Text(
                        _shareText,
                        style:
                        TextStyle(
                          color: _shareText == 'ロケたんをシェア'
                              ? Defines.colorset['drawcolor']
                              : Defines.colorset['darkdrawcolor'],
                          fontSize: _shareText == 'ロケたんをシェア'
                              ? 18.0
                              : 14.0,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    shareApp();
                    DataBase().addOperationLog( 'push share roketan' );
                  },
                ),
              ),
              CreateDrawerMenuItemWidget(
                  icon: Icons.logout,
                  title: 'ログアウト',
                  onItemTapped: () async{
                    DataBase().addOperationLog( 'logout' );
                    await _aadm.logoutAccountData();
                    await _vdm.initViewData();
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
                        return Login();
                      }),
                    );
                  }
              ),
              CreateDrawerMenuItemWidget(
                  icon: Icons.contact_support_outlined,
                  title: 'お問い合わせ',
                  onItemTapped: () {
                    DataBase().addOperationLog( 'logout' );
                    Navigator.pop(context);
                    urlLauncherMail();
                  }
              ),

            ]),
          ),
        ),
      ),
      body: Container(
        color: Defines.colorset['backgroundcolor'],
        child: Stack(
          children: [
            Container(
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.bottomCenter,
                    height: 60.0,
                    color: Defines.colorset['backgroundcolor'],
                    child: Row(
                      children: [
                        Container(
                          height: 60.0,
                          width: 60.0,
                          padding: EdgeInsets.all(2.0),
                          child: GestureDetector(
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              backgroundImage: _aadm.getAccountData('profileIcon') == ''
                                  ? Image.network( 'assets/noimage.png' ).image
                                  : Image.network( _aadm.getAccountData('profileIcon') ).image,
                            ),
                            onTap: () async{
                              _scaffoldKey.currentState.openDrawer();
                              await DataBase().addOperationLog( 'open drawer menu' );
                            }
                          ),
                        ),
                        Expanded(
                          child: CreateSearchBoxWidget(
                            hitText: 'キーワード検索',
                            onChanged: null,
                            onSubmitted: null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      child: Stack(
                        children: [
                          Offstage(
                            offstage: widget.showMP[MainPageName.SearchResult.index],
                            child: SearchResult(
                              pinsSpotStreamController: widget.pinsSpotStreamController,
                              onTapToSubPage: (int index) {
                                _onTappedToSubpage(index);
                              },
                            ),
                          ),
                          Offstage(
                            offstage: widget.showMP[MainPageName.KeepLocation.index],
                            child: KeepLocation(
                              onTapToSubPage: (int index) {
                                _onTappedToSubpage(index);
                              },
                            ),
                          ),
                          Offstage(
                            offstage: widget.showMP[MainPageName.KeepUser.index],
                            child: KeepUser(
                              onTapToSubPage: (int index) {
                                _onTappedToSubpage(index);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Offstage(
              offstage: widget.showSP[SubPageName.Profile.index],
              child: _vdm.getViewData('selectedUserInfo') != null
                  ? Profile(
                      userData: _vdm.getViewData('selectedUserInfo'),
                      onTapToSubPage: (int pageIndex) => _onTappedToSubpage( pageIndex ),
              )
                  : Container(),
            ),
            Offstage(
              offstage: widget.showSP[SubPageName.NarrowDownByHashtag.index],
              child: NarrowDownByHashtag(),
            ),
            Offstage(
              offstage: widget.showSP[SubPageName.PremiumUserResister.index],
              child: PremiumUserResister(),
            ),
            Offstage(
              offstage: widget.showSP[SubPageName.Post.index],
              child: Post(),
            ),
            Offstage(
              offstage: widget.showSP[SubPageName.PostDetail.index],
              child: _vdm.getViewData('selectedPostInfo') != null
                  ? PostDetail(
                      postData: _vdm.getViewData('selectedPostInfo'),
                      onTapUserToProfilePage: ( int pageIndex) => _onTappedToSubpage( pageIndex ),
                      onTapToSubPage: (int index) => _onTappedToSubpage(index),
                      pinsSpotStreamController: widget.pinsSpotStreamController,
                    )
                  : Container(),
            ),
            Offstage(
              offstage: widget.showSP[SubPageName.EditProfile.index],
              child: EditProfile(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        onItemTapped: ( int index ){
          _onTappedBottomNavigation( index );
          switch( index ){
            case 0:
              DataBase().addOperationLog( 'selected bottom navigation SEARCH' );
              break;
            case 1:
              DataBase().addOperationLog( 'selected bottom navigation KEEP SPOT' );
              break;
            case 2:
              DataBase().addOperationLog( 'selected bottom navigation KEEP USER' );
              break;
          }
        },
      ),
    );
  }
}

//***基本画面を描写するここまで***
//****************************

class CreateDrawerMenuItemWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final Function onItemTapped;
  final String optionalText;

  CreateDrawerMenuItemWidget({
    this.icon,
    this.title,
    this.onItemTapped,
    this.optionalText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64.0,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Defines.colorset['drawcolor']),
        ),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          title,
          style:
          TextStyle(
            color: Defines.colorset['drawcolor'],
            fontSize: 18.0,
          ),
        ),
        onTap: onItemTapped,
      ),
    );
  }
}
