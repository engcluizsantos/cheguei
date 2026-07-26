import 'package:flutter/material.dart';
import 'package:cheguei/services/location/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

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

  String locationMessage = '';

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

      setState(() {
        currentPosition = position;
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

            const SizedBox(height: 20),

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
                onPressed: () {},
                icon: const Icon(Icons.search),
                label: const Text('Encontrar melhor rota'),
              ),
            ),

            const SizedBox(height: 40),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: const [
                    Icon(Icons.smart_toy, size: 50),
                    SizedBox(height: 16),
                    Text(
                      'A recomendação aparecerá aqui.',
                      textAlign: TextAlign.center,
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
