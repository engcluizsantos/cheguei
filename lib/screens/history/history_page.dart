import 'package:flutter/material.dart';
import 'package:cheguei/services/storage/storage_service.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final history = StorageService.getHistory();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico'),
      ),
      body: history.isEmpty
          ? const Center(
              child: Text('Nenhum destino pesquisado.'),
            )
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final destination = history[index];

                return ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(destination),
                );
              },
            ),
    );
  }
}