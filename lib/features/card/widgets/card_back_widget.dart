// card/widgets/card_back_widget.dart

import 'package:flutter/material.dart';
import '../models/beneficiario_model.dart'; // Mantive o import, embora o beneficiario não seja usado neste design
import '../../../core/theme/app_theme.dart';

class CardBackWidget extends StatelessWidget {
  final Beneficiario beneficiario;

  const CardBackWidget({super.key, required this.beneficiario});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        // 1. Cor sólida, como na imagem, em vez de gradiente
        color: AppColors.vinhoUltraUniodonto,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      // Usamos ClipRRect para garantir que os cantos da barra vertical sejam cortados corretamente
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            // 2. Conteúdo principal (ocupa a maior parte do espaço)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Seção Superior
                    const Text(
                      'PLANO EXCLUSIVAMENTE ODONTOLÓGICO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'É obrigatória a apresentação de documento de identidade.',
                      style: TextStyle(color: Colors.white, fontSize: 9),
                    ),
                    const SizedBox(height: 12),
                    // Seção de Contatos
                    _buildContactRow(
                      'UNIODONTO PORTO ALEGRE ADMINISTRATIVO',
                      '(51) 3302-4000',
                    ),
                    _buildContactRow(
                      'URGÊNCIA 24 horas PORTO ALEGRE:',
                      '(51) 3302-4024',
                    ),
                    _buildContactRow('URGÊNCIA GUAÍBA:', '(51) 3055-4058'),
                    _buildContactRow('URGÊNCIA PELOTAS:', '(53) 3227-6515'),
                    const Spacer(), // Empurra o rodapé para baixo
                    // Seção do Rodapé
                    Row(
                      children: [
                        // 3. LOGO: Substitua pelo seu widget de logo
                        SizedBox(
                          height: 25,
                          child: Image.asset(
                            'assets/images/Logo-na-horizontal-colorido.png',
                          ), // <-- COLOQUE SEU LOGO AQUI
                        ),
                        const Spacer(),
                        const Text(
                          'www.uniodontopoa.com.br',
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // 4. Barra Branca Vertical na Direita
            Container(
              width: 28,
              color: AppColors.vinhoUltraUniodonto,
              child: RotatedBox(
                quarterTurns: 3, // Gira o conteúdo em -90 graus
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        color: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        child: const Text(
                          'ANS - nº 366439',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para criar as linhas de contato
  Widget _buildContactRow(String label, String number) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
