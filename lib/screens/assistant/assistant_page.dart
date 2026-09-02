import 'package:flutter/material.dart';
import 'package:cheguei/services/location/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cheguei/services/assistant/assistant_service.dart';
import 'package:cheguei/models/weather_model.dart';
import 'package:cheguei/services/weather/weather_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cheguei/services/storage/storage_service.dart';
import 'package:go_router/go_router.dart';
//import 'package:animated_text_kit/animated_text_kit.dart';

// O AssistantPage é um StatefulWidget, isso significa que ele precisa atualizar as informações
// dinamicamente (localização, clima, rota).

class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

// A classe _AssistantPageState guarda variáveis como localização atual, clima, mensagens do
// Assistente e transporte recomendado.

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

  /* LOCALIZAÇÃO
  * Usa o LocationService e o pacote geolocator para obter a localização atual.
  * Converte Latitude e Longitude em endereço com placemarkFromCoordinates (Pacote Geocoding)
  */

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

    await StorageService.saveHistory(destinationController.text.trim());

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

  Future<void> openGoogleMaps(String destination) async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(destination)}',
    );

    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  void useFrequentDestination(String? address, String label) {
    if (address == null || address.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nenhum endereço de $label cadastrado.')),
      );
      return;
    }

    setState(() {
      destinationController.text = address;
    });
  }

  Future<void> saveFrequentDestination(
    String label,
    Future<void> Function(String) saveAddress,
  ) async {
    final controller = TextEditingController();

    final address = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Cadastrar $label'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Endereço de $label',
              hintText: 'Digite o endereço completo',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = controller.text.trim();

                if (value.isNotEmpty) {
                  Navigator.pop(context, value);
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (address == null || address.isEmpty) {
      return;
    }

    await saveAddress(address);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label salvo com sucesso.')));
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
        actions: [
          IconButton(
            onPressed: () {
              context.push('/profile');
            },
            icon: const Icon(Icons.person),
            tooltip: 'Perfil',
          ),
          IconButton(
            onPressed: () {
              context.push('/favorites');
            },
            icon: const Icon(Icons.star),
            tooltip: 'Favoritos',
          ),
          IconButton(
            onPressed: () {
              context.push('/home');
            },
            icon: const Icon(Icons.home),
            tooltip: 'Home',
          ),
          IconButton(
            onPressed: () {
              context.push('/history');
            },
            icon: const Icon(Icons.history),
            tooltip: 'Histórico',
          ),
        ],
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

            const SizedBox(height: 16),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    final address = StorageService.getHomeAddress();

                    if (address == null || address.trim().isEmpty) {
                      saveFrequentDestination(
                        'Casa',
                        StorageService.saveHomeAddress,
                      );
                    } else {
                      useFrequentDestination(address, 'Casa');
                    }
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('Casa'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    final address = StorageService.getWorkAddress();

                    if (address == null || address.trim().isEmpty) {
                      saveFrequentDestination(
                        'Trabalho',
                        StorageService.saveWorkAddress,
                      );
                    } else {
                      useFrequentDestination(address, 'Trabalho');
                    }
                  },
                  icon: const Icon(Icons.work),
                  label: const Text('Trabalho'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    final address = StorageService.getCollegeAddress();

                    if (address == null || address.trim().isEmpty) {
                      saveFrequentDestination(
                        'Faculdade',
                        StorageService.saveCollegeAddress,
                      );
                    } else {
                      useFrequentDestination(address, 'Faculdade');
                    }
                  },
                  icon: const Icon(Icons.school),
                  label: const Text('Faculdade'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: () {
                if (destinationController.text.trim().isNotEmpty) {
                  openGoogleMaps(destinationController.text);
                }
              },
              icon: const Icon(Icons.map),
              label: const Text('Ver no Google Maps'),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: () async {
                final destination = destinationController.text.trim();

                if (destination.isNotEmpty) {
                  await StorageService.saveFavorite(destination);

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Destino adicionado aos favoritos.'),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.star),
              label: const Text('Adicionar aos favoritos'),
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

                    // ANIMA A SAUDAÇÃO DO ASSISTENTE

                    /*
                    AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          assistantMessage,
                          textStyle: const TextStyle(fontSize: 16, height: 1.5),
                          speed: const Duration(milliseconds: 80),
                        ),
                      ],
                      totalRepeatCount: 1, // só uma vez
                      pause: const Duration(milliseconds: 500),
                      displayFullTextOnTap:
                          true, // mostra tudo se o usuário tocar
                      stopPauseOnTap: true,
                    ),
                    */

                    /*
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                      child: Text(
                        assistantMessage,
                        key: ValueKey<String>(assistantMessage),
                        textAlign: TextAlign.left,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ),
                    */
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
