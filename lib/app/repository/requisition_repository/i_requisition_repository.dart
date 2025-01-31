import 'package:uber/app/model/Requisicao.dart';

abstract class IRequisitionRepository {
   Future<Requisicao?> verfyActivatedRequisition(String idUser);
   Future<bool> createActiveRequisition(Requisicao requisition);
   Future<bool> createRequisition(Requisicao requisicao);
   Future<bool> cancelRequisition(Requisicao requisition);
   Stream<String> listenerRequisicao(String idRequisicao);
  Future<void> updataDataRequisition(String requisitionId,String fiedRequisitonName,Object dataToUpdate );
   }