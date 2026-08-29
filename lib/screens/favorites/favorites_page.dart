import 'package:flutter/material.dart';
import 'package:cheguei/services/storage/storage_service.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = StorageService.getFavorites();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
      ),
      body: favorites.isEmpty
          ? const Center(
              child: Text('Nenhum favorito salvo.'),
            )
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final destination = favorites[index];

                return ListTile(
                  leading: const Icon(Icons.star),
                  title: Text(destination),
                );
              },
            ),
    );
  }
}