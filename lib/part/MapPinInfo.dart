
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:test_roketan/part/CreateSearchBoxWidget.dart';
import 'package:test_roketan/part/DataBase.dart';
import 'package:test_roketan/part/Defines.dart' as Defines;
import 'package:test_roketan/part/DataManager.dart';
import 'package:test_roketan/part/PostListViewWidget.dart';
import 'package:test_roketan/part/SpotListViewWidget.dart';
import 'package:test_roketan/view/MainView.dart';
import 'package:latlong/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import 'getLocation.dart';

class pinSpot extends StatefulWidget {
  final Function onTapToSubPage;
  final Stream<Map<String, dynamic>> stream;
  final String herotag;

  pinSpot({
    this.onTapToSubPage,
    this.stream,
    this.herotag,
  });
  @override
  _pinSpotState createState() => _pinSpotState(stream: stream, herotag: this.herotag);
}

class _pinSpotState extends State<pinSpot> {
  @override

  final Stream<Map<String, dynamic>> stream;
  final String herotag;

  _pinSpotState({
    this.stream,
    this.herotag,
  });

  //データマネージャのインスタンス生成
  ViewDataManager _vdm = new ViewDataManager();
  ActiveAccountDataManager _aadm = new ActiveAccountDataManager();

  double _heightRate;
  double _maxHeightRate;
  double _minHeightRate;

  initState() {
    super.initState();
    _heightRate = 0.5;
    _maxHeightRate = 1.0;
    _minHeightRate = 0.2;
  }

  int _postDataCount = 0;
  List<Map<String, dynamic>> _postData = [];

  int _keepSpotUserNumberOfThisSpot = 0;
  int _haveBeenUserNumberToThisSpot = 0;

  bool _offstageCaution = true;

  //GPS用データ
  Location _locationService = Location();
  LocationData _nowLocationData;
  LatLng _nowLatLng;

  void _getLocation() async{
    _nowLocationData = await compute(getLocationData, _locationService);
    _nowLatLng = new LatLng(_nowLocationData.latitude, _nowLocationData.longitude);
  }


  bool isKeepSpot(){
    var _keep = _aadm.getAccountData('keepSpotInfoList');
    var _select;
    if( _vdm.getViewData('selectedSpotInfo') != null ){
      _select = _vdm.getViewData('selectedSpotInfo')['id'];
    }
    if( _keep.indexOf(_select) != -1 ){
      return true;
    } else {
      return false;
    }
  }

  bool isHaveBeen() {

    var _keep = _aadm.getAccountData('haveBeenSpotInfoList');
    var _select;
    if( _vdm.getViewData('selectedSpotInfo') != null ){
      _select = _vdm.getViewData('selectedSpotInfo')['id'];
    }
    if( _keep.indexOf(_select) != -1 ){
      return true;
    } else {
      return false;
    }
  }


  void _onTapButtonKS() {
    var _myID = _aadm.getAccountData('id');
    var _premium = _aadm.getAccountData('isPremium');
    var _keep = _aadm.getAccountData('keepSpotInfoList');
    var _select;
    if( _vdm.getViewData('selectedSpotInfo') != null ){
      _select = _vdm.getViewData('selectedSpotInfo')['id'];
    }
    if( isKeepSpot() == true ){
      _keep.removeAt( _keep.indexOf(_select) );
      setState(() {
        _aadm.setAccountData('keepSpotInfoList', _keep);
        DataBase().updateSpotInfo(_select, 'keepSpotUserInfoList', _myID, 'remove');
      });
    } else {
      //プレミアム会員なら１１件以上登録可能
      if( _premium == true || _keep.length < 11 ){
        _keep.add(_select);
        setState(() {
          _aadm.setAccountData('keepSpotInfoList', _keep);
          DataBase().updateSpotInfo(_select, 'keepSpotUserInfoList', _myID, 'add');
        });
      }
    }
  }
  void _onTapButtonHB() {
    var _myID = _aadm.getAccountData('id');
    var _premium = _aadm.getAccountData('isPremium');
    var _keep = _aadm.getAccountData('haveBeenSpotInfoList');
    var _select;
    if( _vdm.getViewData('selectedSpotInfo') != null ){
      _select = _vdm.getViewData('selectedSpotInfo')['id'];
    }


    final Distance distance = new Distance();
    _getLocation();
    LatLng _selectedLatLng;
    int _distanceMeter;
    if( _vdm.getViewData('selectedSpotInfo') != null && _nowLatLng != null ){
      double _selectedLat = double.parse( _vdm.getViewData('selectedSpotInfo')['Latitude'] );
      double _selectedLng = double.parse( _vdm.getViewData('selectedSpotInfo')['Longitude'] );
      _selectedLatLng = new LatLng( _selectedLat, _selectedLng );
      _distanceMeter = distance( _selectedLatLng, _nowLatLng );

      if( isHaveBeen() == true ){
        //_keep.removeAt( _keep.indexOf(_select) );
        setState(() {
          //_vdm.setViewData('haveBeenSpotInfoList', _keep);
        });
      } else {
        //プレミアム会員なら距離制限なく「行った」できる
        if( _premium == true ){
          _keep.add(_select);
          setState(() {
            _aadm.setAccountData('haveBeenSpotInfoList', _keep);
            DataBase().updateSpotInfo(_select, 'haveBeenUserInfoList', _myID, 'add');
          });
        }
        //ノーマル会員は、１キロ以内かつ１０件まで「行った」できる
        if( _distanceMeter < 1000 && _keep.length < 11 ){
          _keep.add(_select);
          setState(() {
            _aadm.setAccountData('haveBeenSpotInfoList', _keep);
            DataBase().updateSpotInfo(_select, 'haveBeenUserInfoList', _myID, 'add');
          });
        }
      }
    }
  }


  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: this.stream,
        builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if(snapshot.hasData) {
            if(snapshot.data['postData']!=null) {
              _postData = snapshot.data['postData'];
              _postDataCount = snapshot.data['postData'].length;
              _keepSpotUserNumberOfThisSpot = snapshot.data['selectedSpotInfo']['keepSpotUserInfoList'].length;
              _haveBeenUserNumberToThisSpot = snapshot.data['selectedSpotInfo']['haveBeenUserInfoList'].length;
            } else {
              _postData = [];
              _postDataCount = 0;
              _keepSpotUserNumberOfThisSpot = 0;
              _haveBeenUserNumberToThisSpot = 0;
            }
          }
          return Offstage(
              offstage: snapshot.hasData ? !snapshot.data['_isSpotSelected'] : true,
              child: Container(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  widthFactor: 1.0,
                  heightFactor: _heightRate,
                  child: Container(
                    //padding: EdgeInsets.only(top: 8.0),
                    decoration: BoxDecoration(
                      color: Defines.colorset['backgroundcolor'],
                      borderRadius: const BorderRadius.only(
                        topRight: const Radius.circular(20),
                        topLeft: const Radius.circular(20),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          child: Column(
                            children: [
                              // 動かすためのバー
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  height: 32,
                                  padding: EdgeInsets.only(top: 8.0, bottom: 16.0 ),
                                  child: Container(
                                    width: 60.0,
                                    height: 8.0,
                                    decoration: BoxDecoration(
                                      color: Defines.colorset['drawcolor'],
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                ),
                                onPanUpdate: (details) {
                                  setState(() {
                                    _heightRate -= details.delta.dy/600;
                                    if (_heightRate  > _maxHeightRate)
                                      _heightRate = _maxHeightRate;
                                    else if (_heightRate < _minHeightRate )
                                      _heightRate = _minHeightRate;
                                  });
                                },
                              ),
                              //
                              Expanded(
                                child: Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Stack(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Defines.colorset['backgroundcolor'],
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Defines.colorset['drawcolor'],
                                                ),
                                              ),
                                            ),
                                            height: 60,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: GestureDetector(
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          width: 60,
                                                          child: Icon(
                                                            Icons.flag,
                                                            color: Defines.colorset['drawcolor'],
                                                            size: 40.0,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Container(
                                                            child: RichText(
                                                              overflow: TextOverflow.ellipsis,
                                                              text: TextSpan(
                                                                text: snapshot.hasData ? snapshot.data['selectedSpotName'] : '',
                                                                style: TextStyle(
                                                                  color: Defines
                                                                      .colorset['darkdrawcolor'],
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 28.0,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    onTap: (){},
                                                  ),
                                                ),
                                                Container(
                                                  width: 60,
                                                  child: IconButton(
                                                    icon: Icon(
                                                      Icons.directions_car,
                                                      color: Defines.colorset['highlightcolor'],
                                                    ),
                                                    iconSize: 40.0,
                                                    onPressed: (){
                                                      if( _aadm.getAccountData('isPremium') ){
                                                        String lat = snapshot.data['selectedSpotInfo']['Latitude'];
                                                        String lng = snapshot.data['selectedSpotInfo']['Longitude'];
                                                        String url = "https://www.google.com/maps/dir/?api=1&destination=${lat},${lng}";
                                                        launch(url);
                                                      } else {
                                                        setState(() {
                                                          _offstageCaution = false;
                                                        });
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Offstage(
                                            offstage: _offstageCaution,
                                            child: Container(
                                              width: double.infinity,
                                              height: 60,
                                              color: Colors.grey[300].withOpacity(0.9),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Center(
                                                      child: Text(
                                                        'プレミアム会員登録するとルート案内がご利用になれます',
                                                        style: TextStyle(
                                                          color: Defines.colorset['darkdrawcolor'],
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.symmetric(horizontal: 10),
                                                    child: FlatButton(
                                                      child: Text('OK'),
                                                      onPressed: (){
                                                        setState(() {
                                                          _offstageCaution = true;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Flexible(
                                        child: ListView(
                                          //shrinkWrap: true,
                                          children: [
                                            Container(
                                              height: 100.0,
                                              padding: EdgeInsets.only(left: 4.0, right: 4.0),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        border: Border(
                                                          top: BorderSide(
                                                            color: Defines.colorset['drawcolor'],
                                                          ),
                                                          bottom: BorderSide(
                                                            color: Defines.colorset['drawcolor'],
                                                          ),
                                                          right: BorderSide(
                                                            color: Defines.colorset['drawcolor'],
                                                          ),
                                                        ),
                                                      ),
                                                      child: Container(
                                                        padding: EdgeInsets.all(4.0),
                                                        child: CreateActionButtonToThisSpotWidget(
                                                          iconData: Icons.bookmark,
                                                          title: '保存済み',
                                                          number3: _keepSpotUserNumberOfThisSpot,
                                                          active: isKeepSpot(),
                                                          onTap: _onTapButtonKS,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        border: Border(
                                                          top: BorderSide(
                                                            color: Defines.colorset['drawcolor'],
                                                          ),
                                                          bottom: BorderSide(
                                                            color: Defines.colorset['drawcolor'],
                                                          ),
                                                        ),
                                                      ),
                                                      child: CreateActionButtonToThisSpotWidget(
                                                        //optionText1_1: 'あなたは過去に',
                                                        //optionNumber1: _haveBeenTimesToThisSpot,
                                                        //optionText1_2: '回行きました',
                                                        iconData: Icons.location_on_sharp,
                                                        title: '行った',
                                                        number3: _haveBeenUserNumberToThisSpot,
                                                        active: isHaveBeen(),
                                                        onTap: _onTapButtonHB,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              height: 24,
                                              padding: EdgeInsets.only(left: 20.0),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  RichText(
                                                    text: TextSpan(
                                                      text: _postDataCount.toString(),
                                                      style: TextStyle(
                                                        color: Defines.colorset['darkdrawcolor'],
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16.0,
                                                      ),
                                                    ),
                                                  ),
                                                  RichText(
                                                    text: TextSpan(
                                                      text: ' 件の投稿',
                                                      style: TextStyle(
                                                        color: Defines.colorset['drawcolor'],
                                                        fontWeight: FontWeight.normal,
                                                        fontSize: 14.0,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: double.infinity,
                                              height: 400,
                                              child: CustomScrollView(
                                                slivers: <Widget>[
                                                  PostListViewWidget(
                                                    postDataList: _postData,
                                                    onTapToSubPage: (int index) => widget.onTapToSubPage(index),
                                                  ),
                                                ],
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
                        ),
                        Container(
                            padding: EdgeInsets.all(24.0),
                            alignment: Alignment.bottomRight,
                            child: FloatingActionButton(
                              heroTag: 'ExistingHero:' + this.herotag,
                              onPressed: (){
                                widget.onTapToSubPage(SubPageName.Post.index);
                              },
                              backgroundColor: Defines.colorset['selectedcolor'],
                              child: Icon(
                                Icons.add_location_outlined,
                                size: 40.0,
                              ),
                            )
                        ),
                      ],
                    ),
                  ),
                ),
              )
          );
        }
    );
  }
}

class newPinCreate extends StatefulWidget {
  final Function onTapToSubPage;
  final Stream<Map<String, dynamic>> stream;
  final String herotag;

  newPinCreate({
    this.onTapToSubPage,
    this.stream,
    this.herotag,
  });

  @override
  _newPinCreateState createState() => _newPinCreateState(stream: stream, herotag: this.herotag);
}

class _newPinCreateState extends State<newPinCreate> {
  final Stream<Map<String, dynamic>> stream;
  final String herotag;

  _newPinCreateState({
    this.stream,
    this.herotag,
  });

  double _heightRate;
  double _maxHeightRate;
  double _minHeightRate;

  double _newPinLatitude;
  double _newPinLongitude;

  ViewDataManager _vdm = new ViewDataManager();
  AppDataManager _appdm = new AppDataManager();

  initState() {
    super.initState();
    _heightRate = 0.5;
    _maxHeightRate = 1.0;
    _minHeightRate = 0.1;
  }

  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: this.stream,
        builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if( snapshot.hasData ){
            _newPinLatitude = snapshot.data['latitude'];
            _newPinLongitude = snapshot.data['longitude'];
          }
          return Offstage(
            offstage: snapshot.hasData ? !snapshot.data["_isNewPinCreated"] : true,
            child: Container(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                widthFactor: 1.0,
                heightFactor: _heightRate,
                child: Container(
                  //padding: EdgeInsets.only(top: 8.0),
                  decoration: BoxDecoration(
                    color: Defines.colorset['backgroundcolor'],
                    borderRadius: const BorderRadius.only(
                      topRight: const Radius.circular(20),
                      topLeft: const Radius.circular(20),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        child: Column(
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                height: 32,
                                padding: EdgeInsets.only(top: 8.0, bottom: 16.0 ),
                                child: Container(
                                  width: 60.0,
                                  height: 8.0,
                                  decoration: BoxDecoration(
                                    color: Defines.colorset['drawcolor'],
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                  ),
                                ),
                              ),
                              onPanUpdate: (details) {
                                setState(() {
                                  _heightRate -= details.delta.dy/600;
                                  if (_heightRate  > _maxHeightRate)
                                    _heightRate = _maxHeightRate;
                                  else if (_heightRate < _minHeightRate )
                                    _heightRate = _minHeightRate;
                                });
                              },
                            ),
                            Expanded(
                              child: Container(
                                child: ListView(
                                  children: [
                                    Container(
                                      height: 60,
                                      color: Defines.colorset['backgroundcolor'],
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 60,
                                            child: Icon(
                                              Icons.flag,
                                              color: Defines.colorset['drawcolor'],
                                              size: 40.0,
                                            ),
                                          ),
                                          Expanded(
                                            child: CreateSearchBoxWidget(
                                              hitText: '候補を絞り込む',
                                              onChanged: null,
                                              onSubmitted: null,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      height: 36,
                                      padding: EdgeInsets.only(left: 4.0, right: 4.0),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Defines.colorset['drawcolor'],
                                          ),
                                        ),
                                      ),
                                      child: RichText(
                                        text: TextSpan(
                                          text: 'もしかしてここですか？',
                                          style: TextStyle(
                                            color: Defines.colorset['drawcolor'],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: Text(
                                        '「もしかしてここですか？」は今後実装予定ですm(_ _)m',
                                        style: TextStyle(
                                          color: Defines.colorset['drawcolor'],
                                        ),
                                      ),
                                    ),
                                    /*
                                    !snapshot.hasData ? Container() : SpotListViewWidget(
                                      spotDataList: _appdm.getProposedPostSpotInfoList(
                                          _newPinLatitude,
                                          _newPinLongitude,
                                      ),
                                      onTapSpotNameToPostPage: null,
                                      onTapPostNumberToSpotInfo: null,
                                      onTapHashtagToSearchResult: null,
                                    ),

                                     */
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.all(24.0),
                          alignment: Alignment.bottomRight,
                          child: FloatingActionButton(
                            heroTag: 'NewHero:' + this.herotag,
                            onPressed: (){
                              if(snapshot.hasData) {
                                _vdm.setViewData('selectedLatitude', snapshot.data['latitude']);
                                _vdm.setViewData('selectedLongitude', snapshot.data['longitude']);
                                widget.onTapToSubPage(SubPageName.Post.index);
                              }
                              // widget.onTapToSubPage(SubPageName.Post.index);
                            },
                            backgroundColor: Defines.colorset['newspotcolor'],
                            child: Icon(
                              Icons.add_location_outlined,
                              size: 40.0,
                            ),
                          )
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
    );
  }
}

// Map全体をタップして、情報表示や新規マップ作成画面を消す
void mapTap(ViewDataManager _vdm, StreamController<Map<String, dynamic>> _pinsStreamController,
    StreamController<Map<String, dynamic>> _pinsCreateStreamController,
    StreamController _mapStreamController, String pageName) {

  _vdm.setViewData('_isSpotSelected', false);
  _vdm.setViewData('_isNewPinCreated', false);
  _vdm.setViewData('selectedSpotID', null);
  _vdm.setViewData('selectedSpotName', null);
  _vdm.setViewData('selectedLatitude', null);
  _vdm.setViewData('selectedLongitude', null);

  Map<String, dynamic> _sinkObj = {
    '_isSpotSelected' : false,
  };

  Map<String, dynamic> _sinkPinsCreateObj = {
    '_isNewPinCreated': false,
  };

  _pinsStreamController.sink.add(_sinkObj);
  _pinsCreateStreamController.sink.add(_sinkPinsCreateObj);

  switch(pageName) {
    case 'KeepLocation':
      Map<String, Map<String, dynamic>> _sinkMapObj;
      _sinkMapObj = {
        'mapObj': {
          '_switchHaveBeen' : _vdm.getViewData('_switchHaveBeen'),
          '_switchKeepSpot' : _vdm.getViewData('_switchKeepSpot'),
          'selectedSpotName': null,
        }
      };
      _mapStreamController.sink.add(_sinkMapObj);
      break;
    case 'SearchResult':
      Map<String, dynamic> _sinkMapObj;
      _sinkMapObj = {
        'selectedSpotName':  null,
      };
      _mapStreamController.sink.add(_sinkMapObj);
      break;
  }
}

void mapLongTap(LatLng point, ViewDataManager _vdm, StreamController<Map<String, dynamic>> _pinsSpotStreamController, StreamController<Map<String, dynamic>> _pinsNewCraetedStreamController, StreamController<Map<String, dynamic>> _mapStreamController, String pageName) {
  _vdm.setViewData('_isSpotSelected', false);
  _vdm.setViewData('_isNewPinCreated', true);
  _vdm.setViewData('selectedSpotID', null);
  _vdm.setViewData('selectedSpotName', null);


  // pinSpot StreamSink
  Map<String, dynamic> _sinkPinSpotObj = {
    '_isSpotSelected': false,
  };
  _pinsSpotStreamController.sink.add(_sinkPinSpotObj);

  // newPinCreated StreamSink
  Map<String, dynamic> _sinkNewPinCreatedObj = {
    '_isNewPinCreated': true,
    'latitude': point.latitude,
    'longitude': point.longitude,
  };

  _pinsNewCraetedStreamController.add(_sinkNewPinCreatedObj);


  // mapViewer StreamSink
  switch(pageName) {
    case 'KeepLocation':
      Map<String, Map<String, dynamic>> _sinkMapObj = {
        'mapObj': {
          '_switchHaveBeen' : _vdm.getViewData('_switchHaveBeen'),
          '_switchKeepSpot' : _vdm.getViewData('_switchKeepSpot'),
          'selectedSpotName': null,
          'newPinFlag': true,
          'newPinInfo': {
            'latitude': point.latitude,
            'longitude': point.longitude,
          }
        }
      };
      _mapStreamController.sink.add(_sinkMapObj);
      break;
    case 'SearchResult':
      Map<String, dynamic> _sinkMapObj = {
        'newPinFlag': true,
        'newPinInfo': {
          'latitude': point.latitude,
          'longitude': point.longitude,
        }
      };
      _mapStreamController.sink.add(_sinkMapObj);
      break;
  }

}

class CreateActionButtonToThisSpotWidget extends StatelessWidget {
  final String optionText1_1;
  final int optionNumber1;
  final optionText1_2;
  final IconData iconData;
  final String title;
  final int number3;
  final String text3;
  final bool active;
  final Function onTap;

  CreateActionButtonToThisSpotWidget({
    this.optionText1_1,
    this.optionNumber1,
    this.optionText1_2,
    this.iconData,
    this.title,
    this.number3,
    this.text3,
    this.active,
    this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(top: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                  text: optionText1_1 != null  ? optionText1_1 + ' ' : '',
                  style: TextStyle(
                    color: Defines.colorset['drawcolor'],
                    fontWeight: FontWeight.normal,
                    fontSize: 12.0,
                  ),
                ),
              ),
              RichText(
                text: TextSpan(
                  text: optionNumber1 != null ? optionNumber1.toString() : '',
                  style: TextStyle(
                    color: Defines.colorset['darkdrawcolor'],
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                  ),
                ),
              ),
              RichText(
                text: TextSpan(
                  text: optionText1_2 != null ? ' ' + optionText1_2 : '',
                  style: TextStyle(
                    color: Defines.colorset['drawcolor'],
                    fontWeight: FontWeight.normal,
                    fontSize: 12.0,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GestureDetector(
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    iconData,
                    color: active
                        ? Defines.colorset['highlightcolor']
                        : Defines.colorset['drawcolor'],
                    size: active ? 40.0 : 32.0,
                  ),
                  RichText(
                    text: TextSpan(
                      text: title,
                      style: TextStyle(
                        color: active
                            ? Defines.colorset['highlightcolor']
                            : Defines.colorset['drawcolor'],
                        fontWeight: active
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: active ? 20.0 : 16.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            onTap: (){ onTap(); },
          ),
        ),
        Container(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                  text: number3.toString(),
                  style: TextStyle(
                    color: Defines.colorset['darkdrawcolor'],
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                  ),
                ),
              ),
              RichText(
                text: TextSpan(
                  text: ' 人のユーザー',
                  style: TextStyle(
                    color: Defines.colorset['drawcolor'],
                    fontWeight: FontWeight.normal,
                    fontSize: 12.0,
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