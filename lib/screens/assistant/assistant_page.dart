import 'package:flutter/material.dart';
import 'package:cheguei/services/location/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cheguei/services/assistant/assistant_service.dart';
import 'package:cheguei/models/weather_model.dart';
import 'package:cheguei/services/weather/weather_service.dart';

class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  final destinationController = TextEditingController();

  Position? currentPosition;
  bool loadingLocation = true;

  String currentAddress = 'Localizando...';

  WeatherModel? currentWeather;

  String locationMessage = '';

  String assistantMessage =
      'Olá! Eu sou o Gui.\n\nPara onde você deseja ir hoje?';

  String recommendedTransport = '';
  String recommendedEmoji = '';

  Future<void> loadLocation() async {
    final status = await LocationService.checkLocationStatus();

    if (status != null) {
      if (!mounted) return;

      setState(() {
        loadingLocation = false;
        currentAddress = status;
      });

      return;
    }

    final position = await LocationService.getCurrentLocation();

    if (!mounted) return;

    if (position == null) {
      setState(() {
        loadingLocation = false;
        currentAddress = 'Não foi possível obter a localização.';
      });
      return;
    }

    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final place = placemarks.first;

      final weather = await WeatherService.getCurrentWeather(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      setState(() {
        currentPosition = position;
        currentWeather = weather;

        currentAddress =
            '${place.subLocality?.isNotEmpty == true ? place.subLocality : place.locality}\n'
            '${place.locality} - ${place.administrativeArea}';

        loadingLocation = false;
      });
    } catch (e) {
      setState(() {
        currentPosition = position;
        currentAddress =
            'Localização encontrada, mas não foi possível obter o endereço.';
        loadingLocation = false;
      });
    }
  }

  Future<void> findRoute() async {
    if (currentPosition == null) {
      setState(() {
        assistantMessage = 'Não foi possível obter sua localização atual.';
      });
      return;
    }

    final destinationPosition = await getDestinationPosition(
      destinationController.text,
    );

    if (destinationPosition == null) {
      setState(() {
        assistantMessage = 'Não consegui localizar o destino informado.';
      });
      return;
    }

    final distanceKm = LocationService.calculateDistance(
      startLatitude: currentPosition!.latitude,
      startLongitude: currentPosition!.longitude,
      endLatitude: destinationPosition.latitude,
      endLongitude: destinationPosition.longitude,
    );

    final response = await AssistantService.analyze(
      currentLocation: currentAddress,
      destination: destinationController.text,
      distanceKm: distanceKm,
      temperature: currentWeather?.temperature ?? 0,
      isRaining: currentWeather?.isRaining ?? false,
    );

    if (!mounted) return;

    String emoji = '';

    switch (response.transport) {
      case 'Caminhada':
        emoji = '🚶';
        break;

      case 'Bicicleta':
        emoji = '🚲';
        break;

      case 'Ônibus':
        emoji = '🚌';
        break;

      case 'Metrô':
        emoji = '🚇';
        break;

      case 'Carro':
        emoji = '🚗';
        break;
    }

    setState(() {
      assistantMessage = response.message;
      recommendedTransport = response.transport;
      recommendedEmoji = emoji;
    });
  }

  Future<Position?> getDestinationPosition(String destination) async {
    try {
      final locations = await locationFromAddress(destination);

      if (locations.isEmpty) return null;

      return Position(
        latitude: locations.first.latitude,
        longitude: locations.first.longitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    loadLocation();
  }

  @override
  void dispose() {
    destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistente Inteligente'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'assets/images/assistant.png',
                width: 200,
                height: 200,
              ),
            ),

            const SizedBox(height: 10),

            const Center(
              child: Text(
                'Assistente Cheguei',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 12),

            const Center(
              child: Text(
                'Vou ajudá-lo a encontrar a melhor forma de chegar ao seu destino.',
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 40),

            Card(
              child: ListTile(
                leading: const Icon(Icons.my_location),
                title: const Text('Sua localização'),
                subtitle: loadingLocation
                    ? const Text('📡 Localizando...')
                    : Text(currentAddress),
              ),
            ),

            const SizedBox(height: 15),

            Card(
              child: ListTile(
                leading: const Icon(Icons.cloud),
                title: const Text('Clima Atual'),
                subtitle: currentWeather == null
                    ? const Text('Não disponível')
                    : Text(
                        '${currentWeather!.temperature.toStringAsFixed(1)}°C\n'
                        '${currentWeather!.isRaining ? "🌧️ Chovendo" : "☀️ Sem chuva"}',
                      ),
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: destinationController,
              decoration: const InputDecoration(
                labelText: 'Destino',
                hintText: 'Ex.: Avenida Paulista',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                //onPressed: () {},
                onPressed: findRoute,
                icon: const Icon(Icons.search),
                label: const Text('Encontrar melhor rota'),
              ),
            ),

            const SizedBox(height: 40),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.smart_toy, size: 50),

                    const SizedBox(height: 16),

                    if (recommendedTransport.isNotEmpty)
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const Text(
                                'Melhor opção encontrada',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                recommendedEmoji,
                                style: const TextStyle(fontSize: 40),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                recommendedTransport,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),

                    Text(
                      assistantMessage,
                      textAlign: TextAlign.left,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
