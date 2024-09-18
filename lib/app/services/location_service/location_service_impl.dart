import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uber/app/model/addres.dart';
import 'package:uber/app/model/polyline_data.dart';
import 'package:uber/app/repository/location_repository/location_repository.dart';

class LocationServiceImpl {
  final LocationRepositoryImpl _locationRepository;

  LocationServiceImpl({
    required LocationRepositoryImpl locationRepositoryImpl,
  }) : _locationRepository = locationRepositoryImpl;

  Future<Addres> setNameMyLocal(double latitude, double longitude) =>
      _locationRepository.setNameMyLocal(latitude, longitude);

  Future<List<Addres>> findAddresByName(String nameAddres) =>
      _locationRepository.findAddresByName(nameAddres);
  void getUserLocation() {}

  Future<PolylineData> getRoute(
          Addres myLocation, Addres myDestination,Color lineColor,int widthLine) =>
      _locationRepository.getRouteTrace(myLocation, myDestination,lineColor,widthLine);
}
