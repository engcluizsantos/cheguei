import 'package:cheguei/models/user_model.dart';
import 'package:cheguei/models/recommendation_model.dart';
import 'package:cheguei/services/recommendation/recommendation_service.dart';
import 'package:cheguei/services/storage/storage_service.dart';
import 'package:cheguei/services/metro/metro_service.dart';
import 'package:cheguei/models/assistant_response.dart';
import 'package:cheguei/services/sptrans/sptrans_service.dart';
import 'package:cheguei/services/metro/metro_station_service.dart';
import 'package:cheguei/core/constants/sptrans_constants.dart';

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

    final nearbyStations = MetroStationService.findStationsByDestination(
      destination,
    );

    final int metroStationsFound = nearbyStations.length;

    String stationMessage = '';

    stationMessage =
        '''
🚇 Estações relacionadas ao destino:
${nearbyStations.take(3).map((station) => '${station.name} (${station.line})').join('\n')}
''';

    int busLinesFound = 0;

    String busLinesMessage = '';

    try {
      final authenticated = await SpTransService.authenticate(
        SpTransConstants.apiKey,
      );

      if (!authenticated) {
        throw Exception('Falha na autenticação da SPTrans.');
      }

      final busStops = await SpTransService.searchStops(destination);

      if (busStops.isNotEmpty) {
        final forecasts = await SpTransService.getForecastsByStop(
          busStops.first.id,
        );

        busLinesFound = forecasts.length;

        if (forecasts.isNotEmpty) {
          final topForecasts = forecasts.take(3);

          busLinesMessage = topForecasts
              .map((forecast) {
                final accessibility = forecast.accessible
                    ? '♿ Acessível'
                    : 'Não acessível';

                return '• ${forecast.lineCode} - '
                    '${forecast.origin} → ${forecast.destination}\n'
                    '  Chegada prevista: ${forecast.arrivalTime} | '
                    '$accessibility';
              })
              .join('\n');
        } else {
          busLinesMessage =
              'Nenhuma previsão de ônibus disponível para esta parada.';
        }
      } else {
        busLinesMessage =
            'Não identifiquei cobertura de ônibus da SPTrans para este destino. '
            'Vou considerar as demais opções de transporte disponíveis.';
      }
    } catch (e) {
      busLinesFound = 0;

      busLinesMessage =
          'Não foi possível consultar a SPTrans neste momento. '
          'Vou considerar as demais opções de transporte disponíveis.';
    }

    final metroStatus = metroLines
        .map((line) => '🚇 ${line.line}: ${line.status}')
        .join('\n');

    bool hasStrongBusCoverage = false;

    final destinationLower = destination.toLowerCase();

    if (destinationLower.contains('paulista') ||
        destinationLower.contains('sé') ||
        destinationLower.contains('barra funda') ||
        destinationLower.contains('bourbon')) {
      hasStrongBusCoverage = true;
    }

    final List<RecommendationModel> recommendations =
        RecommendationService.generateRecommendations(
          distanceKm: distanceKm,
          user: user,
          hasNearbyBusStop: busLinesFound > 0,
          hasStrongBusCoverage: hasStrongBusCoverage,
          busLinesFound: busLinesFound,
          metroStationsFound: metroStationsFound,
          isRaining: isRaining,
        );

    final RecommendationModel best = recommendations.first;

    String rankingMessage = recommendations
        .map(
          (item) =>
              '${item.emoji} ${item.type}: ${item.score.toStringAsFixed(0)} pontos',
        )
        .join('\n');

    String recommendationReason = '';

    if (best.type == 'Caminhada') {
      recommendationReason =
          '📏 A distância é curta e adequada para deslocamento a pé.';
    }

    if (best.type == 'Bicicleta') {
      recommendationReason =
          '🚲 A distância é adequada para bicicleta e seu perfil permite esse deslocamento.';
    }

    if (best.type == 'Ônibus') {
      recommendationReason =
          '🚌 Foram encontradas opções de transporte público para esta região.';
    }

    if (best.type == 'Metrô') {
      recommendationReason =
          '🚇 Existem linhas metroferroviárias disponíveis para o trajeto.';
    }

    if (best.type == 'Carro') {
      recommendationReason =
          '🚗 Esta opção oferece maior conforto para o deslocamento.';
    }

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

$stationMessage

🚌 Linhas encontradas:

$busLinesFound

🚌 Principais linhas:

$busLinesMessage
🚇 Status das linhas:

$metroStatus

📏 Distância aproximada:
${distanceKm.toStringAsFixed(1)} km

🌡️ Temperatura:
${temperature.toStringAsFixed(1)}°C

$weatherMessage

${best.emoji} Recomendo utilizar ${best.type}.

$recommendationReason

⭐ Ranking das opções:

$rankingMessage

''',
      transport: best.type,
      distanceKm: distanceKm,
      score: best.score,
      temperature: temperature,
      isRaining: isRaining,
    );
  }
}
