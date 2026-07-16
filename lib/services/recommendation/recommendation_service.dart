import 'package:cheguei/models/recommendation_model.dart';
import 'package:cheguei/models/user_model.dart';

class RecommendationService {
  static List<RecommendationModel> generateRecommendations({
    required double distanceKm,
    required UserModel user,
    required bool hasNearbyBusStop,
  }) {
    final recommendations = <RecommendationModel>[];

    // 🚶 Caminhada
    double walkScore = distanceKm <= 1 ? 100 : 60;

    // 🚲 Bicicleta
    double bikeScore = distanceKm <= 3 ? 90 : 50;

    // 🚌 Ônibus
    double busScore = 70;

    // Existe parada próxima?
    if (hasNearbyBusStop) {
      busScore += 20;
    } else {
      busScore -= 20;
    }

    // 🚗 Carro
    double carScore = 60;

    // Perfil do usuário
    if (user.isElderly || user.hasDisability || user.reducedMobility) {
      bikeScore = 0;
      walkScore -= 30;
    }

    if (user.isPregnant) {
      bikeScore = 0;
    }

    // Preferências
    if (user.preferLowestCost) {
      walkScore += 10;
      busScore += 10;
    }

    if (user.preferShortestTime) {
      bikeScore += 10;
      carScore += 10;
    }

    recommendations.add(
      RecommendationModel(
        type: 'Caminhada',
        emoji: '🚶',
        description: '${distanceKm.toStringAsFixed(1)} km',
        score: walkScore,
        recommended: false,
      ),
    );

    recommendations.add(
      RecommendationModel(
        type: 'Bicicleta',
        emoji: '🚲',
        description: '${distanceKm.toStringAsFixed(1)} km',
        score: bikeScore,
        recommended: false,
      ),
    );

    recommendations.add(
      RecommendationModel(
        type: 'Ônibus',
        emoji: '🚌',
        description: 'Transporte público',
        score: busScore,
        recommended: false,
      ),
    );

    recommendations.add(
      RecommendationModel(
        type: 'Carro',
        emoji: '🚗',
        description: '${distanceKm.toStringAsFixed(1)} km',
        score: carScore,
        recommended: false,
      ),
    );

    recommendations.sort((a, b) => b.score.compareTo(a.score));

    final best = recommendations.first;

    return recommendations
        .map((item) => item.copyWith(recommended: item.type == best.type))
        .toList();
  }
}
