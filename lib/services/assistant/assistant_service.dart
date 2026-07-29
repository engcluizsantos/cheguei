import 'package:cheguei/models/user_model.dart';
import 'package:cheguei/models/recommendation_model.dart';
import 'package:cheguei/services/recommendation/recommendation_service.dart';
import 'package:cheguei/services/storage/storage_service.dart';

class AssistantService {
  static Future<String> analyze({
    required String currentLocation,
    required String destination,
    required double distanceKm,
  }) async {
    if (destination.trim().isEmpty) {
      return 'Informe um destino para que eu possa ajudá-lo.';
    }

    final UserModel? user = StorageService.getUser();

    if (user == null) {
      return 'Não encontrei um perfil cadastrado.';
    }

    final List<RecommendationModel> recommendations =
        RecommendationService.generateRecommendations(
          distanceKm: distanceKm,
          user: user,
          hasNearbyBusStop: true,
        );

    final RecommendationModel best = recommendations.first;

return '''
🤖 Olá!

Analisei sua solicitação e encontrei uma boa opção para você.

📍 Você está em:
$currentLocation

🎯 Destino:
$destination

📏 Distância aproximada:
${distanceKm.toStringAsFixed(1)} km

${best.emoji} Recomendo utilizar ${best.type}.

Essa alternativa apresentou a melhor pontuação para o seu perfil, considerando as preferências cadastradas e as regras de mobilidade do aplicativo.

⭐ Pontuação da recomendação:
${best.score.toStringAsFixed(0)} pontos.
''';

  }
}
