class UserModel {
  final String name;
  final String email;
  final String password;

  final int age;

  final bool isElderly;
  final bool isPregnant;
  final bool hasDisability;
  final bool reducedMobility;

  final bool preferShortestTime;
  final bool preferLowestCost;
  final bool avoidTransfers;
  final bool needAccessibility;

  final bool firstAccess;

  const UserModel({
    required this.name,
    required this.email,
    required this.password,

    this.age = 0,

    this.isElderly = false,
    this.isPregnant = false,
    this.hasDisability = false,
    this.reducedMobility = false,

    this.preferShortestTime = false,
    this.preferLowestCost = false,
    this.avoidTransfers = false,
    this.needAccessibility = false,

    this.firstAccess = true,
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? password,
    int? age,
    bool? isElderly,
    bool? isPregnant,
    bool? hasDisability,
    bool? reducedMobility,

    bool? preferShortestTime,
    bool? preferLowestCost,
    bool? avoidTransfers,
    bool? needAccessibility,
    bool? firstAccess,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      age: age ?? this.age,
      isElderly: isElderly ?? this.isElderly,
      isPregnant: isPregnant ?? this.isPregnant,
      hasDisability: hasDisability ?? this.hasDisability,
      reducedMobility: reducedMobility ?? this.reducedMobility,

      preferShortestTime: preferShortestTime ?? this.preferShortestTime,
      preferLowestCost: preferLowestCost ?? this.preferLowestCost,
      avoidTransfers: avoidTransfers ?? this.avoidTransfers,
      needAccessibility: needAccessibility ?? this.needAccessibility,
      firstAccess: firstAccess ?? this.firstAccess,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'age': age,
      'isElderly': isElderly,
      'isPregnant': isPregnant,
      'hasDisability': hasDisability,
      'reducedMobility': reducedMobility,

      'preferShortestTime': preferShortestTime,
      'preferLowestCost': preferLowestCost,
      'avoidTransfers': avoidTransfers,
      'needAccessibility': needAccessibility,
      'firstAccess': firstAccess,
    };
  }

  factory UserModel.fromMap(Map<dynamic, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      age: map['age'] ?? 0,
      isElderly: map['isElderly'] ?? false,
      isPregnant: map['isPregnant'] ?? false,
      hasDisability: map['hasDisability'] ?? false,
      reducedMobility: map['reducedMobility'] ?? false,

      preferShortestTime: map['preferShortestTime'] ?? false,
      preferLowestCost: map['preferLowestCost'] ?? false,
      avoidTransfers: map['avoidTransfers'] ?? false,
      needAccessibility: map['needAccessibility'] ?? false,
      firstAccess: map['firstAccess'] ?? true,
    );
  }
}
