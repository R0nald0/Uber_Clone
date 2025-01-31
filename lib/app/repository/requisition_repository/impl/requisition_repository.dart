import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uber/app/model/Requisicao.dart';
import 'package:uber/app/repository/requisition_repository/i_requisition_repository.dart';
import 'package:uber/app/util/Status.dart';
import 'package:uber/core/constants/uber_clone_contstants.dart';
import 'package:uber/core/exceptions/requisicao_exception.dart';
import 'package:uber/core/local_storage/local_storage.dart';
import 'package:uber/core/logger/app_uber_log.dart';


class RequisitionRepository implements IRequisitionRepository {
  final _fireStoreDatabase = FirebaseFirestore.instance;

  final LocalStorage _localStorage;
  final IAppUberLog _logger;
 

  RequisitionRepository(
      {required IAppUberLog logger,
      required LocalStorage localStorage})
      : _logger = logger,
        _localStorage = localStorage;

  @override
  Future<Requisicao?> verfyActivatedRequisition(String idUser) async {
    final requisicao = await _localStorage
        .read<String>(UberCloneConstants.KEY_PREFERENCE_REQUISITION_ACTIVE);
    if (requisicao != null) {
      final actualRequisition = Requisicao.fromJson(requisicao);
     
      return actualRequisition;
    }
    const message = 'Erro ao buscar requisçao ativa';
    _logger.erro(message);
    return null;
  }

  @override
  Future<bool> createActiveRequisition(Requisicao requisition) async {
    try {
      await _fireStoreDatabase
          .collection(UberCloneConstants.REQUISITION_ACTIVE_DATABASE_NAME)
          .doc(requisition.id)
          .set(requisition.dadosPassageiroToMap());

      final saved = await _localStorage.write<String>(
          UberCloneConstants.KEY_PREFERENCE_REQUISITION_ACTIVE,
          requisition.toJson());

      print('SAlVO $saved');
      return saved ?? false;
    } on FirebaseException catch (e, s) {
      const message = 'Erro ao criar viagem';
      _logger.erro(message, e, s);
      throw RequisicaoException(message: message);
    }
  }

  @override
  Future<bool> createRequisition(Requisicao requisicao) async {
    try {
      final docRef = _fireStoreDatabase
          .collection(UberCloneConstants.REQUISITION_DATABASE_NAME)
          .doc();

      final requisitionWithId = requisicao.copyWith(id: () => docRef.id);

      await docRef.set(requisitionWithId.dadosPassageiroToMap());
     final success = await createActiveRequisition(requisitionWithId);

       return success;
    } on FirebaseException catch (e, s) {
      const message = 'Erro ao criar requisição';
      _logger.erro(message, e, s);
      throw RequisicaoException(message: message);
    }

    //salvar dados da requisicao activa
    // _salvarRequisicaoAtiva(_idRequisicao, idUser);
    // _listenerRequisicao(_idRequisicao);
  }

  @override
  Future<bool> cancelRequisition(Requisicao requisition) async {

    final updateDataRequisition = await _fireStoreDatabase
        .collection(UberCloneConstants.REQUISITION_DATABASE_NAME)
        .doc(requisition.id)
        .update({"status": Status.CANCELADA}).then((_) async {
      return true;
    }, onError: (e) {
      _logger.erro("Erro ao atualizar requsição");
      return false;
    });

    if (!updateDataRequisition) {
      return false;
    }

    final docRefActive = _fireStoreDatabase
        .collection(UberCloneConstants.REQUISITION_ACTIVE_DATABASE_NAME)
        .doc(requisition.id);

    await docRefActive.update({"status": Status.CANCELADA});
    
    return await docRefActive
    .delete()
    .then((_) async {
      final isRemoved = await _localStorage
          .remove(UberCloneConstants.KEY_PREFERENCE_REQUISITION_ACTIVE);
      if (isRemoved == null || isRemoved == false) {
        return false;
      }
  
      return true;
    }, onError: (e) {
      _logger.erro("Erro ao cancelar requsição");
      return false;
    });
  }

@override
  Stream<String> listenerRequisicao(String idRequisicao) async* {
   yield*  _fireStoreDatabase
        .collection(UberCloneConstants.REQUISITION_DATABASE_NAME)
        .doc(idRequisicao)
        .snapshots()
        .map((data) => data["status"] as String);
  }

  @override
  Future<void> updataDataRequisition(String requisitionId,String fiedRequisitonName,Object dataToUpdate )async{
    await  _fireStoreDatabase.collection(UberCloneConstants.REQUISITION_DATABASE_NAME)
        .doc(requisitionId)
        .update({
          fiedRequisitonName : dataToUpdate
    });
}
}


