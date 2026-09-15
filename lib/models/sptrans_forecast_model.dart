class SpTransForecastModel {
  final int lineId;
  final String lineCode;
  final String origin;
  final String destination;
  final int direction;
  final int vehicleCount;
  final String arrivalTime;
  final bool accessible;

  const SpTransForecastModel({
    required this.lineId,
    required this.lineCode,
    required this.origin,
    required this.destination,
    required this.direction,
    required this.vehicleCount,
    required this.arrivalTime,
    required this.accessible,
  });
}