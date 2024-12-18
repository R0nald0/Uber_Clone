import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uber/app/model/Requisicao.dart';
import 'package:uber/app/repository/requisition_repository/i_requisition_repository.dart';
import 'package:uber/core/exceptions/requisicao_exception.dart';
import 'package:uber/core/logger/app_uber_log.dart';

class RequisitionRepository implements IRequisitionRepository {
   final _fireStoreDatabase =  FirebaseFirestore.instance;
   final IAppUberLog _logger ;
   RequisitionRepository({required IAppUberLog logger}):_logger= logger;
 
  Future<Requisicao?> verfyActivatedRequisition(String idUser) async{
      try {
         DocumentSnapshot snapshot =
        await _fireStoreDatabase.collection("requisicao-ativa").doc(idUser).get();
        return snapshot.get('id_requisisicao');
      } catch (e,s) {
          const message = 'Erro ao buscar requisçao ativa';
         _logger.erro(message,e,s);
         throw RequisicaoException(message: message);
      }
  }

}