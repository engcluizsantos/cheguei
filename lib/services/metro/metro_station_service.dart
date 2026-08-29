import 'package:cheguei/models/metro_station_model.dart';

class MetroStationService {
  static const List<MetroStationModel> stations = [
    MetroStationModel(
      name: 'Palmeiras-Barra Funda',
      line: 'Linha 3-Vermelha',
      address: 'Av. Mario de Andrade, s/nº',
    ),

    MetroStationModel(
      name: 'Sé',
      line: 'Linha 3-Vermelha',
      address: 'Praça da Sé, s/nº',
    ),

    MetroStationModel(
      name: 'Consolação',
      line: 'Linha 2-Verde',
      address: 'Av. Paulista, 2163',
    ),

    MetroStationModel(
      name: 'Trianon-MASP',
      line: 'Linha 2-Verde',
      address: 'Av. Paulista, 1400',
    ),

    MetroStationModel(
      name: 'Brigadeiro',
      line: 'Linha 2-Verde',
      address: 'Av. Paulista, 447',
    ),

    MetroStationModel(
      name: 'Ana Rosa',
      line: 'Linha 1-Azul',
      address: 'R. Domingos de Morais, 505',
    ),

    MetroStationModel(
      name: 'Vila Mariana',
      line: 'Linha 1-Azul',
      address: 'Av. Prof. Noé Azevedo, 255',
    ),

    MetroStationModel(
      name: 'Santana',
      line: 'Linha 1-Azul',
      address: 'Av. Cruzeiro do Sul, 3173',
    ),

    MetroStationModel(
      name: 'Tucuruvi',
      line: 'Linha 1-Azul',
      address: 'Av. Dr. Antônio Maria de Laet, 100',
    ),

    MetroStationModel(
      name: 'Jabaquara',
      line: 'Linha 1-Azul',
      address: 'R. dos Jequitibás, 80',
    ),
  ];

  static List<MetroStationModel> findStationsByDestination(String destination) {
    final term = destination.toLowerCase();

    return stations.where((station) {
      return station.name.toLowerCase().contains(term) ||
          station.address.toLowerCase().contains(term);
    }).toList();
  }
}
