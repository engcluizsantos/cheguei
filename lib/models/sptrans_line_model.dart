class SpTransLineModel {
  final int id;
  final String code;
  final String origin;
  final String destination;
  final int direction;
  final bool circular;

  const SpTransLineModel({
    required this.id,
    required this.code,
    required this.origin,
    required this.destination,
    required this.direction,
    required this.circular,
  });

  factory SpTransLineModel.fromJson(Map<String, dynamic> json) {
    return SpTransLineModel(
      id: json['cl'] ?? 0,
      code: json['lt'] ?? '',
      origin: json['tp'] ?? '',
      destination: json['ts'] ?? '',
      direction: json['sl'] ?? 0,
      circular: json['lc'] ?? false,
    );
  }
}

/*
O QUE REPRESENTA CADA CAMPO

| Campo da API | Campo no Model | Descrição                      |
| ------------ | -------------- | ------------------------------ |
| `cl`         | id             | Identificador da linha         |
| `lt`         | code           | Código da linha (ex.: 8000-10) |
| `tp`         | origin         | Terminal de origem             |
| `ts`         | destination    | Terminal de destino            |
| `sl`         | direction      | Sentido da linha               |
| `lc`         | circular       | Indica se a linha é circular   |

*/