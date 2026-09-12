class TravelRoutineModel {
  final String name;
  final String destination;
  final int departureHour;
  final int departureMinute;
  final int minutesBefore;
  final List<int> weekdays;
  final bool enabled;

  const TravelRoutineModel({
    required this.name,
    required this.destination,
    required this.departureHour,
    required this.departureMinute,
    required this.minutesBefore,
    required this.weekdays,
    required this.enabled,
  });

  TravelRoutineModel copyWith({
    String? name,
    String? destination,
    int? departureHour,
    int? departureMinute,
    int? minutesBefore,
    List<int>? weekdays,
    bool? enabled,
  }) {
    return TravelRoutineModel(
      name: name ?? this.name,
      destination: destination ?? this.destination,
      departureHour: departureHour ?? this.departureHour,
      departureMinute: departureMinute ?? this.departureMinute,
      minutesBefore: minutesBefore ?? this.minutesBefore,
      weekdays: weekdays ?? this.weekdays,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'destination': destination,
      'departureHour': departureHour,
      'departureMinute': departureMinute,
      'minutesBefore': minutesBefore,
      'weekdays': weekdays,
      'enabled': enabled,
    };
  }

  factory TravelRoutineModel.fromMap(Map<dynamic, dynamic> map) {
    return TravelRoutineModel(
      name: map['name'] as String,
      destination: map['destination'] as String,
      departureHour: map['departureHour'] as int,
      departureMinute: map['departureMinute'] as int,
      minutesBefore: map['minutesBefore'] as int,
      weekdays: List<int>.from(map['weekdays']),
      enabled: map['enabled'] as bool,
    );
  }
}