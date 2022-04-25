import 'package:chatting/common/shared.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';

LocationService ls = LocationService();
Widget locationMsg(latitude, longitude) {
  return Container(
      width: Get.width * 0.45,
      height: Get.height * 0.25,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("imgs/location.jpg"), fit: BoxFit.fill)),
      child: GestureDetector(
        onTap: () async =>
            await ls.goToMaps(double.parse(latitude), double.parse(longitude)),
        child: Center(
          child: txt("Go", Colors.black, 23, true),
        ),
      ));
}

class LocationService {
  getLocation() async {
    Location location = new Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _locationData = await location.getLocation();
    print("latitude ${_locationData.latitude}");
    print("longitude ${_locationData.longitude}");
    return _locationData;
  }

  goToMaps(double latitude, double longitude) async {
    print("going to map");
    String mapLocationUrl =
        "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";
    final String encodedURl = Uri.encodeFull(mapLocationUrl);
    if (await canLaunch(encodedURl)) {
      await launch(encodedURl);
    } else {
      print('Could not launch $encodedURl');
      snackMsg("Something went wrong");
    }
  }
}
