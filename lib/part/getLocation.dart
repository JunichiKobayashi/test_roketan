
import 'dart:html';

import 'package:flutter/widgets.dart';
import 'package:location/location.dart';
import 'package:toast/toast.dart';

Future<Map<String, dynamic>> geoServiceEnabledCheck(Map<String, dynamic> argMap) async {
  Map<String, dynamic> result;

  Location locationService = argMap['locationService'];
  BuildContext context = argMap['context'];

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;

  _serviceEnabled = await locationService.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await locationService.requestService();
    if (!_serviceEnabled) {
      Toast.show("位置情報の取得に失敗しました。", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
    }
  }

  _permissionGranted = await locationService.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await locationService.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      Toast.show("位置情報の取得に失敗しました。", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
    }
  }

  result = {
    '_serviceEnabled': _serviceEnabled,
    '_permissionGranted': _permissionGranted,
  };
  return result;
}

Future<LocationData> getLocationData(Location locationService) async {
  LocationData _locationData = await locationService.getLocation();
  return _locationData;
}