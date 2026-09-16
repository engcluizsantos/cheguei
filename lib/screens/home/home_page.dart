import 'package:cheguei/core/widgets/cheguei_button.dart';
import 'package:cheguei/core/widgets/cheguei_textfield.dart';
import 'package:cheguei/core/widgets/recommendation_card.dart';
import 'package:cheguei/models/recommendation_model.dart';
import 'package:cheguei/services/location/location_service.dart';
import 'package:cheguei/services/recommendation/recommendation_service.dart';
import 'package:cheguei/services/storage/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cheguei/services/sptrans/sptrans_service.dart';
import 'package:cheguei/core/constants/sptrans_constants.dart';
import 'package:cheguei/repositories/sptrans_repository.dart';
import 'package:cheguei/models/sptrans_stop_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:cheguei/app/app_router.dart';
import 'package:geocoding/geocoding.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = '';

  final originController = TextEditingController();
  final destinationController = TextEditingController();

  List<RecommendationModel> recommendations = [];

  // VARIÁVEIS DE ORIGEM
  double? latitude;
  double? longitude;

  // VARIÁVEIS DE DESTINO
  double? destinationLatitude;
  double? destinationLongitude;

  final MapController mapController = MapController();

  double distanceKm = 0;

  List<SpTransStopModel> nearbyStops = [];

  // Variáveis para armazenar as paradas

  SpTransStopModel? originStop;
  SpTransStopModel? destinationStop;

  Future<void> loadLocation() async {
    final position = await LocationService.getCurrentLocation();

    if (position == null) return;

    latitude = position.latitude;
    longitude = position.longitude;

    distanceKm = LocationService.calculateDistance(
      startLatitude: latitude!,
      startLongitude: longitude!,
      endLatitude: latitude! + 0.005,
      endLongitude: longitude! + 0.005,
    );

    // Busca as paradas próximas

    loadRecommendations();

    setState(() {});
  }

  Future<void> findBestRoute() async {
    final origin = originController.text.trim();
    final destination = destinationController.text.trim();

    if (origin.isEmpty || destination.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe a origem e o destino.')),
      );
      return;
    }

    final destinationLocations = await locationFromAddress(destination);

    if (destinationLocations.isNotEmpty) {
      destinationLatitude = destinationLocations.first.latitude;
      destinationLongitude = destinationLocations.first.longitude;
    }

    final authenticated = await SpTransService.authenticate(
      SpTransConstants.apiKey,
    );

    if (!authenticated) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha na autenticação da SPTrans.')),
      );
      return;
    }

    final originStops = await SpTransRepository.searchStops(origin);
    final destinationStops = await SpTransRepository.searchStops(destination);

    originStop = originStops.isNotEmpty ? originStops.first : null;
    destinationStop = destinationStops.isNotEmpty
        ? destinationStops.first
        : null;

    if (originStop != null && destinationStop != null) {
      distanceKm = LocationService.calculateDistance(
        startLatitude: originStop!.latitude,
        startLongitude: originStop!.longitude,
        endLatitude: destinationStop!.latitude,
        endLongitude: destinationStop!.longitude,
      );

      loadRecommendations();
    }

    setState(() {});

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (destinationLatitude != null &&
          destinationLongitude != null &&
          latitude != null &&
          longitude != null) {
        mapController.fitCamera(
          CameraFit.coordinates(
            coordinates: [
              LatLng(latitude!, longitude!),
              LatLng(destinationLatitude!, destinationLongitude!),
            ],
            padding: const EdgeInsets.all(50),
            maxZoom: 16,
          ),
        );
      }
    });
  }

  void loadRecommendations() {
    final user = StorageService.getUser();

    if (user == null) return;

    RecommendationService.generateRecommendations(
      distanceKm: distanceKm,
      user: user,
      hasNearbyBusStop: nearbyStops.isNotEmpty,
      hasStrongBusCoverage: false,
      busLinesFound: 0,
      metroStationsFound: 0,
      isRaining: false,
    );
  }

  @override
  void initState() {
    super.initState();

    final user = StorageService.getUser();

    if (user != null) {
      userName = user.name;
    }

    loadLocation();
  }

  @override
  void dispose() {
    originController.dispose();
    destinationController.dispose();
    super.dispose();
  }

  // ABRIR GOOGLE MAPS
  Future<void> openGoogleMaps() async {
    if (originStop == null || destinationStop == null) return;

    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=${originStop!.latitude},${originStop!.longitude}'
      '&destination=${destinationStop!.latitude},${destinationStop!.longitude}'
      '&travelmode=transit',
    );

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cheguei')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Olá, $userName 👋',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Mobilidade inteligente.',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              ChegueiTextField(
                controller: originController,
                label: 'Origem',
                hint: 'Ex.: Lapa, São Paulo',
                prefixIcon: Icons.trip_origin,
              ),

              const SizedBox(height: 16),

              ChegueiTextField(
                controller: destinationController,
                label: 'Destino',
                hint: 'Ex.: Paulista, São Paulo',
                prefixIcon: Icons.place,
              ),

              const SizedBox(height: 24),

              ChegueiButton(
                text: 'Encontrar melhor rota',
                icon: Icons.route,
                onPressed: findBestRoute,
              ),

              const SizedBox(height: 12),

              const SizedBox(height: 12),

              // TESTAR SPTRANS
              ElevatedButton.icon(
                onPressed: testSpTrans,
                icon: const Icon(Icons.directions_bus),
                label: const Text('Testar SPTrans'),
              ),

              OutlinedButton.icon(
                onPressed: () {
                  context.push(AppRoutes.assistant);
                },
                icon: const Icon(Icons.smart_toy),
                label: const Text('Assistente Inteligente'),
              ),

              const SizedBox(height: 32),

              if (originStop != null || destinationStop != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '📍 Rota encontrada',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        if (originStop != null)
                          Text(
                            'Origem: ${originStop!.name}',
                            style: const TextStyle(fontSize: 16),
                          ),

                        const SizedBox(height: 8),

                        if (destinationStop != null)
                          Text(
                            'Destino: ${destinationStop!.name}',
                            style: const TextStyle(fontSize: 16),
                          ),

                        const SizedBox(height: 16),

                        // BOTAO GOOGLE MAPS
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: openGoogleMaps,
                            icon: const Icon(Icons.map),
                            label: const Text('Abrir no Google Maps'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              const Text(
                'Sugestões de rota',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              ...recommendations.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: RecommendationCard(
                    emoji: item.emoji,
                    title: item.recommended ? '${item.type} ⭐' : item.type,
                    subtitle:
                        '${item.description} • Pontuação: ${item.score.toStringAsFixed(0)}',
                    onTap: () {},
                  ),
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'Sua localização atual',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              if (latitude != null && longitude != null)
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.deepPurple, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        initialCenter: LatLng(latitude!, longitude!),
                        initialZoom: 15,
                        initialCameraFit:
                            destinationLatitude != null &&
                                destinationLongitude != null
                            ? CameraFit.coordinates(
                                coordinates: [
                                  LatLng(latitude!, longitude!),
                                  LatLng(
                                    destinationLatitude!,
                                    destinationLongitude!,
                                  ),
                                ],
                                padding: const EdgeInsets.all(40),
                                maxZoom: 16,
                              )
                            : null,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.cheguei.app',
                        ),

                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(latitude!, longitude!),
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.location_on,
                                size: 40,
                                color: Colors.red,
                              ),
                            ),

                            if (destinationLatitude != null &&
                                destinationLongitude != null)
                              Marker(
                                point: LatLng(
                                  destinationLatitude!,
                                  destinationLongitude!,
                                ),
                                width: 40,
                                height: 40,
                                child: const Icon(
                                  Icons.flag,
                                  size: 40,
                                  color: Colors.blue,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              if (nearbyStops.isNotEmpty)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.directions_bus,
                              color: Colors.deepPurple,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Paradas próximas',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        ...nearbyStops
                            .take(5)
                            .map(
                              (stop) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Colors.red,
                                      size: 18,
                                    ),

                                    const SizedBox(width: 10),

                                    Expanded(
                                      child: Text(
                                        stop.name,
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> testSpTrans() async {
    final authenticated = await SpTransService.authenticate(
      SpTransConstants.apiKey,
    );

    if (!mounted) return;

    if (!authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha na autenticação da SPTrans.')),
      );
      return;
    }

    final stops = await SpTransService.searchStops('Paulista');

    debugPrint('=== TESTE PARADAS SPTRANS ===');
    debugPrint('Quantidade encontrada: ${stops.length}');

    for (final stop in stops.take(5)) {
      debugPrint('ID: ${stop.id}');
      debugPrint('Nome: ${stop.name}');
      debugPrint('Endereço: ${stop.address}');
      debugPrint('Latitude: ${stop.latitude}');
      debugPrint('Longitude: ${stop.longitude}');
      debugPrint('-----------------------------');
    }

    if (stops.isNotEmpty) {
      final forecasts = await SpTransService.getForecastsByStop(stops.first.id);

      debugPrint('=== PREVISÕES PROCESSADAS ===');
      debugPrint('Quantidade de linhas: ${forecasts.length}');

      for (final forecast in forecasts.take(5)) {
        debugPrint('Linha: ${forecast.lineCode}');
        debugPrint('Origem: ${forecast.origin}');
        debugPrint('Destino: ${forecast.destination}');
        debugPrint('Chegada prevista: ${forecast.arrivalTime}');
        debugPrint('Acessível: ${forecast.accessible}');
        debugPrint('Veículos monitorados: ${forecast.vehicleCount}');
        debugPrint('-----------------------------');
      }
    }
  }
}
