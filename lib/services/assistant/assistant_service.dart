import 'package:cheguei/models/user_model.dart';
import 'package:cheguei/models/recommendation_model.dart';
import 'package:cheguei/services/recommendation/recommendation_service.dart';
import 'package:cheguei/services/storage/storage_service.dart';
import 'package:cheguei/services/metro/metro_service.dart';
import 'package:cheguei/models/assistant_response.dart';

class AssistantService {
  static Future<AssistantResponse> analyze({
    required String currentLocation,
    required String destination,
    required double distanceKm,
    required double temperature,
    required bool isRaining,
  }) async {
    if (destination.trim().isEmpty) {
      return const AssistantResponse(
        success: false,
        message: 'Informe um destino para que eu possa ajudá-lo.',
        transport: '',
        distanceKm: 0,
        score: 0,
        temperature: 0,
        isRaining: false,
      );
    }

    final UserModel? user = StorageService.getUser();

    if (user == null) {
      return const AssistantResponse(
        success: false,
        message: 'Não encontrei um perfil cadastrado.',
        transport: '',
        distanceKm: 0,
        score: 0,
        temperature: 0,
        isRaining: false,
      );
    }

    final metroLines = await MetroService.getMetroStatus();

    final metroStatus = metroLines
        .map((line) => '🚇 ${line.line}: ${line.status}')
        .join('\n');

    final List<RecommendationModel> recommendations =
        RecommendationService.generateRecommendations(
          distanceKm: distanceKm,
          user: user,
          hasNearbyBusStop: true,
          isRaining: isRaining,
        );

    final RecommendationModel best = recommendations.first;

    String weatherMessage = '';

    if (isRaining) {
      weatherMessage =
          '\n🌧️ Detectei chuva na sua região.\n'
          '🚶 Caminhada e 🚲 bicicleta receberam menor pontuação.\n';
    } else {
      weatherMessage =
          '\n☀️ O clima está favorável para deslocamentos ao ar livre.\n';
    }

    return AssistantResponse(
      success: true,
      message:
          '''
🤖 Olá!

Analisei sua solicitação e encontrei uma boa opção para você.

📍 Você está em:
$currentLocation

🎯 Destino:
$destination

🚇 Status das linhas:

$metroStatus

📏 Distância aproximada:
${distanceKm.toStringAsFixed(1)} km

🌡️ Temperatura:
${temperature.toStringAsFixed(1)}°C

$weatherMessage

${best.emoji} Recomendo utilizar ${best.type}.

⭐ Pontuação:
${best.score.toStringAsFixed(0)} pontos.
''',
      transport: best.type,
      distanceKm: distanceKm,
      score: best.score,

      temperature: 0,
      isRaining: false,
    );
  }
}
