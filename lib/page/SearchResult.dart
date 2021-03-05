
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';
import 'package:test_roketan/part/DataBase.dart';
import 'package:test_roketan/part/DataManager.dart';
import 'package:test_roketan/part/Defines.dart' as Defines;
import 'package:test_roketan/part/NarrowDown.dart';
import 'package:test_roketan/part/PostListViewWidget.dart';
import 'package:test_roketan/part/UserListViewWidget.dart';
import 'package:test_roketan/part/CreateTopTabItemWidget.dart';
import 'package:test_roketan/part/MapPinInfo.dart';
import 'package:test_roketan/part/getLocation.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';


class Choice {
  const Choice({this.title});
  final String title;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: '聖地'),
  const Choice(title: '投稿'),
  const Choice(title: 'ユーザー'),
];

enum TopTab {
  spot,
  post,
  user,
}

class SearchResult extends StatefulWidget {
  final Function onTapToSubPage;
  final StreamController<Map<String, dynamic>> pinsSpotStreamController;

  SearchResult({
    this.onTapToSubPage,
    this.pinsSpotStreamController,
  });

  @override
  _SearchResultState createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {

  //データマネージャのインスタンス作成
  AppDataManager _appdm = new AppDataManager();
  ActiveAccountDataManager _aadm = new ActiveAccountDataManager();

  // StreamController作成
  final _mapStreamController = StreamController<Map<String, dynamic>>();
  // final pinsSpotStreamController = StreamController<Map<String, dynamic>>();
  final _pinsCreateStreamController = StreamController<Map<String, dynamic>>();


  //トップタブの初期化　最初は一番左が選択されている状態(true)
  List<bool> _activeTopTab = [true, false, false];

  void _onTappedTopTab(int index) {
    setState(() {
      //全て非選択(false)で初期化
      for (int i = 0; i < _activeTopTab.length; i++) { _activeTopTab[i] = false; }
      //選択したトップタブアイテムだけ選択(true)に反転させる
      _activeTopTab[index] = true;
    });
  }

  void _keepRelease( int index ) async{
    List<dynamic> _userIDList;
    List<Map<String, dynamic>> _userInfoList;
    _userIDList = await _aadm.getAccountData('keepUserInfoList');
    _userInfoList = await DataBase().getDBUserDataListFromUserIDList( _userIDList );
    List<Map<String, dynamic>> _tmplist = await _appdm.getSearchResultUserInfoList();

    //操作ログ用
    DataBase().addOperationLog( 'keep/release user ${_tmplist[index]['id']}' );

    //ユーザーをリストに保存したりリストから保存解除するときの処理を書く
    for( int i=0; i<_userInfoList.length; i++ ) {
      //ボタンを押した対象のユーザーが、自分の保存リストに含まれていたら保存リストから削除する
      if( _tmplist[index]['id'] == _userIDList[i] ){
        setState(() {
          _userIDList.removeAt(i);
          _aadm.setAccountData('keepUserInfoList', _userIDList);
        });
        return null;
      }
    }
    //ボタンを押した対象のユーザーが、自分の保存リストに含まれていなかったら、保存リストに追加する。
    setState(() {
      _userIDList.insert(0, _tmplist[index]['id'] );
      _aadm.setAccountData('keepUserInfoList', _userIDList);
    });
  }

  Widget build(BuildContext context) {
    return Container(
      color: Defines.colorset['backgroundcolor'],
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 60.0,
            color: Defines.colorset['backgroundcolor'],
            child: Row(
              children: [
                Expanded(
                  child: CreateTopTabItemWidget(
                    title: '聖地',
                    active: _activeTopTab[TopTab.spot.index],
                    onTappedTopTab: () {
                      DataBase().addOperationLog( 'selected top tab SPOT' );
                      _onTappedTopTab(TopTab.spot.index);
                    },
                  ),
                ),
                Expanded(
                  child: CreateTopTabItemWidget(
                    title: '投稿',
                    active: _activeTopTab[TopTab.post.index],
                    onTappedTopTab: () {
                      DataBase().addOperationLog( 'selected top tab POST' );
                      _onTappedTopTab(TopTab.post.index);
                    },
                  ),
                ),
                Expanded(
                  child: CreateTopTabItemWidget(
                    title: 'ユーザー',
                    active: _activeTopTab[TopTab.user.index],
                    onTappedTopTab: () {
                      DataBase().addOperationLog( 'selected top tab USER' );
                      _onTappedTopTab(TopTab.user.index);
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: Stack(
                children: [
                  Offstage(
                      offstage: !_activeTopTab[TopTab.spot.index],
                      child: Stack(
                        children: [
                          (){
                          print( 'mapViewerSearchResult START : ${DateTime.now()}' );
                            return Container(
                              constraints: BoxConstraints.expand(),
                              child: mapViewerSearchResult(
                                mapStreamController: _mapStreamController,
                                pinsSpotStreamController: widget.pinsSpotStreamController,
                                pinsCreateStreamController: _pinsCreateStreamController,
                              ),
                            );
                          }(),
                          (){
                            print( 'pinSpot START : ${DateTime.now()}' );
                          return pinSpot(
                            stream: widget.pinsSpotStreamController.stream,
                            herotag: 'SearchResult',
                            onTapToSubPage: (int index) => widget.onTapToSubPage(index),
                          );
                          }(),
                          (){
                            print( 'newPinCreate START : ${DateTime.now()}' );
                          return newPinCreate(
                            stream: _pinsCreateStreamController.stream,
                            herotag: 'SearchResult',
                            onTapToSubPage: (int index) => widget.onTapToSubPage(index),
                          );
                          }(),
                        ],
                      )
                  ),
                  Offstage(
                    offstage: !_activeTopTab[TopTab.post.index],
                    child: CustomScrollView(
                      slivers: [
                        FutureBuilder(
                          future: DataBase().getDBPostData(),
                          builder: (context, snapshot) {
                            return PostListViewWidget(
                              postDataList: snapshot.data,
                              onTappedTopTab: (int index) => this._onTappedTopTab(index),
                              onTapToSubPage: (int index) => widget.onTapToSubPage(index),
                            );
                          }
                        ),
                      ],
                    ),
                  ),
                  Offstage(
                    offstage: !_activeTopTab[TopTab.user.index],
                    child: FutureBuilder(
                      future: DataBase().getDBUserData(),
                      builder: (context, snapshot) {
                        return !snapshot.hasData ? Container() : UserListViewWidget(
                          userDataList: snapshot.data,
                          keepRelease: (int index) => _keepRelease(index),
                          onTapUserToProfilePage: (int index) => widget.onTapToSubPage(index),
                        );
                      }
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

// Map表示用のWidgetクラス
class mapViewerSearchResult extends StatefulWidget {
  final StreamController<Map<String, dynamic>> mapStreamController;
  final StreamController<Map<String, dynamic>> pinsSpotStreamController;
  final StreamController<Map<String, dynamic>> pinsCreateStreamController;

  mapViewerSearchResult({
    this.mapStreamController,
    this.pinsSpotStreamController,
    this.pinsCreateStreamController,
  });

  @override
  _mapViewerSearchResultState createState() => _mapViewerSearchResultState(
    mapStreamController: this.mapStreamController,
    pinsSpotStreamController: this.pinsSpotStreamController,
    pinsCreateStreamController: this.pinsCreateStreamController,
  );
}

class _mapViewerSearchResultState extends State<mapViewerSearchResult> {
  @override
  final StreamController<Map<String, dynamic>> mapStreamController;
  final StreamController<Map<String, dynamic>> pinsSpotStreamController;
  final StreamController<Map<String, dynamic>> pinsCreateStreamController;

  _mapViewerSearchResultState(
    {
      this.mapStreamController,
      this.pinsSpotStreamController,
      this.pinsCreateStreamController,
    }
  );

  // GPS用データ
  Location _locationService = Location();
  LocationData _nowLocationData;
  StreamSubscription _locationChangedListen;
  LatLng _nowLatLng;
  MapController _mapInfoController = MapController();

  initState() {
    super.initState();
    // 現在地の取得と変化の監視
    Future(() async {
      _getLocation();
    });

    // 現在地の変化に合わせて、現在地マーカーを変更 -> 停止中
    /*
    _locationChangedListen = _locationService.onLocationChanged.listen((LocationData result) async {
      Map<String, dynamic> _sinkMapObj = {
        'selectedSpotName': ViewDataManager().getViewData('selectedSpotName'),
        'selectedLatitude': ViewDataManager().getViewData('selectedLatitude'),
        'selectedLongitude': ViewDataManager().getViewData('selectedLongitude'),
        'newPinFlag': ViewDataManager().getViewData('newPinFlag'),
        'nowLatitude': result.latitude,
        'nowLongitude': result.longitude,
      };

      mapStreamController.sink.add(_sinkMapObj);
      ViewDataManager().setViewData('nowLatitude', result.latitude);
      ViewDataManager().setViewData('nowLongitude', result.longitude);
    });

     */

  }

  @override
  void dispose() {
    // 現在地の監視を終了
    /*
    _locationChangedListen?.cancel();

     */

    super.dispose();
  }

  // 現在地取得用メソッド
   void _getLocation() async {

    // サービスが利用可能か判別 - 上手くいかないので外しています。
    /*
    Map<String, dynamic> _argMap = {
      'locationService': _locationService,
      'context': context,
    };
    Map<String, dynamic> _serviceEnabled = await compute(geoServiceEnabledCheck, _argMap);

     */

    _nowLocationData = await compute(getLocationData, _locationService);

    if(!(ViewDataManager().getViewData('_sinkPinSpotObj')==null)) {
      double _lat = double.parse(ViewDataManager().getViewData('_sinkPinSpotObj')['selectedLatitude']);
      double _lng = double.parse(ViewDataManager().getViewData('_sinkPinSpotObj')['selectedLongitude']);
      _nowLatLng = new LatLng(_lat, _lng);

      Map<String, dynamic> _sinkPinSpotObj = ViewDataManager().getViewData('_sinkPinSpotObj');

      Map<String, dynamic> _pinsInfoSinkObj = {
        'selectedSpotInfo':  _sinkPinSpotObj['selectedSpotInfo'],
        'selectedSpotName': _sinkPinSpotObj['selectedSpotName'],
        'selectedLatitude': _sinkPinSpotObj['selectedLatitude'],
        'selectedLongitude': _sinkPinSpotObj['selectedLongitude'],
        '_isSpotSelected': true,
        'postData': await postDataFromSpotNameNarrowList(_sinkPinSpotObj['selectedSpotName']),
      };
      widget.pinsSpotStreamController.sink.add(_pinsInfoSinkObj);

      ViewDataManager().setViewData('_sinkPinSpotObj', null);
    } else {
      _nowLatLng = new LatLng(_nowLocationData.latitude, _nowLocationData.longitude);
    }

    _mapInfoController.move(_nowLatLng, 15.0);

  }

  ViewDataManager _vdm = new ViewDataManager();

  Map<String, dynamic> _sinkMapObj = {
    'selectedSpotName': ViewDataManager().getViewData('selectedSpotName'),
    'selectedLatitude': ViewDataManager().getViewData('selectedLatitude'),
    'selectedLongitude': ViewDataManager().getViewData('selectedLongitude'),
    '_isSpotSelected': true,
    'newPinFlag': false,
    'nowLatitude': ViewDataManager().getViewData('nowLatitude'),
    'nowLongitude': ViewDataManager().getViewData('nowLongitude'),
  };


  Widget build(BuildContext context) {

    MapInfo _mapInfo = new MapInfo(
        pageName: 'SearchResult',
        sinkPinSpot: this.pinsSpotStreamController.sink,
        sinkNewPinCreated: pinsCreateStreamController.sink,
        sinkMap: mapStreamController.sink
    );

    if(!(ViewDataManager().getViewData('_sinkPinSpotObj')==null)) {
      _sinkMapObj['selectedSpotName'] = ViewDataManager().getViewData('_sinkPinSpotObj')['selectedSpotName'];
      _sinkMapObj['selectedLatitude'] = ViewDataManager().getViewData('_sinkPinSpotObj')['selectedLatitude'];
      _sinkMapObj['selectedLongitude'] = ViewDataManager().getViewData('_sinkPinSpotObj')['selectedLongitude'];
      _sinkMapObj['newPinFlag'] = false;
      _sinkMapObj['nowLatitude'] = ViewDataManager().getViewData('_sinkPinSpotObj')['selectedLatitude'];
      _sinkMapObj['nowLongitude'] = ViewDataManager().getViewData('_sinkPinSpotObj')['selectedLongitude'];
    }



    return StreamBuilder(
        stream: this.mapStreamController.stream,
        initialData: _sinkMapObj,
        builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          return !snapshot.hasData ? Container() : Stack(
            children: [
              FutureBuilder(
                  future:_mapInfo.pinsMakerSearchResult(
                    snapshot.data['selectedSpotName'],
                    snapshot.data['newPinFlag'],
                    snapshot.data['newPinInfo'],
                  ),
                  builder: (context, AsyncSnapshot<List<Marker>> snapshotMapInfo) {
                    return !snapshotMapInfo.hasData ? Container() : FlutterMap(
                      mapController: _mapInfoController,
                      options: new MapOptions(
                        rotationThreshold: 100,
                        plugins: [
                          MarkerClusterPlugin(),
                        ],
                        center: new LatLng(35.681455, 139.767400),
                        zoom: 14.0,
                        onTap: (point) => mapTap(
                            _vdm, this.pinsSpotStreamController,
                            this.pinsCreateStreamController,
                            this.mapStreamController,
                            'SearchResult'
                        ),
                        onLongPress: (point) => mapLongTap(
                            point,
                            _vdm,
                            this.pinsSpotStreamController,
                            this.pinsCreateStreamController,
                            this.mapStreamController,
                            'SearchResult'
                        ),
                      ),
                      layers: [
                        new TileLayerOptions(
                            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                            subdomains: ['a', 'b', 'c']
                        ),
                        // 現在地マーカー -> 動作不良につき停止中
                        /*
                          new CircleLayerOptions(
                              circles: <CircleMarker>[
                                _mapInfo.nowSpotMarker(snapshot.data['nowLatitude'], snapshot.data['nowLongitude']),
                              ]
                          ),
                           */

                        MarkerClusterLayerOptions(
                          maxClusterRadius: 200,
                          disableClusteringAtZoom: 15,
                          size: Size(48, 48),
                          anchor: AnchorPos.align(AnchorAlign.center),
                          fitBoundsOptions: FitBoundsOptions(
                            padding: EdgeInsets.all(50),
                          ),
                          markers: snapshotMapInfo.data,
                          builder: (context, markers) {
                            return FloatingActionButton(
                              backgroundColor: Defines.colorset['highlightcolor'],
                              child: Text(
                                //'2002',
                                markers.length.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: markers.length > 1000 ? 12 : 16,
                                ),
                              ),
                              onPressed: null,
                            );
                          },
                        ),


                        //全てのピンをベタ置きしてたときのコード
                        /*
                        new MarkerLayerOptions(
                          markers: snapshotMapInfo.data,
                        ),

                         */
                      ],
                    );
                  }
              ),
              Container(
                alignment: Alignment.bottomLeft,
                margin: EdgeInsets.all(2),
                child: Container(
                  width: 240,
                  height: 20,
                  color: Defines.colorset['backgroundcolor'].withOpacity(0.4),
                  child: Row(
                    children: [
                      Text(
                        ' © ',
                        style: TextStyle(
                          color: Defines.colorset['drawcolor'],
                        ),
                      ),
                      InkWell(
                        child: Text(
                          'OpenStreetMap',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        onTap: () => launch('https://www.openstreetmap.org/'),
                      ),
                      Text(
                        ' contributors',
                        style: TextStyle(
                          color: Defines.colorset['drawcolor'],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: 40,
                    margin: EdgeInsets.only(
                      top: 16,
                      right: 16,
                    ),
                    child: RaisedButton.icon(
                      icon: Icon(
                        Icons.near_me,
                        color: Defines.colorset['darkdrawcolor'],
                      ),
                      label: Text('現在地'),
                      shape: StadiumBorder(),
                      onPressed: () {
                        DataBase().addOperationLog( 'push get location button' );
                        _getLocation();
                      },
                    ),
                  )
                ],
              ),
            ],
          );
        }
    );
  }
}