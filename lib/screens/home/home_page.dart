import 'package:cheguei/services/storage/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:cheguei/core/widgets/cheguei_textfield.dart';
import 'package:cheguei/core/widgets/cheguei_button.dart';
import 'package:cheguei/core/widgets/recommendation_card.dart';
import 'package:cheguei/models/recommendation_model.dart';
import 'package:cheguei/services/recommendation/recommendation_service.dart';

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

  void loadRecommendations() {
    final user = StorageService.getUser();

    if (user == null) return;

    recommendations = RecommendationService.generateRecommendations(
      distanceKm: 0.8,
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
    loadRecommendations();
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
    );
  }
}
