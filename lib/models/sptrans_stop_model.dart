class SpTransStopModel {
  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  const SpTransStopModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory SpTransStopModel.fromJson(Map<String, dynamic> json) {
    return SpTransStopModel(
      id: json['cp'] ?? 0,
      name: json['np'] ?? '',
      address: json['ed'] ?? '',
      latitude: (json['py'] ?? 0).toDouble(),
      longitude: (json['px'] ?? 0).toDouble(),
    );
  }
}