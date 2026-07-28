import 'package:cheguei/models/user_model.dart';
import 'package:cheguei/models/recommendation_model.dart';
import 'package:cheguei/services/recommendation/recommendation_service.dart';
import 'package:cheguei/services/storage/storage_service.dart';

class AssistantService {
  static Future<String> analyze({
    required String currentLocation,
    required String destination,
  }) async {
    if (destination.trim().isEmpty) {
      return 'Informe um destino para que eu possa ajudá-lo.';
    }

    final UserModel? user = StorageService.getUser();

    if (user == null) {
      return 'Não encontrei um perfil cadastrado.';
    }

    const double simulatedDistance = 5.0;

final List<RecommendationModel> recommendations =
    RecommendationService.generateRecommendations(
  distanceKm: simulatedDistance,
  user: user,
  hasNearbyBusStop: true,
);

final RecommendationModel best = recommendations.first;

    return '''
Olá!

Analisei sua solicitação.

📍 Origem:
$currentLocation

🎯 Destino:
$destination

${best.emoji} Minha recomendação é utilizar ${best.type}.

Motivo:
Essa opção foi considerada a mais adequada com base no seu perfil e nas regras do aplicativo.

Pontuação: ${best.score.toStringAsFixed(0)} pontos.
''';
  }
}
