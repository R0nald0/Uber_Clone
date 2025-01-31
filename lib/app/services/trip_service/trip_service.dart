import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uber/app/model/Requisicao.dart';
import 'package:uber/app/model/addres.dart';
import 'package:uber/app/model/polyline_data.dart';
import 'package:uber/app/model/tipo_viagem.dart';
import 'package:uber/app/model/trip.dart';
import 'package:uber/app/repository/addres_reposiory/address_repository_impl.dart';
import 'package:uber/app/repository/location_repository/location_repository.dart';
import 'package:uber/app/repository/requisition_repository/i_requisition_repository.dart';
import 'package:uber/core/exceptions/addres_exception.dart';
import 'package:uber/core/exceptions/requisicao_exception.dart';

class TripService {
  final LocationRepositoryImpl _locationRepositoryImpl;
  final IRequisitionRepository _requisitionRepository;
  final AddressRepositoryImpl _addressRepositoryImpl;

  TripService(
      {required LocationRepositoryImpl locationImpl,
      required IRequisitionRepository requisitionRepository,
      required AddressRepositoryImpl addresReposiory})
      : _locationRepositoryImpl = locationImpl,
        _requisitionRepository = requisitionRepository,
        _addressRepositoryImpl = addresReposiory;

  Future<PolylineData> getRoute(Address myLocation, Address myDestination,
          Color lineColor, int widthLine) =>
      _locationRepositoryImpl.getRouteTrace(
          myLocation, myDestination, lineColor, widthLine);

  List<Trip> configureTripList(PolylineData data) {
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

  Future<Requisicao?> createRequisitionToRide(Requisicao requiscao) async {
    try {
      final idUser = requiscao.passageiro.idUsuario;
      if (idUser == null) {
        throw RequisicaoException(
            message: "erro ao criar requisição,dados do usuário incorretos");
      }

     final success = await _requisitionRepository.createRequisition(requiscao);
     // await _addressRepositoryImpl.saveAddres(requiscao.destino);
      if (success) {
          final requisition =
          await _requisitionRepository.verfyActivatedRequisition(idUser);
          return requisition ;
      }
      
      return null;

    } on RequisicaoException   {
      rethrow;
    } on AddresException  {
      rethrow;
    }
  }

  Future<Requisicao?> verfyActivatedRequisition(String idUser) async {
    final requisition =
        await _requisitionRepository.verfyActivatedRequisition(idUser);
    if (requisition != null) {
      return requisition;
    }
    return null;
  }

  Future<bool> cancelRequisition(Requisicao requisition) =>
      _requisitionRepository.cancelRequisition(requisition);

  Stream<String> listenerRequisicao(String idRequisicao) =>
      _requisitionRepository.listenerRequisicao(idRequisicao);
  Future<void> updataDataRequisition(String requisitionId,
          String fiedRequisitonName, Object dataToUpdate) =>
      _requisitionRepository.updataDataRequisition(
          requisitionId, fiedRequisitonName, dataToUpdate);
}
