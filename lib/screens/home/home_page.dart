import 'package:cheguei/services/storage/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:cheguei/core/widgets/cheguei_textfield.dart';
import 'package:cheguei/core/widgets/cheguei_button.dart';
import 'package:cheguei/core/widgets/recommendation_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = '';

  final originController = TextEditingController();
  final destinationController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final user = StorageService.getUser();

    if (user != null) {
      userName = user.name;
    }
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Olá, $userName!',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
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

            RecommendationCard(
              emoji: '🚶',
              title: 'Caminhada',
              subtitle: '800 metros • 10 minutos',
              onTap: () {},
            ),

            RecommendationCard(
              emoji: '🚲',
              title: 'Bicicleta',
              subtitle: '800 metros • 4 minutos',
              onTap: () {},
            ),

            RecommendationCard(
              emoji: '🚌',
              title: 'Ônibus',
              subtitle: 'Linha 4310 • 18 minutos',
              onTap: () {},
            ),

            RecommendationCard(
              emoji: '🚗',
              title: 'Carro',
              subtitle: '800 metros • 5 minutos',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
