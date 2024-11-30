import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uber/app/model/addres.dart';
import 'package:uber/app/model/polyline_data.dart';
import 'package:uber/app/model/tipo_viagem.dart';
import 'package:uber/app/model/trip.dart';
import 'package:uber/app/repository/location_repository/location_repository.dart';

class TripService {
  final LocationRepositoryImpl _locationRepositoryImpl;

   TripService({required LocationRepositoryImpl locationImpl}) :_locationRepositoryImpl = locationImpl;

    Future<PolylineData> getRoute(
          Addres myLocation, Addres myDestination,Color lineColor,int widthLine) =>
      _locationRepositoryImpl.getRouteTrace(myLocation, myDestination,lineColor,widthLine); 

  List<Trip> configireTripList(PolylineData data) {

    final distanceBetweenPoint = data.distanceInt.toDouble();
    final priceUberX =
        _calcularValorVieagem(distanceBetweenPoint, TipoViagem.uberX);
    final priceMoto =
        _calcularValorVieagem(distanceBetweenPoint, TipoViagem.uberMoto);

    return [
      Trip(
          type: 'UberX',
          price: priceUberX,
          timeTripe: data.durationBetweenPoints,
          distance: data.distanceBetween,
          quatitePersons: 4),
      Trip(
          type: 'Uber Moto ',
          price: priceMoto,
          timeTripe: data.durationBetweenPoints,
          distance: data.distanceBetween,
          quatitePersons: null)
    ];
  }

  String _calcularValorVieagem(
      double distanceBetweenPoint, TipoViagem tipoViagem) {
    final taxaCorrida = tipoViagem == TipoViagem.uberX ? 4 : 2;
    double distanciaKm = distanceBetweenPoint / 1000;
    double valorDacorrida = distanciaKm * taxaCorrida;

    String valorCobrado = _formatarValor(valorDacorrida);

    return valorCobrado;
  }

  String _formatarValor(double unFormatedValue) {
    var valor = NumberFormat('##,##0.00', 'pt-BR');
    String total = valor.format(unFormatedValue);
    return total;
  }


}
