import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:test_roketan/part/DataBase.dart';
import 'package:test_roketan/part/Defines.dart' as Defines;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:test_roketan/part/Hashtag.dart';
import 'package:test_roketan/part/NarrowDown.dart';


/////////////////////////////////////////////////////////
//ここでは複数のウィジェットに跨って使用するデータを一元管理する。
/////////////////////////////////////////////////////////
//アプリの表示に必要な状態を管理するクラス///////////////////////////////
class ViewDataManager {

  static final Map<String, dynamic> _viewData = <String, dynamic>{
    'selectedBN'        : 0, //選択されたボトムナビゲーションアイテム(int)
    'selectedSpotID'    : null,
    'selectedSpotName'  : null,
    'selectedLatitude'  : null,
    'selectedLongitude' : null,
    '_isSpotSelected'   : false,
    '_isNewPinCreated'  : false,
    '_switchHaveBeen'   : true,
    '_switchKeepSpot'   : true,
    'selectedUserInfo'  : null,
    'selectedSpotInfo'  : null,
    'selectedPostInfo'  : null,
    'newPinFlag'        : false,
    'nowLatitude'       : 35.090867,
    'nowLongitude'      : 138.857391,
    '_sinkPinSpotObj'   : null,
  };

  static final ViewDataManager _cache = ViewDataManager._internal();
  ViewDataManager._internal();

  factory ViewDataManager() {
    return _cache;
  }

  initViewData(){
    _viewData['selectedBN'] = 0;
    _viewData['selectedSpotName'] = null;
    _viewData['selectedLatitude'] = null;
    _viewData['selectedLongitude'] = null;
    _viewData['_isSpotSelected'] = false;
    _viewData['_isNewPinCreated'] = false;
    _viewData['_switchHaveBeen'] = true;
    _viewData['_switchKeepSpot'] = true;
    _viewData['selectedUserInfo'] = null;
    _viewData['selectedSpotInfo'] = null;
    _viewData['selectedPostInfo'] = null;
    _viewData['newPinFlag'] = false;
    _viewData['nowLatitude'] = 35.090867;
    _viewData['nowLongitude'] = 138.857391;
    _viewData['_sinkPinSpotObj'] = null;
  }
  setViewData(String key, dynamic data) => _viewData[key] = data;
  getViewData(String key) => _viewData[key];

}
/////////////////////////////////////////////////////////////////
//自分のアカウント情報を管理するクラス////////////////////////////////
class ActiveAccountDataManager {

  static final Map<String, dynamic> _accountData = <String, dynamic>{
    'id'                    : null,
    'email'                 : null,
    'password'              : null,
    'twitterInfo'           : null,
    'instagramInfo'         : null,
    'isPremium'             : null,
    'profileIcon'           : null,
    'nickname'              : null,
    'introduction'          : null,
    'profileHashtagList'    : null,
    'narrowDownHashtagList' : null,
    'userPostList'          : null,
    'keepUserInfoList'      : null,
    'keepSpotInfoList'      : null,
    'haveBeenSpotInfoList'  : null,
  };

  static final ActiveAccountDataManager _cache = ActiveAccountDataManager._internal();
  ActiveAccountDataManager._internal();

  factory ActiveAccountDataManager() {
    return _cache;
  }


  logoutAccountData(){
    _accountData.forEach((key, value) {
      _accountData[key] = null;
    });
  }

  setAccountData(String key, dynamic data) {
    _accountData[key] = data;
      DataBase().setUserInfo(_accountData['id'], key, data);
  }

  getAccountData(String key) {
    return _accountData[key];
  }

  getAccountDataAll(){
    return _accountData;
  }

}
///////////////////////////////////////////////////////////////////
//アプリの進行に必要な「聖地情報」「投稿情報」「ユーザー情報」を管理するクラス
class AppDataManager {

  List _searchResultSpotInfoList = [];
  List<Map<String, dynamic>> _searchResultPostInfoList;
  List<Map<String, dynamic>> _searchResultUserInfoList;

  List<Map<String, dynamic>> _proposedPostSpotInfoList = <Map<String, dynamic>>[
    {
      'id'                    :'hogespot0',
      'spotName'              :'阿蘭陀館',
      'location'              :'緯度経度情報',
      'postNumberToThisSpot'  :12,
      'hashtagList'           :['#アニメ', '#ラブライブ！サンシャイン!!', '#渡辺曜', '#曜ちゃん', '#ヨキソバ', '#2年生'],
    },
    {
      'id'                    :'hogespot1',
      'spotName'              :'リバーサイドホテル',
      'location'              :'緯度経度情報',
      'postNumberToThisSpot'  :31,
      'hashtagList'           :['#アニメ', '#ラブライブ！サンシャイン!!', '#ヨハネ', '#津島善子'],
    },
    {
      'id'                    :'hogespot2',
      'spotName'              :'長井埼中学校',
      'location'              :'緯度経度情報',
      'postNumberToThisSpot'  :23,
      'hashtagList'           :['#アニメ', '#ラブライブ！サンシャイン!!', '#Aqours' ],
    },
  ];

  static final AppDataManager _cache = AppDataManager._internal();

  AppDataManager._internal();

  factory AppDataManager() {
    return _cache;
  }

  Future<List<Map<String, dynamic>>> getSearchResultUserInfoList( [ dynamic data ] ) async{
    _searchResultUserInfoList = await DataBase().getDBUserData( data );
    return _searchResultUserInfoList;
  }

  Future<List<Map<String, dynamic>>> getSearchResultPostInfoList( [ dynamic data ] ) async{
    _searchResultPostInfoList = await DataBase().getDBPostData( data );
    return _searchResultPostInfoList;
  }

  getSearchResultSpotInfoList( [ dynamic data ] ) async{
    _searchResultSpotInfoList = await DataBase().getDBSpotData( data );
    return _searchResultSpotInfoList;
  }

  //半径300ｍ以内に投稿が存在するスポットを提案する
  //newSpotの緯度経度情報を引数として渡し、スポット情報のリストを返す
  Future<List<Map<String, dynamic>>> getProposedPostSpotInfoList( [double latitude, double longitude] ) async{
    _proposedPostSpotInfoList = [];
    var _spotInfoAll = await DataBase().getDBSpotData();
    var _postIDList = [];
    var _hashtagIDList = [];

    //新規スポットの緯度経度情報
    final Distance distance = new Distance();
    LatLng _newSpotLatLng;
    int _distanceMeter;
    _newSpotLatLng = new LatLng( latitude, longitude );

    for( int i=0; i<_spotInfoAll.length; i++ ){
      var _spotLat = double.parse( _spotInfoAll[i]['Latitude'] );
      var _spotLng = double.parse( _spotInfoAll[i]['Longitude'] );
      var _spotLatLng = new LatLng( _spotLat, _spotLng );
      _distanceMeter = distance( _newSpotLatLng, _spotLatLng );
      _hashtagIDList = [];

      if( _distanceMeter < 3000 ){
        _proposedPostSpotInfoList.add( _spotInfoAll[i] );
        var _postInfoList = await DataBase().getDBPostDataListFromPostIDList( _spotInfoAll[i]['PostToLoc'] );
        for( int j=0; j<_postInfoList.length; j++ ){
          for( int k=0; k<_postInfoList[j]['postHashtagList'].length; k++ ){
            if( _hashtagIDList.indexOf( _postInfoList[j]['postHashtagList'][k] ) == -1 ){
              _hashtagIDList.add( _postInfoList[j]['postHashtagList'][k] );
            }
          }
        }
      }
      var _hashtagInfoList = await DataBase().getDBHashtagDataListFromHashtagIDList( _hashtagIDList );
      var _hashtagDataList = [];
      for( int l=0; l<_hashtagInfoList.length; l++ ){
        if( _hashtagDataList.indexOf( _hashtagInfoList[l]['hashtag'] ) == -1 ){
          _hashtagDataList.add( _hashtagInfoList[l]['hashtag'] );
        }
      }
      _proposedPostSpotInfoList[i]['hashtagList'] = _hashtagDataList;
    }

    return _proposedPostSpotInfoList;
  }
  
}
////////////////////////////////////////////////////////////////////////

//Mapに関するデータ作成 - ピン情報作成 //////////////////////////////////////////
class MapInfo {
  String pageName;
  final StreamSink<Map<String, dynamic>> sinkPinSpot;
  final StreamSink<Map<String, dynamic>> sinkNewPinCreated;
  final StreamSink<Map<String, dynamic>> sinkMap;

  ViewDataManager _vdm = new ViewDataManager();
  ActiveAccountDataManager _aadm = new ActiveAccountDataManager();

  MapInfo(
      {
        this.pageName,
        this.sinkPinSpot,
        this.sinkNewPinCreated,
        this.sinkMap,
      }
      );



  Marker _pin(
      Map selectedSpotInfo, String selectedSpotName, double lat, double lng,
      String pinColorKey, [ bool newPinFlag ]) {
    return Marker(
      width: 50.0,
      height: 50.0,
      point: new LatLng(lat, lng),
      builder: (context) {
        return new InkWell(
          onTap: () async {
            //ログ保存用
            DataBase().addOperationLog(
                'selected pin ${selectedSpotInfo['id']}');

            bool _newPinFlag = newPinFlag == null ? false : newPinFlag;

            if (!_newPinFlag) {
              _vdm.setViewData('selectedSpotInfo', selectedSpotInfo);
              _vdm.setViewData('selectedSpotName', selectedSpotName);
              _vdm.setViewData('selectedLatitude', lat);
              _vdm.setViewData('selectedLongitude', lng);
              _vdm.setViewData('_isSpotSelected', true);
              _vdm.setViewData('_isNewPinCreated', false);

              // pinSpot StreamSink
              Map<String, dynamic> _sinkPinSpotObj;
              _sinkPinSpotObj = {
                'selectedSpotInfo': selectedSpotInfo,
                'selectedSpotName': selectedSpotName,
                'selectedLatitude': lat,
                'selectedLongitude': lng,
                '_isSpotSelected': true,
                'postData': await postDataFromSpotNameNarrowList(
                    selectedSpotName),
              };
              this.sinkPinSpot.add(_sinkPinSpotObj);

              // newPinCreated StreamSink
              Map<String, dynamic> _sinkNewPinCreatedObj = {
                '_isNewPinCreated': false,
              };
              this.sinkNewPinCreated.add(_sinkNewPinCreatedObj);

              // mapViewer StreamSink
              switch (pageName) {
                case 'KeepLocation':
                  Map<String, Map<String, dynamic>> _sinkMapObj;
                  _sinkMapObj = {
                    'mapObj': {
                      '_switchHaveBeen': _vdm.getViewData('_switchHaveBeen'),
                      '_switchKeepSpot': _vdm.getViewData('_switchKeepSpot'),
                      'selectedSpotName': selectedSpotName,
                    }
                  };
                  this.sinkMap.add(_sinkMapObj);
                  break;
                case 'SearchResult':
                  Map<String, dynamic> _sinkMapObj;
                  _sinkMapObj = {
                    'selectedSpotName': selectedSpotName,
                  };
                  this.sinkMap.add(_sinkMapObj);
                  break;
              }
            }
          },
          child: Container(
              child: Icon(
                Icons.location_on,
                color: Defines.colorset[pinColorKey],
                size: 50.0,
              )
          ),
        );
      },
    );
  }

  // KeepLocation用のピン作成
  Future<List<Marker>> pinsMakerKeepLocation(Map<String, dynamic> mapObj) async{
    List<Marker> contentWidgets = List<Marker>();
    bool _newPinFlag = mapObj['newPinFlag']==null ? false : mapObj['newPinFlag'];

    if(mapObj['_switchKeepSpot']) {
      List<Map<String, dynamic>> _pinsInfoKeepSpot;
      _pinsInfoKeepSpot = await DataBase().getDBSpotDataListFromSpotIDList( _aadm.getAccountData('keepSpotInfoList') );

      for (Map<String, dynamic> pin in _pinsInfoKeepSpot) {
        contentWidgets.add(
            _pinCreator(
              pin,
              pin['LocName'],
              double.parse(pin['Latitude'].toString()),
              double.parse(pin['Longitude'].toString()),
              mapObj['selectedSpotName'],
              'KeepLocation',
              'keepspotcolor',
            )
        );
      }
    }

    if(mapObj['_switchHaveBeen']) {
      List<Map<String, dynamic>> _pinsInfoHaveBeen;
      _pinsInfoHaveBeen = await DataBase().getDBSpotDataListFromSpotIDList( _aadm.getAccountData('haveBeenSpotInfoList') );

      for (Map<String, dynamic> pin in _pinsInfoHaveBeen) {
        contentWidgets.add(
            _pinCreator(
              pin,
              pin['LocName'],
              double.parse(pin['Latitude'].toString()),
              double.parse(pin['Longitude'].toString()),
              mapObj['selectedSpotName'],
              'KeepLocation',
              'havebeencolor',
            )
        );
      }
    }

    if(_newPinFlag) {
      contentWidgets.add(
          _newPinCreator('新規ピン', mapObj['newPinInfo']['latitude'], mapObj['newPinInfo']['longitude'])
      );
    }

    return contentWidgets;

    /*
        配列内の後に代入したMarker(ピン)が優先して表示される。
        順番にMarkerをMap上へオーバーレイするため、
        後に表示するものはどんどん上に重ねていくと思われる。
     */
  }

  // SearchResult用のピン作成用の関数
  Future<List<Marker>> pinsMakerSearchResult( String selectedSpotName, bool newPinFlag, Map<String, dynamic> newPinInfo ) async{

    List<Marker> contentWidgets = List<Marker>();
    bool _newPinFlag = newPinFlag==null ? false : newPinFlag;
    List<Map<String, dynamic>> _pinsSpotInfoList = [];
    List<Map<String, dynamic>> _spotDataAll = await DataBase().getDBSpotData();
    List<Map<String, dynamic>> _postDataAll = await DataBase().getDBPostData();
    List<List<String>> hashtagIDList = await _aadm.getAccountData('narrowDownHashtagList');
    List<List<Map<String,dynamic>>> hashtagList = await DataBase().getDBHashtagDataListListFromHashtagIDListList( hashtagIDList ) ;

    //ハッシュタグに何も登録されていない場合は、全てのスポット情報を表示させる。
    if( hashtagIDList.length == 1 && hashtagIDList.first.length == 1 && hashtagIDList.first.first.length == 0 ){
      _pinsSpotInfoList = _spotDataAll;

    } else {

      List<Map<String, dynamic>> tmpSpotList = [];
      List<Map<String, dynamic>> _inputSpot;
      List<Map<String, dynamic>> _inputPost;
      for( int i=0; i<hashtagList.length; i++ ){
        //検索テーブルの初期化（ここでOR条件になる）
        _inputSpot = _spotDataAll;
        _inputPost = _postDataAll;
        for( int j=0; j<hashtagList[i].length; j++ ){
          //検索テーブルをハッシュタグの数の回数分だけ絞り込んでいく（ここでAND条件になる）
          _inputSpot = hashtagNarrowDown(hashtagList[i][j], _inputSpot, _inputPost)['spotList'];
          _inputPost = hashtagNarrowDown(hashtagList[i][j], _inputSpot, _inputPost)['postList'];
        }
        for( int k=0; k<_inputSpot.length; k++ ){
          if( tmpSpotList.indexOf( _inputSpot[k] ) == -1 ){
            tmpSpotList.add( _inputSpot[k] );
          }
        }
        for( int l=0; l<tmpSpotList.length; l++ ){
          if( _pinsSpotInfoList.indexOf( tmpSpotList[l] ) == -1 ){
            _pinsSpotInfoList.add( tmpSpotList[l] );
          }
        }
      }

      /*
      //////////////////////////////////////////////////////////////////////////////////////
      // ハッシュタグで絞り込み結果をピン情報に追加 - スポット情報の名前 - _dbSpotInfoList['LocName'] //
      //////////////////////////////////////////////////////////////////////////////////////
      List<Map<String, dynamic>> _spotnameNarrowDownList1 = await hashtagNarrowDownList(hashtagList, _spotDataAll, 'LocName');
      for(Map<String, dynamic> spotNameNarrowDownData in _spotnameNarrowDownList1) {
        _pinsSpotInfoList.add(spotNameNarrowDownData);
      }

      ///////////////////////////////////////////////////////////////////////////////////////////////////////
      // ハッシュタグで絞り込み結果をSpot情報に変換してピン情報に追加 - 投稿情報のタイトル - _dbPostInfoList['postTitle'] //
      ///////////////////////////////////////////////////////////////////////////////////////////////////////
      List<Map<String, dynamic>> _postpostTitleNarrowDownList = [];
      _postpostTitleNarrowDownList = await hashtagNarrowDownList(hashtagList, _postDataAll, 'postTitle');

      List<String> _spotIDfromPostDataPostTitle = [];
      for(Map<String, dynamic> posttextNarrowDown in _postpostTitleNarrowDownList) {
        _spotIDfromPostDataPostTitle.add(posttextNarrowDown['postSpot']);
      }

      List<Map<String, dynamic>> _spotnameNarrowDownList2 = await DataBase().getDBSpotDataListFromSpotIDList( _spotIDfromPostDataPostTitle );

      for(Map<String, dynamic> spotNameNarrowDownData in _spotnameNarrowDownList2) {
        _pinsSpotInfoList.add(spotNameNarrowDownData);
      }

      ///////////////////////////////////////////////////////////////////////////////////////////////
      // ハッシュタグで絞り込み結果をSpot情報に変換してピン情報に追加 - 投稿情報の本文 - _dbPostInfoList['text'] //
      ///////////////////////////////////////////////////////////////////////////////////////////////
      List<Map<String, dynamic>> _posttextNarrowDownList = [];
      _posttextNarrowDownList = await hashtagNarrowDownList(hashtagList, _postDataAll, 'text');

      List<String> _spotIDfromPostDataText = [];
      for(Map<String, dynamic> posttextNarrowDown in _posttextNarrowDownList) {
        _spotIDfromPostDataText.add(posttextNarrowDown['postSpot']);
      }

      List<Map<String, dynamic>> _spotnameNarrowDownList3 = await DataBase().getDBSpotDataListFromSpotIDList( _spotIDfromPostDataText );

      for(Map<String, dynamic> spotNameNarrowDownData in _spotnameNarrowDownList3) {
        _pinsSpotInfoList.add(spotNameNarrowDownData);
      }

      ///////////////////////////////////////////////////////////////////////////////////////////////////////
      // ハッシュタグで絞り込み結果をSpot情報に変換してピン情報に追加 - 投稿情報のハッシュタグ - _dbPostInfoList['postHashtagList'] //
      ///////////////////////////////////////////////////////////////////////////////////////////////////////
      List<Map<String, dynamic>> _postHashtagListNarrowDownList = [];
      _postpostTitleNarrowDownList = await hashtagNarrowDownList(hashtagList, _postDataAll, 'postHashtagList');

      List<String> _spotIDfromPostDataPostHashtagList = [];
      for(Map<String, dynamic> posttextNarrowDown in _postpostTitleNarrowDownList) {
        _spotIDfromPostDataPostHashtagList.add(posttextNarrowDown['postSpot']);
      }

      List<Map<String, dynamic>> _spotnameNarrowDownList4 = await DataBase().getDBSpotDataListFromSpotIDList( _spotIDfromPostDataPostHashtagList );

      for(Map<String, dynamic> spotNameNarrowDownData in _spotnameNarrowDownList4) {
        _pinsSpotInfoList.add(spotNameNarrowDownData);
      }

       */
    }



    //////////////////////////////////////////////////////////////////////////////////////////////////////
    // _pinsSpotInfoList情報からピンを作成
    for (Map<String, dynamic> pin in _pinsSpotInfoList) {
      contentWidgets.add(
          _pinCreator(
            pin,
            pin['LocName'],
            double.parse(pin['Latitude'].toString()),
            double.parse(pin['Longitude'].toString()),
            selectedSpotName,
            'SearchResult',
          )
      );
    }

    if(_newPinFlag) {
      contentWidgets.add(
          _newPinCreator('新規ピン', newPinInfo['latitude'], newPinInfo['longitude'])
      );
    }

    /////////////////////////////////
    //Markerのクラスタリング処理を入れる
    /////////////////////////////////


    return contentWidgets;
  }

  Marker _pinCreator(Map selectedSpotInfo, String locName, double latitude, double longitude, String selectedSpotName, String pageName, [ String colorKey ]) {
    Marker _tmpPin;

    if(locName == selectedSpotName) {
      _tmpPin = _pin(selectedSpotInfo, locName, latitude, longitude, 'selectedcolor');
    } else {
      switch (pageName) {
        case 'KeepLocation':
          _tmpPin = _pin(selectedSpotInfo, locName, latitude, longitude, colorKey);
          break;
        case 'SearchResult':
          _tmpPin = _pin(selectedSpotInfo, locName, latitude, longitude, 'highlightcolor');
          break;
        default:
          _tmpPin = null;
      }
    }

    return _tmpPin;
  }

  Marker _newPinCreator(String locName, double latitude, double longitude) {
    Marker _tmpPin = _pin(null, locName, latitude, longitude, 'newspotcolor', true);

    return _tmpPin;
  }

  CircleMarker nowSpotMarker(double lat, double lng) {
    double _lat = lat==null ? 35.090867 : lat;
    double _lng = lng==null ? 138.857391 : lng;

    CircleMarker _nowSpotMarker = CircleMarker(
      point: LatLng(_lat, _lng),
      color: Defines.colorset['nowpointer'],
      borderStrokeWidth: 2,
      useRadiusInMeter: true,
      radius: 50,
    );

    return _nowSpotMarker;
  }
}

////////////////////////////////////////////////////////////////////////


