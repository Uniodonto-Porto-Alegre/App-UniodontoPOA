// card/views/card_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart'; // 1. Importe o pacote
import '../models/beneficiario_model.dart';
import '../widgets/card_front_widget.dart';
import '../widgets/card_back_widget.dart';
import '../../../core/theme/app_theme.dart';

class CardDetailsScreen extends StatelessWidget {
  // 2. Pode ser um StatelessWidget agora
  final Beneficiario beneficiario;

  const CardDetailsScreen({super.key, required this.beneficiario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carteirinha Digital'),
        backgroundColor:
            AppColors.vinhoUltraUniodonto, // Cor de fundo mais escura
        elevation: 0,
      ),
      // 3. Fundo com gradiente sutil e escuro
      backgroundColor: AppColors.fundoConteudo,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 4. O widget FlipCard cuida de toda a lógica e animação
              FlipCard(
                front: CardFrontWidget(beneficiario: beneficiario),
                back: CardBackWidget(beneficiario: beneficiario),
                direction: FlipDirection.HORIZONTAL, // Animação horizontal
              ),
              const SizedBox(height: 40),
              // 5. Instrução clara para o usuário
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.touch_app_outlined,
                    color: AppColors.vinhoUltraUniodonto,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Toque no cartão para virar',
                    style: TextStyle(
                      color: AppColors.vinhoUltraUniodonto,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
