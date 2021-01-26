
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:test_roketan/part/CreateSwitchBoxWidget.dart';
import 'package:test_roketan/part/DataBase.dart';
import 'package:test_roketan/part/Defines.dart' as Defines;
import 'package:test_roketan/part/DataManager.dart';
import 'package:test_roketan/part/MapPinInfo.dart';
import 'package:location/location.dart';
import 'package:test_roketan/part/getLocation.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';


class KeepLocation extends StatefulWidget {
  final Function onTapToSubPage;
  KeepLocation({
    this.onTapToSubPage,
  });

  @override
  _KeepLocationState createState() => _KeepLocationState();
}

class _KeepLocationState extends State<KeepLocation> {

  //データマネージャのインスタンス生成
  ViewDataManager _vdm = new ViewDataManager();
  ActiveAccountDataManager _aadm = new ActiveAccountDataManager();


  final _mapStreamController = StreamController<Map<String, Map<String, dynamic>>>();
  final pinsSpotStreamController = StreamController<Map<String, dynamic>>();
  final _pinsCreateStreamController = StreamController<Map<String, dynamic>>();

  @override
  void dispose() {
    _mapStreamController.close();
    pinsSpotStreamController.close();
    _pinsCreateStreamController.close();
    super.dispose();
  }

  initState() {
    super.initState();

  }

  final String _keepspot = '保存済み';
  final String _havebeen = '行った';
  bool _switchKeepSpot = true;
  bool _switchHaveBeen = true;

  void changeSwitchKeepSpot(bool e) {
    DataBase().addOperationLog( 'switch keep spot' );
    setState(() {
      _switchKeepSpot = e;
    });

    _vdm.setViewData('_switchKeepSpot', e);
    _vdm.setViewData('_switchHaveBeen', _switchHaveBeen);
    _vdm.setViewData('_isSpotSelected', false);
    _vdm.setViewData('_isNewPinCreated', false);

    Map<String, dynamic> _sinkObj = {
      '_isSpotSelected' : false,
    };

    Map<String, dynamic> _sinkPinsCreateObj = {
      '_isNewPinCreated': false,
    };

    pinsSpotStreamController.sink.add(_sinkObj);
    _pinsCreateStreamController.sink.add(_sinkPinsCreateObj);

    Map<String, Map<String, dynamic>> _sinkPinSwitchObj = {
      'mapObj': {
        '_switchKeepSpot': e,
        '_switchHaveBeen': _switchHaveBeen,
      }
    };
    _mapStreamController.sink.add(_sinkPinSwitchObj);
  }

  void _changeSwitchHaveBeen(bool e) {
    DataBase().addOperationLog( 'switch have been' );
    setState(() {
      _switchHaveBeen = e;
    });

    _vdm.setViewData('_switchKeepSpot', _switchKeepSpot);
    _vdm.setViewData('_switchHaveBeen', e);
    _vdm.setViewData('_isSpotSelected', false);
    _vdm.setViewData('_isNewPinCreated', false);

    Map<String, dynamic> _sinkObj = {
      '_isSpotSelected' : false,
    };

    Map<String, dynamic> _sinkPinsCreateObj = {
      '_isNewPinCreated': false,
    };

    pinsSpotStreamController.sink.add(_sinkObj);
    _pinsCreateStreamController.sink.add(_sinkPinsCreateObj);

    Map<String, Map<String, dynamic>> _sinkPinSwitchObj = {
      'mapObj': {
        '_switchKeepSpot': _switchKeepSpot,
        '_switchHaveBeen': e,
      }
    };
    _mapStreamController.sink.add(_sinkPinSwitchObj);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            height: 60.0,
            color: Defines.colorset['backgroundcolor'],
            child: Row(
              children: [
                Expanded(
                  child: CreateSwitchBoxWidget(
                    color: Defines.colorset['keepspotcolor'],
                    active: _switchKeepSpot,
                    changeSwitch: changeSwitchKeepSpot,
                    icon: Icons.bookmark_outline_sharp,
                    title: _keepspot,
                    number: _aadm.getAccountData('keepSpotInfoList').length,
                  ),
                ),
                Expanded(
                  child: CreateSwitchBoxWidget(
                    color: Defines.colorset['havebeencolor'],
                    active: _switchHaveBeen,
                    changeSwitch: _changeSwitchHaveBeen,
                    icon: Icons.location_on_outlined,
                    title: _havebeen,
                    number: _aadm.getAccountData('haveBeenSpotInfoList').length,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  constraints: BoxConstraints.expand(),
                  child: mapViewerKeepLocation(
                    mapStreamController: _mapStreamController,
                    pinsSpotStreamController: pinsSpotStreamController,
                    pinsCreateStreamController: _pinsCreateStreamController,
                  ),
                ),
                pinSpot(
                    stream: pinsSpotStreamController.stream,
                    herotag: 'KeepLocation',
                    onTapToSubPage: (int index) => widget.onTapToSubPage(index),
                ),
                newPinCreate(
                  stream: _pinsCreateStreamController.stream,
                  herotag: 'KeepLocation',
                  onTapToSubPage: (int index) => widget.onTapToSubPage(index),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Map表示用のWidgetクラス
class mapViewerKeepLocation extends StatefulWidget {
  final StreamController<Map<String, dynamic>> mapStreamController;
  final StreamController<Map<String, dynamic>> pinsSpotStreamController;
  final StreamController<Map<String, dynamic>> pinsCreateStreamController;

  mapViewerKeepLocation({
    this.mapStreamController,
    this.pinsSpotStreamController,
    this.pinsCreateStreamController,
  });

  @override
  _mapViewerKeepLocationState createState() => _mapViewerKeepLocationState(
      mapStreamController: this.mapStreamController,
      pinsSpotStreamController: this.pinsSpotStreamController,
      pinsCreateStreamController: this.pinsCreateStreamController );
}

class _mapViewerKeepLocationState extends State<mapViewerKeepLocation> {
  @override
  final StreamController<Map<String, Map<String, dynamic>>> mapStreamController;
  final StreamController<Map<String, dynamic>> pinsSpotStreamController;
  final StreamController<Map<String, dynamic>> pinsCreateStreamController;

  _mapViewerKeepLocationState(
      {
        this.mapStreamController,
        this.pinsSpotStreamController,
        this.pinsCreateStreamController,
      });

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
      Map<String, Map<String, dynamic>> _sinkMapObj = {
        'mapObj': {
          '_switchKeepSpot': ViewDataManager().getViewData('_switchKeepSpot'),
          '_switchHaveBeen': ViewDataManager().getViewData('_switchHaveBeen'),
          'selectedSpotName': ViewDataManager().getViewData('selectedSpotName'),
          'nowLatitude': result.latitude,
          'nowLongitude': result.longitude,
        }
      };

      mapStreamController.sink.add(_sinkMapObj);
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
    _nowLatLng = new LatLng(_nowLocationData.latitude, _nowLocationData.longitude);
    _mapInfoController.move(_nowLatLng, 15.0);
  }


  Map<String, Map<String, dynamic>> _sinkPinSwitchObj = {
    'mapObj': {
      '_switchKeepSpot': true,
      '_switchHaveBeen': true,
      'selectedSpotName': ViewDataManager().getViewData('selectedSpotName'),
      'nowLatitude': ViewDataManager().getViewData('nowLatitude'),
      'nowLongitude': ViewDataManager().getViewData('nowLongitude'),
    }
  };

  ViewDataManager _vdm = new ViewDataManager();

  Widget build(BuildContext context) {

    MapInfo _mapInfo = new MapInfo(
        pageName: 'KeepLocation',
        sinkPinSpot: this.pinsSpotStreamController.sink,
        sinkNewPinCreated: pinsCreateStreamController.sink,
        sinkMap: this.mapStreamController.sink,
    );


    return StreamBuilder(
        stream: this.mapStreamController.stream,
        initialData: _sinkPinSwitchObj,
        builder: (BuildContext context, AsyncSnapshot<Map<String, Map<String, dynamic>>> snapshot) {
          switch(snapshot.hasData) {
            case true:
              return Stack(
                children: [
                  FutureBuilder(
                    future: _mapInfo.pinsMakerKeepLocation( snapshot.data['mapObj'] ),
                    builder: (context, AsyncSnapshot<List<Marker>> snapshotMapInfo) {
                      return !snapshotMapInfo.hasData ? Container() : FlutterMap(
                        options: new MapOptions(
                          center: new LatLng(35.681455, 139.767400),
                          zoom: 5.0,
                          onTap: (point) => mapTap(
                              _vdm, this.pinsSpotStreamController, this.pinsCreateStreamController,
                              this.mapStreamController, 'KeepLocation',
                          ),
                          onLongPress: (point) => mapLongTap(
                              point, _vdm, this.pinsSpotStreamController,
                              this.pinsCreateStreamController, this.mapStreamController, 'KeepLocation',
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
                                _mapInfo.nowSpotMarker(snapshot.data['mapObj']['nowLatitude'], snapshot.data['mapObj']['nowLongitude']),
                              ]
                          ),
                           */
                          new MarkerLayerOptions(
                              markers: snapshotMapInfo.data,
                          ),
                        ],
                        mapController: _mapInfoController,
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
                      FloatingActionButton(
                        heroTag: 'near_me_KeepLocation',
                        onPressed: () {
                          DataBase().addOperationLog( 'push get location button' );
                          _getLocation();
                        },
                        child: Icon(Icons.near_me, color: Defines.colorset['darkdrawcolor'],),
                        backgroundColor: Defines.colorset['backgroundcolor'],
                      )
                    ],
                  ),
                ],
              );
            default:
              return Container();
          }
        }
    );
  }
}
