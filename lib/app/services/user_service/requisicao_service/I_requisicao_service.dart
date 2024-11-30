import 'package:uber/app/model/Requisicao.dart';

abstract class IRequisicaoService {
     Future<Requisicao?> verfyActivatedRequisition(String idUser);
}