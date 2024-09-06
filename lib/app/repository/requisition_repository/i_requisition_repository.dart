import 'package:uber/app/model/Requisicao.dart';

abstract class IRequisitionRepository {
   Future<Requisicao?> verfyActivatedRequisition(String idUser);
   }