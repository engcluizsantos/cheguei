class AssistantResponse {
  final String message;
  final bool success;

  final String transport;
  final double distanceKm;
  final double score;

  final double temperature;
  final bool isRaining;

  const AssistantResponse({
    required this.message,
    required this.success,
    required this.transport,
    required this.distanceKm,
    required this.score,
    required this.temperature,
    required this.isRaining,
  });
}