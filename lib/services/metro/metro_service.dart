import 'package:cheguei/models/metro_model.dart';

class MetroService {
  static Future<List<MetroModel>> getMetroStatus() async {
    return [
      MetroModel(
        line: 'Linha 4-Amarela',
        status: 'Operação Normal',
        operational: true,
      ),
      MetroModel(
        line: 'Linha 2-Verde',
        status: 'Operação Normal',
        operational: true,
      ),
    ];
  }
}