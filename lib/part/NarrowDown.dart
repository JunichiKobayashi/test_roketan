
import 'package:test_roketan/part/DataBase.dart';
import 'package:test_roketan/part/DataManager.dart';

Future<List<Map<String, dynamic>>> hashtagNarrowDownList(
    List<List<Map<String, dynamic>>> hashtagMapList,
    List<Map<String, dynamic>> conditionsListMap,
    String key
    ) async{

  List<Map<String, dynamic>> _resultList = [];
  List<Map<String, dynamic>> _hashtagListMap = [];
  List<List<Map<String,dynamic>>> hashtagList = hashtagMapList;

  //ハッシュタグを２次元→１次元に整理するための処理
  for( int i=0; i<hashtagList.length; i++ ){
    for( int j=0; j<hashtagList[i].length; j++ ){
      _hashtagListMap.add(hashtagList[i][j]);
    }
  }

  List<String> _hashtagList = [];
  List<String> _conditionsList = [];
  List<List<String>> _conditionsListList = [];

  // ActiveAccountDataManagerのハッシュタグ情報をList<String>に整形
  // 大文字小文字は関係なくヒット（小文字に揃える）
  for(Map<String, dynamic> hashtagMap in _hashtagListMap) {
    _hashtagList.add(hashtagMap['hashtag'].toString().toLowerCase());
  }

  // 検索条件(conditionsListMap)の情報をList<String>に整形
  // 大文字小文字は関係なくヒット（小文字に揃える）
  for(Map<String, dynamic> conditionMap in conditionsListMap) {
    if( key == 'postHashtagList' ){
      List<Map<String, dynamic>> hashtagDataList = await DataBase().getDBHashtagDataListFromHashtagIDList( conditionMap[key] );
      _conditionsList = [];
      for( int i=0; i<conditionMap[key].length; i++ ){
        _conditionsList.add( hashtagDataList[i]['hashtag'] );
      }
      _conditionsListList.add( _conditionsList );
    } else {
      _conditionsList.add(conditionMap[key].toString().toLowerCase());
    }
  }

  // ハッシュタグで絞り込み - 曖昧検索 - 複数ヒットに対応
  //ハッシュタグの場合は２次元のリストでデータを持つので特別仕様
  if( key == 'postHashtagList' ){
    for(String hashtag in _hashtagList) {
      for( int i=0; i<_conditionsListList.length; i++ ){
        for( int j=0; j<_conditionsListList[i].length; j++ ){
          bool containsFlag = _conditionsListList[i][j].contains(hashtag);
          if(containsFlag && _resultList.indexOf( conditionsListMap[i] ) == -1 ) {
            _resultList.add(conditionsListMap[i]);
          }
        }
      }
    }
    return _resultList;
  } else {
    for(String hashtag in _hashtagList) {
      for(int i=0; i<_conditionsList.length; i++) {
        bool containsFlag = _conditionsList[i].contains(hashtag);
        if(containsFlag) {
          _resultList.add(conditionsListMap[i]);
        }
      }
    }
    return _resultList;
  }
}


Map<String,List<Map<String, dynamic>>> hashtagNarrowDown(
    Map<String, dynamic> hashtagMap,
    List<Map<String, dynamic>> spotInfoAll,
    List<Map<String, dynamic>> postInfoAll,
    ) {

  List<Map<String, dynamic>> spotInfoAllForSearch = spotInfoAll;
  List<Map<String, dynamic>> postInfoAllForSearch = postInfoAll;
  Map<String, dynamic> hashtagMapForSearch = hashtagMap;

  List<Map<String, dynamic>> hitSpotInfoList = [];
  List<Map<String, dynamic>> hitPostInfoList = [];

  // ハッシュタグの情報を整形
  // 大文字小文字は関係なくヒット（小文字に揃える）
  hashtagMapForSearch['hashtag'] = hashtagMap['hashtag'].toString().toLowerCase();

  //////////////////////////////////////////////////////////////////////////////////////////
  // 検索条件の情報を整形・・・「スポット名で検索」するパート
  // 大文字小文字は関係なくヒット（小文字に揃える）
  //////////////////////////////////////////////////////////////////////////////////////////
  for( int i=0; i<spotInfoAllForSearch.length; i++ ){
    spotInfoAllForSearch[i]['LocName'] = spotInfoAllForSearch[i]['LocName'].toString().toLowerCase();
    if( spotInfoAllForSearch[i]['LocName'].contains(hashtagMapForSearch['hashtag']) ){
      //重複する場合は無視
      if( hitSpotInfoList.indexOf( spotInfoAllForSearch[i] ) == -1 ){
        //spotInfoAllForSearch[i]をaddするのは間違い。toLowerCase以前の元データをaddする
        hitSpotInfoList.add( spotInfoAll[i] );
      }
    }
  }

  //////////////////////////////////////////////////////////////////////////////////////////
  // 検索条件の情報を整形・・・「投稿タイトルで検索」「投稿本文で検索」するパート
  // 大文字小文字は関係なくヒット（小文字に揃える）
  //////////////////////////////////////////////////////////////////////////////////////////
  List<String> tmpSpotIDList = [];
  for( int i=0; i<postInfoAllForSearch.length; i++ ){
    postInfoAllForSearch[i]['postTitle'] = postInfoAllForSearch[i]['postTitle'].toString().toLowerCase();
    postInfoAllForSearch[i]['text'] = postInfoAllForSearch[i]['text'].toString().toLowerCase();
    // 投稿タイトル　または　投稿本文　のどちらかにヒットする場合
    if( postInfoAllForSearch[i]['postTitle'].contains(hashtagMapForSearch['hashtag'])
        || postInfoAllForSearch[i]['text'].contains(hashtagMapForSearch['hashtag']) ){
      if( tmpSpotIDList.indexOf( postInfoAllForSearch[i]['postSpot'] ) == -1 ){
        //hisPostSpotをaddしないといけないのでpostInfoAllForSearchを使う
        tmpSpotIDList.add( postInfoAllForSearch[i]['postSpot'] );
      }
      if( hitPostInfoList.indexOf( postInfoAllForSearch[i] ) == -1 ){
        hitPostInfoList.add( postInfoAllForSearch[i] );
      }
    }
  }

  //////////////////////////////////////////////////////////////////////////////////////////
  // 検索条件の情報を整形・・・「ハッシュタグで検索」するパート
  // ハッシュタグに関しては、完全一致だけをヒットさせるのでtoLowerCaseしない。IDで一致確認する
  // tmpSpotIDListは上から引き継ぐ。
  //////////////////////////////////////////////////////////////////////////////////////////
  for( int i=0; i<postInfoAll.length; i++ ){
    for( int j=0; j<postInfoAll[i]['postHashtagList'].length; j++ ){
      if( hashtagMap['id'] == postInfoAll[i]['postHashtagList'][j] ){
        if( tmpSpotIDList.indexOf( postInfoAll[i]['postSpot'] ) == -1 ){
          tmpSpotIDList.add( postInfoAll[i]['postSpot'] );
        }
        if( hitPostInfoList.indexOf( postInfoAllForSearch[i] ) == -1 ){
          hitPostInfoList.add( postInfoAllForSearch[i] );
        }
      }
    }
  }

  ///////////////////////////////////////////////////////////////////////////////////////////
  //スポットIDのリストから重複を避けてhitSpotInfoListにaddする
  ///////////////////////////////////////////////////////////////////////////////////////////
  for( int i=0; i<tmpSpotIDList.length; i++ ){
    for( int j=0; j<spotInfoAll.length; j++ ){
      if( tmpSpotIDList[i] == spotInfoAll[j]['id'] ){
        if( hitSpotInfoList.indexOf( spotInfoAll[j] ) == -1 ){
          hitSpotInfoList.add( spotInfoAll[j] );
        }
      }
    }
  }


  return { 'spotList' : hitSpotInfoList, 'postList' : hitPostInfoList };
}



Future<String> spotIdFromSpotNameSearch(String spotName) async{
  String _result;

  List<Map<String, dynamic>> _originSpotData = await DataBase().getDBSpotData();
  List<String> _originSpotNameList = [];

  for(Map<String, dynamic> originSpot in _originSpotData) {
    _originSpotNameList.add(originSpot['LocName'].toString());
  }

  int searchIndex = _originSpotNameList.indexOf(spotName);
  _result = _originSpotData[searchIndex]['id'];

  return _result;
}

Future<List<Map<String, dynamic>>> postDataFromSpotNameNarrowList(String spotName) async{
  List<Map<String, dynamic>> _resultList = [];

  List<Map<String, dynamic>> _originPostData = await DataBase().getDBPostData();
  List<String> _originSpotIdList = [];

  for(Map<String, dynamic> originSpot in _originPostData) {
    _originSpotIdList.add(originSpot['postSpot']);
  }

  String _spotId = await spotIdFromSpotNameSearch(spotName);

  for(int i=0; i<_originSpotIdList.length; i++) {
    bool containsFlag = _originSpotIdList[i].contains(_spotId);
    if(containsFlag) {
      _resultList.add(_originPostData[i]);
    }
  }

  return _resultList;
}
