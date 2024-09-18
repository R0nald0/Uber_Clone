
import 'package:intl/intl.dart';

class TravelService {
  
    Future<String> _calcularValorVieagem(double distanciaKm) async {
    
    double valorDacorrida = distanciaKm * 5;

    String valorCobrado = formatarValor(valorDacorrida);

    return valorCobrado;
  }

   String formatarValor(double unFormatedValue) {
    var valor = NumberFormat('##,##0.00', 'pt-BR');
    String total = valor.format(unFormatedValue);
    return total;
  }
}