import 'package:flutter/material.dart';

class RecommendationCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const RecommendationCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Text(
          emoji,
          style: const TextStyle(fontSize: 28),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}