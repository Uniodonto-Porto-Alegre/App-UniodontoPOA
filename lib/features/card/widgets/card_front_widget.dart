// card/widgets/card_front_widget.dart

import 'package:flutter/material.dart';
import 'package:uniodontopoa/core/theme/app_theme.dart';
import '../models/beneficiario_model.dart';
// Removi os imports não utilizados como 'dart:ui' e o AppTheme, se não for mais necessário.

class CardFrontWidget extends StatelessWidget {
  final Beneficiario beneficiario;

  const CardFrontWidget({super.key, required this.beneficiario});

  @override
  Widget build(BuildContext context) {
    // 1. Container principal com cor sólida e sombra
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,

          end: Alignment.bottomRight,

          colors: [
            AppColors.vinhoMedioUniodonto,

            AppColors.vinhoUltraUniodonto,
          ], // Gradiente mais vibrante
        ),

        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),

            blurRadius: 25,

            offset: const Offset(0, 10),
          ),
        ],
      ),
      // 2. Stack para sobrepor o padrão decorativo no lado direito
      child: Stack(
        children: [
          // 3. Conteúdo principal do cartão
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Número da Carteira
                Text(
                  beneficiario.carteira,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                // Nome do Beneficiário
                Text(
                  beneficiario.nome,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // Tipo de Contratação
                Text(
                  beneficiario.tipoContratacao.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // Empregador
                Text(
                  beneficiario.empregador,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
                const Spacer(), // Empurra as informações para baixo
                // 4. Seção de informações detalhadas
                _buildInfoRow(
                  'MOD: ${beneficiario.mod}',
                  beneficiario.registro,
                ),
                _buildInfoRow('INCL: ${beneficiario.inclusao}', ''),
                _buildInfoRow(
                  'CNS: ${beneficiario.cns}',
                  'NASC: ${beneficiario.nascimento}',
                ),
                _buildInfoRow('ABRANGENCIA: ${beneficiario.abrangencia}', ''),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para criar as linhas de informação com duas colunas
  Widget _buildInfoRow(String leftText, String rightText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            leftText,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          Text(
            rightText,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
