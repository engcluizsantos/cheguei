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

  double? latitude;
  double? longitude;

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

    debugPrint('');
    debugPrint('========== RESULTADO DA BUSCA ==========');

    debugPrint('Origem: $origin');
    debugPrint('Paradas encontradas: ${originStops.length}');
    if (originStops.isNotEmpty) {
      debugPrint('Primeira parada: ${originStops.first.name}');
    }

    debugPrint('');

    debugPrint('Destino: $destination');
    debugPrint('Paradas encontradas: ${destinationStops.length}');
    if (destinationStops.isNotEmpty) {
      debugPrint('Primeira parada: ${destinationStops.first.name}');
    }

    debugPrint('========================================');
  }

  void loadRecommendations() {
    final user = StorageService.getUser();

    if (user == null) return;

    recommendations = RecommendationService.generateRecommendations(
      distanceKm: distanceKm,
      user: user,
      hasNearbyBusStop: nearbyStops.isNotEmpty,
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
              Text(
                'Olá, $userName!',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              ChegueiTextField(
                controller: originController,
                label: 'Origem',
                hint: 'Digite o local de origem',
                prefixIcon: Icons.my_location,
              ),

              const SizedBox(height: 16),

              ChegueiTextField(
                controller: destinationController,
                label: 'Destino',
                hint: 'Digite o destino',
                prefixIcon: Icons.location_on,
              ),

              const SizedBox(height: 24),

              ChegueiButton(
                text: 'Encontrar melhor rota',
                onPressed: findBestRoute,
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
                      options: MapOptions(
                        initialCenter: LatLng(latitude!, longitude!),
                        initialZoom: 15,
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
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              if (nearbyStops.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🚌 Paradas próximas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        ...nearbyStops
                            .take(5)
                            .map(
                              (stop) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text('• ${stop.name}'),
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

    final lines = await SpTransService.searchLines('8000');

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('SPTrans conectada! Linhas encontradas: ${lines.length}'),
      ),
    );

    if (lines.isNotEmpty) {
      debugPrint('Linha: ${lines.first.code}');
      debugPrint('Origem: ${lines.first.origin}');
      debugPrint('Destino: ${lines.first.destination}');
    }
  }
}

/* CODIGO ANTIGO
import 'package:cheguei/services/storage/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:cheguei/core/widgets/cheguei_textfield.dart';
import 'package:cheguei/core/widgets/cheguei_button.dart';
import 'package:cheguei/core/widgets/recommendation_card.dart';
import 'package:cheguei/models/recommendation_model.dart';
import 'package:cheguei/services/recommendation/recommendation_service.dart';
import 'package:cheguei/services/location/location_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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

  double? latitude;
  double? longitude;

  double distanceKm = 0;

  Future<void> loadLocation() async {
    final position = await LocationService.getCurrentLocation();

    if (position == null) return;

    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
    });

    distanceKm = LocationService.calculateDistance(
      startLatitude: latitude!,
      startLongitude: longitude!,
      endLatitude: latitude! + 0.005,
      endLongitude: longitude! + 0.005,
    );

    loadRecommendations();

    setState(() {});
  }

  void loadRecommendations() {
    final user = StorageService.getUser();

    if (user == null) return;

    recommendations = RecommendationService.generateRecommendations(
      distanceKm: distanceKm,
      user: user,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cheguei')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Olá, $userName!',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              ChegueiTextField(
                controller: originController,
                label: 'Origem',
                hint: 'Digite o local de origem',
                prefixIcon: Icons.my_location,
              ),

              const SizedBox(height: 16),

              ChegueiTextField(
                controller: destinationController,
                label: 'Destino',
                hint: 'Digite o destino',
                prefixIcon: Icons.location_on,
              ),

              const SizedBox(height: 24),

              ChegueiButton(text: 'Encontrar melhor rota', onPressed: () {}),

              // APENAS PARA TESTE-------------------------------------------------------------
              if (latitude != null && longitude != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Latitude: ${latitude!.toStringAsFixed(6)}\n'
                    'Longitude: ${longitude!.toStringAsFixed(6)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),

              if (latitude != null && longitude != null)
                SizedBox(
                  height: 300,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(latitude!, longitude!),
                      initialZoom: 15,
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
                        ],
                      ),
                    ],
                  ),
                ),

              //--------------------------------------------------------------------------------

              //Card de Caminhada
              const SizedBox(height: 32),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Sugestões de rota',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 16),

              ...recommendations.map(
                (item) => RecommendationCard(
                  emoji: item.emoji,
                  title: item.recommended ? '${item.type} ⭐' : item.type,
                  subtitle:
                      '${item.description} • Pontuação: ${item.score.toStringAsFixed(0)}',
                  onTap: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/
