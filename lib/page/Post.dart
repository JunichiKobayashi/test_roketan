

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_web_image_picker/flutter_web_image_picker.dart';

import 'package:test_roketan/part/CreateButtonWidget.dart';
import 'package:test_roketan/part/DataBase.dart';
import 'package:test_roketan/part/DataManager.dart';

import 'package:test_roketan/part/Defines.dart' as Defines;
import 'package:test_roketan/part/SetHashtagWidget.dart';
import 'package:test_roketan/view/MainView.dart';

class Post extends StatefulWidget {

  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {

  //データマネージャクラスのインスタンス作成
  ViewDataManager _vdm = new ViewDataManager();
  ActiveAccountDataManager _aadm = new ActiveAccountDataManager();

  //入力フォームのチェック用キー作成
  final _formKey = GlobalKey<FormState>();

  // メッセージ表示用
  String infoText = '';
  //投稿ボタン連打防止用
  bool _isButtonActive = true ;

  //データベースに登録する用の投稿データ
  String newSpotName;
  String newPostTitle;
  String newText;
  List newImagePathList = [];
  List<String> newPostHashtagList = [];

  List<String> newPostHashtagIDList = [];
  String newSpotID;
  List<String> newImageUrlList = [];
  String newPostID;


  Image _image0, _image1, _image2, _image3;
  var _imagePath0, _imagePath1, _imagePath2, _imagePath3;

  void initVar(){
    newSpotName = null;
    newPostTitle = null;
    newText = null;
    newImagePathList = [];
    newPostHashtagList = [];
    newPostHashtagIDList= [];
    newSpotID = null;
    newImageUrlList = [];
    newPostID = null;
    _vdm.setViewData('selectedSpotName', null);
    _vdm.setViewData('_isSpotSelected', false);
    _vdm.setViewData( 'selectedLatitude', null );
    _vdm.setViewData( 'selectedLongitude', null );
  }

  Future<void> newHashtagResister( List<String> hashtagList ) async{
    //ハッシュタグのリストを引数として渡し、IDのリストを返す
    //登録されていないハッシュタグが含まれている場合は、ID登録した上で新たに取得したIDとする
    var hashtagIDList = await DataBase().getDBHashtagIDListFromHashtagDataList( hashtagList );
    newPostHashtagIDList = hashtagIDList;
  }

  void newSpotResister( String spotName ) async{
    //新規スポットのIDを取得する処理
    String latitude, longitude;
    latitude = _vdm.getViewData('selectedLatitude').toString();
    longitude = _vdm.getViewData('selectedLongitude').toString();

    await DataBase().setSpotInfo(spotName, latitude, longitude);
    var spotID = await DataBase().getDBSpotIDFromSpotData(spotName, latitude, longitude);
    newSpotID = spotID;
  }

  //投稿を作成し、投稿IDを取得する。取得したIDをスポットに紐付ける
  void newPostResister( String postTitle, String text, List<String> hashtagIDList, String spotID ) async{
    await DataBase().setPostInfo(postTitle, text, hashtagIDList, spotID);

    var userID = _aadm.getAccountData('id');
    var postID = await DataBase().getDBPostIDFromPostData(postTitle, text, userID, spotID);
    newPostID = postID;

    await DataBase().updateSpotInfo( spotID, 'PostToLoc', newPostID, 'add' );
  }

  //↑で取得した投稿IDのフォルダ名をデータベースに作成し、画像のURLを取得して、登録する。
  void getAndUploadImageUrl( String postId, List imagePathList ) async{
    for( int i=0; i<imagePathList.length; i++ ){
      var tmpurl = await DataBase().uploadPostImageAndGetUrl(postId, imagePathList[i].first.name, imagePathList[i].first.bytes);
      newImageUrlList.add( tmpurl );
    }
    await DataBase().updatePostInfo( newPostID, 'postImageList', newImageUrlList);
  }

  //ユーザー情報に投稿IDを追加する
  void addPostIDToMyAccount( String postID ){
    List<dynamic> postList = _aadm.getAccountData('userPostList');
    postList.add( postID );
    _aadm.setAccountData('userPostList',  postList );
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      color: Defines.colorset['backgroundcolor'],
      child: Column(
        children: [
          Container(
            height: 60,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Defines.colorset['drawcolor'],
                  width: 1.0,
                ),
              ),
            ),
            child: Row(
              children: [
                CreateButtonWidget(
                  title: 'キャンセル',
                  onPressed: (){
                    initVar();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => MainView() ));
                  },
                ),
                Expanded(
                  child: Container(
                    child: Center(
                      child: RichText(
                        text: TextSpan(
                          text: '投稿作成',
                          style: TextStyle(
                              color: Defines.colorset['darkdrawcolor'],
                              fontWeight: FontWeight.normal,
                              fontSize: 24.0),
                        ),
                      ),
                    ),
                  ),
                ),
                CreateButtonWidget(
                  title: '投稿',
                  onPressed: () async{
                    if(_isButtonActive) {
                      _isButtonActive = false;
                      //操作ログ用
                      DataBase().addOperationLog( 'push post resister button' );

                      //投稿画像を整理してリストに格納
                      newImagePathList = [];
                      if( _image0 != null ){ newImagePathList.add(_imagePath0); }
                      if( _image1 != null ){ newImagePathList.add(_imagePath1); }
                      if( _image2 != null ){ newImagePathList.add(_imagePath2); }
                      if( _image3 != null ){ newImagePathList.add(_imagePath3); }

                      //入力チェック
                      if( _vdm.getViewData('selectedSpotName') == null ){
                        if( newSpotName != null ){
                          if( newPostTitle != null ){
                            if( newText != null ){
                              //入力チェックOK

                              //操作ログ用
                              DataBase().addOperationLog( 'post resister succeeded' );

                              //新規スポットへ投稿する
                              await newHashtagResister( newPostHashtagList );
                              await newSpotResister( newSpotName );
                              await newPostResister(newPostTitle, newText,newPostHashtagIDList,newSpotID);
                              await getAndUploadImageUrl(newPostID, newImagePathList);
                              addPostIDToMyAccount( newPostID );

                              //変数と状態の初期化
                              initVar();

                              //メインビューへ戻る
                              Navigator.push(context, MaterialPageRoute( builder: (context) => MainView() ));

                            } else {
                              setState(() {
                                infoText = '本文を入力してください';
                              });
                            }
                          } else {
                            setState(() {
                              infoText = 'タイトルを入力してください';
                            });
                          }
                        } else {
                          setState(() {
                            infoText = '聖地名を入力してください';
                          });
                        }
                      } else {
                        if( newPostTitle != null ){
                          if( newText != null ){
                            //入力チェックOK

                            //操作ログ用
                            DataBase().addOperationLog( 'post resister succeeded' );

                            //既に登録済みのスポットへ投稿する場合
                            await newHashtagResister( newPostHashtagList );
                            var _spotID = _vdm.getViewData('selectedSpotInfo')['id'];
                            await newPostResister(newPostTitle, newText,newPostHashtagIDList,_spotID);
                            await getAndUploadImageUrl(newPostID, newImagePathList);
                            addPostIDToMyAccount( newPostID );

                            //変数と状態の初期化
                            initVar();
                            _vdm.setViewData('selectedSpotInfo', null );
                            _vdm.setViewData( 'selectedLatitude', null );
                            _vdm.setViewData( 'selectedLongitude', null );
                            Navigator.push(context, MaterialPageRoute( builder: (context) => MainView() ));
                          } else {
                            setState(() {
                              infoText = '本文を入力してください';
                            });
                          }
                        } else {
                          setState(() {
                            infoText = 'タイトルを入力してください';
                          });
                        }
                      }
                    }
                    _isButtonActive = true;
                  },

                ),

              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            // メッセージ表示
            child: Text(
              infoText,
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 120,
            child: Row(
              children: [
                Container(
                  width: 60,
                  child: Icon(
                    Icons.flag,
                    size: 40.0,
                    color: Defines.colorset['drawcolor'],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Offstage(
                        offstage: _vdm.getViewData('selectedSpotName') == null, //falseなら表示
                        child: Container(
                          child: RichText(
                            text: TextSpan(
                              text: _vdm.getViewData('selectedSpotName'),
                              style: TextStyle(
                                color: Defines.colorset['darkdrawcolor'],
                                fontWeight: FontWeight.bold,
                                fontSize: 28.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Offstage(
                        offstage: _vdm.getViewData('selectedSpotName') != null, //falseなら表示
                        child: Container(
                          margin: EdgeInsets.all( 10 ),
                          child: TextFormField(
                            //keyboardType: TextInputType.multiline,
                            maxLines: 1,
                            maxLength: 30,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only( left: 10, right: 10 ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              hintText: '聖地名を入力してください',
                              hintStyle: TextStyle(
                                fontSize: 18,
                                color: Defines.colorset['drawcolor'],
                              ),
                              filled: true, // fillColorで指定した色で塗り潰し
                              fillColor: Colors.grey[300],
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                      color: Defines.colorset['backgroundcolor']
                                  )
                              ),
                            ),
                            onChanged: (String _spotName){
                              setState(() {
                                newSpotName = _spotName;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: ListView(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.all( 10 ),
                          child: TextFormField(
                            //keyboardType: TextInputType.multiline,
                            maxLines: 1,
                            maxLength: 30,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all( 10 ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              hintText: '投稿タイトルを入力してください',
                              hintStyle: TextStyle(
                                fontSize: 18,
                                color: Defines.colorset['drawcolor'],
                              ),
                              filled: true, // fillColorで指定した色で塗り潰し
                              fillColor: Colors.grey[300],
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                      color: Defines.colorset['backgroundcolor']
                                  )
                              ),
                            ),
                            onChanged: ( String _postTitle ){
                              newPostTitle = _postTitle;
                            },
                          ),
                        ),
                        Container(
                          height: 180,
                          margin: EdgeInsets.all( 10 ),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextFormField(
                            style: TextStyle(height: 1.0),
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(top: 20, bottom: 20, left: 10, right: 10),
                              border: InputBorder.none,
                              hintText: '本文を入力してください',
                              hintStyle: TextStyle(
                                fontSize: 18,
                                color: Defines.colorset['drawcolor'],
                              ),
                              filled: true, // fillColorで指定した色で塗り潰し
                              fillColor: Colors.grey[300],
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                      color: Colors.grey[300],
                                  )
                              ),
                            ),
                            onChanged: ( String _text ){
                              newText = _text;
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all( 10 ),
                          child: SingleChildScrollView(
                            child: Row(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10.0),
                                        color: Colors.grey[300],
                                      ),
                                      width: 100,
                                      height: 100,
                                      child: IconButton(
                                        icon: Icon(Icons.image_rounded),
                                        iconSize: 80,
                                        color: Defines.colorset['drawcolor'],
                                        onPressed: ()async {
                                          //final _image = await FlutterWebImagePicker.getImage;
                                          _imagePath0 = (await FilePicker.platform.pickFiles(
                                              type: FileType.image, allowMultiple: false, withData: true))
                                              ?.files;
                                          var _imageFileName = _imagePath0.first.name;
                                          var _imageData = _imagePath0.first.bytes;
                                          setState(() {
                                            _image0 = Image.memory(_imageData);
                                          });
                                        },
                                      ),
                                    ),
                                    Offstage(
                                      offstage: _image0 == null,
                                      child: Stack(
                                        children: [
                                          Container(
                                            margin: EdgeInsets.all(4),
                                            color: Defines.colorset['darkdrawcolor'],
                                            width: 100,
                                            height: 100,
                                            child: _image0,
                                          ),
                                          Container(
                                            margin: EdgeInsets.all(4),
                                            width: 100,
                                            height: 100,
                                            alignment: Alignment.topRight,
                                            child: Container(
                                              width: 30,
                                              height: 30,
                                              color: Defines.colorset['drawcolor'].withOpacity(0.5),
                                              child: IconButton(
                                                icon: Icon(Icons.highlight_remove),
                                                iconSize: 15,
                                                color: Defines.colorset['drawcolor'],
                                                onPressed: (){
                                                  setState(() {
                                                    _image0 = null;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Stack(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10.0),
                                        color: Colors.grey[300],
                                      ),
                                      width: 100,
                                      height: 100,
                                      child: IconButton(
                                        icon: Icon(Icons.image_rounded),
                                        iconSize: 80,
                                        color: Defines.colorset['drawcolor'],
                                        onPressed: () async {
                                          _imagePath1 = (await FilePicker.platform.pickFiles(
                                              type: FileType.image, allowMultiple: false, withData: true))
                                              ?.files;
                                          var _imageFileName = _imagePath1.first.name;
                                          var _imageData = _imagePath1.first.bytes;
                                          setState(() {
                                            _image1 = Image.memory(_imageData);
                                          });
                                        },
                                      ),
                                    ),
                                    Offstage(
                                      offstage: _image1 == null,
                                      child: Stack(
                                        children: [
                                          Container(
                                            margin: EdgeInsets.all(4),
                                            color: Defines.colorset['darkdrawcolor'],
                                            width: 100,
                                            height: 100,
                                            child: _image1,
                                          ),
                                          Container(
                                            margin: EdgeInsets.all(4),
                                            width: 100,
                                            height: 100,
                                            alignment: Alignment.topRight,
                                            child: Container(
                                              width: 30,
                                              height: 30,
                                              color: Defines.colorset['drawcolor'].withOpacity(0.5),
                                              child: IconButton(
                                                icon: Icon(Icons.highlight_remove),
                                                iconSize: 15,
                                                color: Defines.colorset['drawcolor'],
                                                onPressed: (){
                                                  setState(() {
                                                    _image1 = null;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Stack(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10.0),
                                        color: Colors.grey[300],
                                      ),
                                      width: 100,
                                      height: 100,
                                      child: IconButton(
                                        icon: Icon(Icons.image_rounded),
                                        iconSize: 80,
                                        color: Defines.colorset['drawcolor'],
                                        onPressed: ()async {
                                          _imagePath2 = (await FilePicker.platform.pickFiles(
                                              type: FileType.image, allowMultiple: false, withData: true))
                                              ?.files;
                                          var _imageFileName = _imagePath2.first.name;
                                          var _imageData = _imagePath2.first.bytes;
                                          setState(() {
                                            _image2 = Image.memory(_imageData);
                                          });
                                        },
                                      ),
                                    ),
                                    Offstage(
                                      offstage: _image2 == null,
                                      child: Stack(
                                        children: [
                                          Container(
                                            margin: EdgeInsets.all(4),
                                            color: Defines.colorset['darkdrawcolor'],
                                            width: 100,
                                            height: 100,
                                            child: _image2,
                                          ),
                                          Container(
                                            margin: EdgeInsets.all(4),
                                            width: 100,
                                            height: 100,
                                            alignment: Alignment.topRight,
                                            child: Container(
                                              width: 30,
                                              height: 30,
                                              color: Defines.colorset['drawcolor'].withOpacity(0.5),
                                              child: IconButton(
                                                icon: Icon(Icons.highlight_remove),
                                                iconSize: 15,
                                                color: Defines.colorset['drawcolor'],
                                                onPressed: (){
                                                  setState(() {
                                                    _image2 = null;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Stack(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10.0),
                                        color: Colors.grey[300],
                                      ),
                                      width: 100,
                                      height: 100,
                                      child: IconButton(
                                        icon: Icon(Icons.image_rounded),
                                        iconSize: 80,
                                        color: Defines.colorset['drawcolor'],
                                        onPressed: ()async {
                                          _imagePath3 = (await FilePicker.platform.pickFiles(
                                              type: FileType.image, allowMultiple: false, withData: true))
                                              ?.files;
                                          var _imageFileName = _imagePath3.first.name;
                                          var _imageData = _imagePath3.first.bytes;
                                          setState(() {
                                            _image3 = Image.memory(_imageData);
                                          });
                                        },
                                      ),
                                    ),
                                    Offstage(
                                      offstage: _image3 == null,
                                      child: Stack(
                                        children: [
                                          Container(
                                            margin: EdgeInsets.all(4),
                                            color: Defines.colorset['darkdrawcolor'],
                                            width: 100,
                                            height: 100,
                                            child: _image3,
                                          ),
                                          Container(
                                            margin: EdgeInsets.all(4),
                                            width: 100,
                                            height: 100,
                                            alignment: Alignment.topRight,
                                            child: Container(
                                              width: 30,
                                              height: 30,
                                              color: Defines.colorset['drawcolor'].withOpacity(0.5),
                                              child: IconButton(
                                                icon: Icon(Icons.highlight_remove),
                                                iconSize: 15,
                                                color: Defines.colorset['drawcolor'],
                                                onPressed: (){
                                                  setState(() {
                                                    _image3 = null;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 20),
                          child: SetHashtagWidget(
                            index: -100,
                            hashtagList: newPostHashtagList,
                            onSubmitHashtag: (String str){},
                            onTapClearButton: (){
                              if( newPostHashtagList.length != 0 ){
                                setState(() {
                                  newPostHashtagList.removeAt( newPostHashtagList.length -1 );
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class InsertImageWidget extends StatelessWidget {

  Image image;

  @override
  Widget build(BuildContext context) {
    return  Stack(
      children: [
        Container(
          margin: EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.grey[300],
          ),
          width: 100,
          height: 100,
          child: IconButton(
            icon: Icon(Icons.image_rounded),
            iconSize: 80,
            color: Defines.colorset['drawcolor'],
            onPressed: () async {
              final _image = await FlutterWebImagePicker.getImage;
              //setState(() {
                image = _image;
              //});
            },
          ),
        ),
        Offstage(
          offstage: image == null,
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.all(4),
                width: 100,
                height: 100,
                color: Defines.colorset['darkdrawcolor'],
                child: image,
              ),
              Container(
                width: 100,
                height: 100,
                alignment: Alignment.topRight,
                child: Container(
                  width: 30,
                  height: 30,
                  color: Defines.colorset['backgroundcolor'].withOpacity(0.5),
                  child: IconButton(
                    icon: Icon(Icons.highlight_remove),
                    iconSize: 15,
                    onPressed: (){
                      //setState(() {
                        image = null;
                      //});
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
