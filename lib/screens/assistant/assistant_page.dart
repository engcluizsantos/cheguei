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
import 'package:cheguei/services/notifications/notification_service.dart';

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

  String assistantMessage = '';

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
      builder: (dialogContext) {
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
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = controller.text.trim();

                if (value.isNotEmpty) {
                  Navigator.pop(dialogContext, value);
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

  String getTransportIcon(String transport) {
    switch (transport) {
      case 'Caminhada':
        return 'assets/icons/pessoa.png';

      case 'Bicicleta':
        return 'assets/icons/bike.png';

      case 'Ônibus':
        return 'assets/icons/onibus.png';

      case 'Metrô':
        return 'assets/icons/metro.png';

      case 'Carro':
        return 'assets/icons/carro.png';

      default:
        return 'assets/icons/pessoa.png';
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
        actions: [
          // BOTAO PARA TESTAR NOTIFICAÇÃO-------------------------------------------
          IconButton(
            onPressed: () async {
              await NotificationService.scheduleTestNotification();
            },
            icon: const Icon(Icons.notifications_active),
            tooltip: 'Agendar notificação de teste',
          ),

          IconButton(
            onPressed: () {
              context.push('/routine');
            },
            icon: const Icon(Icons.alarm),
            tooltip: 'Rotinas',
          ),

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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/assistant.png',
                    width: 160,
                    height: 160,
                  ),
                  const SizedBox(height: 12),

                  const Text(
                    'Olá, eu sou o Gui!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Vou ajudá-lo a encontrar a melhor forma de chegar ao seu destino.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, height: 1.4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEDE7F6),
                    child: Icon(Icons.my_location, color: Colors.deepPurple),
                  ),
                  title: const Text(
                    'Sua localização',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: loadingLocation
                      ? const Text('📡 Localizando...')
                      : Text(currentAddress),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEDE7F6),
                    child: Icon(Icons.cloud, color: Colors.deepPurple),
                  ),
                  title: const Text(
                    'Clima atual',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: currentWeather == null
                      ? const Text('Não disponível')
                      : Text(
                          '${currentWeather!.temperature.toStringAsFixed(1)}°C\n'
                          '${currentWeather!.isRaining ? "🌧️ Chovendo" : "☀️ Sem chuva"}',
                        ),
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
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                    side: const BorderSide(color: Colors.deepPurple),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
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
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                    side: const BorderSide(color: Colors.deepPurple),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
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
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                    side: const BorderSide(color: Colors.deepPurple),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
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

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  if (destinationController.text.trim().isNotEmpty) {
                    openGoogleMaps(destinationController.text);
                  }
                },
                icon: const Icon(Icons.map_outlined),
                label: const Text('Ver no Google Maps'),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
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
                icon: const Icon(Icons.star_outline),
                label: const Text('Adicionar aos favoritos'),
              ),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: findRoute,
                icon: const Icon(Icons.route),
                label: const Text(
                  'Encontrar melhor rota',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 40),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    if (recommendedTransport.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.deepPurple.shade100),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              getTransportIcon(recommendedTransport),
                              width: 52,
                              height: 52,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Melhor opção encontrada',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    recommendedTransport,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        assistantMessage,
                        textAlign: TextAlign.left,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
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
