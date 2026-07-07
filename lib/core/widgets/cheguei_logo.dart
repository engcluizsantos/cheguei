import 'package:cheguei/app/app_theme.dart';
import 'package:flutter/material.dart';

class ChegueiLogo extends StatelessWidget {
  final double iconSize;
  final double titleSize;
  final bool showSubtitle;

  const ChegueiLogo({
    super.key,
    this.iconSize = 90,
    this.titleSize = 36,
    this.showSubtitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.assistant_navigation,
          size: iconSize,
          color: AppTheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'CHEGUEI',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: titleSize,
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
        ),
        if (showSubtitle) ...[
          const SizedBox(height: 8),
          Text(
            'Seu assistente inteligente\npara mobilidade urbana',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ]
      ],
    );
  }
}