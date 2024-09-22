import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber/app/model/addres.dart';
import 'package:uber/app/repository/location_repository/location_repository.dart';

class LocationServiceImpl {
  final LocationRepositoryImpl _locationRepository;

  LocationServiceImpl({
    required LocationRepositoryImpl locationRepositoryImpl
  }) : _locationRepository = locationRepositoryImpl;

  Future<Addres> setNameMyLocal(double latitude, double longitude) =>
      _locationRepository.setNameMyLocal(latitude, longitude);

  Future<List<Addres>> findAddresByName(String nameAddres) =>
      _locationRepository.findAddresByName(nameAddres);
  void getUserLocation() {}
  
  
 Marker createLocationMarker(Addres addres, BitmapDescriptor? icon, String idMarcador,
      String tiuloLocal, double hue) {
     return Marker(
        markerId: MarkerId(idMarcador),
        infoWindow: InfoWindow(title: tiuloLocal),
        position: LatLng(addres.latitude, addres.longitude),
        icon: icon ?? BitmapDescriptor.defaultMarkerWithHue(hue));
  }

   Future<AssetMapBitmap> markerPositionIconCostomizer(
      String caminho, double devicePixelRatio) async {
    const configuration = ImageConfiguration(size: Size(23, 23));
    final pathImage = "images/$caminho.png";
    final assetBitMap = BitmapDescriptor.asset(configuration, pathImage);

    return assetBitMap;
  }
}
