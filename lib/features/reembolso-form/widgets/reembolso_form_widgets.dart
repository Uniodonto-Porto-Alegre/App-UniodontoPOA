import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_theme.dart';

class ReembolsoFormWidgets {
  static Widget buildLoadingScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.vinhoUltraUniodonto, Color(0xFF4A1B3B)],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
            SizedBox(height: 24),
            Text(
              'Enviando sua solicitação...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Aguarde alguns instantes',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildModernAppBar(
    BuildContext context,
    String currentStepTitle,
    int currentStep,
    int totalSteps,
  ) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.vinhoUltraUniodonto, Color(0xFF4A1B3B)],
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, offset: Offset(0, 2), blurRadius: 8),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Solicitar Reembolso',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      currentStepTitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${currentStep + 1}/$totalSteps',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget buildProgressIndicator(int currentStep, int totalSteps) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: List.generate(totalSteps, (index) {
          final isActive = index == currentStep;
          final isCompleted = index < currentStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: isCompleted || isActive
                          ? AppColors.vinhoUltraUniodonto
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (index < totalSteps - 1) const SizedBox(width: 8),
              ],
            ),
          );
        }),
      ),
    );
  }

  static Widget buildStepHeader(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.vinhoUltraUniodonto.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.vinhoUltraUniodonto, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildModernTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    bool readOnly = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters, // Novo parâmetro para máscaras
    int? maxLines = 1,
    Widget? suffixIcon,
    VoidCallback? onTap,
    void Function(String)? onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        validator: validator,
        inputFormatters: inputFormatters, // Aplicar máscaras aqui
        maxLines: maxLines,
        onTap: onTap,
        onChanged: onChanged,
        style: TextStyle(
          fontSize: 16,
          color: readOnly ? Colors.grey[600] : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: icon != null
              ? Icon(
                  icon,
                  color: readOnly
                      ? Colors.grey[400]
                      : AppColors.vinhoUltraUniodonto,
                  size: 22,
                )
              : null,
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: readOnly ? Colors.grey[50] : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.vinhoUltraUniodonto,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          labelStyle: TextStyle(
            color: readOnly ? Colors.grey[500] : Colors.grey[700],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
        ),
      ),
    );
  }

  static Widget buildNavigationButtons(
    BuildContext context,
    int currentStep,
    int totalSteps,
    VoidCallback onPrevious,
    VoidCallback onNext,
  ) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (currentStep > 0)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPrevious,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Voltar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.vinhoUltraUniodonto,
                    side: const BorderSide(
                      color: AppColors.vinhoUltraUniodonto,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            if (currentStep > 0) const SizedBox(width: 16),
            Expanded(
              flex: currentStep == 0 ? 1 : 2,
              child: ElevatedButton.icon(
                onPressed: onNext,
                icon: Icon(
                  currentStep == totalSteps - 1
                      ? Icons.send
                      : Icons.arrow_forward,
                ),
                label: Text(
                  currentStep == totalSteps - 1
                      ? 'Enviar Solicitação'
                      : 'Continuar',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.vinhoUltraUniodonto,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Novos métodos para formatação de texto
  static String formatPhoneNumber(String text) {
    final digitsOnly = text.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length <= 10) {
      // Telefone fixo: (11) 1234-5678
      if (digitsOnly.length >= 2) {
        String formatted = '(${digitsOnly.substring(0, 2)})';
        if (digitsOnly.length > 2) {
          formatted +=
              ' ${digitsOnly.substring(2, digitsOnly.length >= 6 ? 6 : digitsOnly.length)}';
        }
        if (digitsOnly.length > 6) {
          formatted +=
              '-${digitsOnly.substring(6, digitsOnly.length >= 10 ? 10 : digitsOnly.length)}';
        }
        return formatted;
      }
    } else {
      // Celular: (11) 91234-5678
      String formatted = '(${digitsOnly.substring(0, 2)})';
      formatted += ' ${digitsOnly.substring(2, 7)}';
      formatted += '-${digitsOnly.substring(7, 11)}';
      return formatted;
    }
    return text;
  }

  static String formatCpfCnpj(String text) {
    final digitsOnly = text.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length <= 11) {
      // CPF: 123.456.789-12
      if (digitsOnly.length >= 3) {
        String formatted = digitsOnly.substring(0, 3);
        if (digitsOnly.length > 3) {
          formatted +=
              '.${digitsOnly.substring(3, digitsOnly.length >= 6 ? 6 : digitsOnly.length)}';
        }
        if (digitsOnly.length > 6) {
          formatted +=
              '.${digitsOnly.substring(6, digitsOnly.length >= 9 ? 9 : digitsOnly.length)}';
        }
        if (digitsOnly.length > 9) {
          formatted +=
              '-${digitsOnly.substring(9, digitsOnly.length >= 11 ? 11 : digitsOnly.length)}';
        }
        return formatted;
      }
    } else {
      // CNPJ: 12.345.678/9012-34
      if (digitsOnly.length >= 2) {
        String formatted = digitsOnly.substring(0, 2);
        if (digitsOnly.length > 2) {
          formatted +=
              '.${digitsOnly.substring(2, digitsOnly.length >= 5 ? 5 : digitsOnly.length)}';
        }
        if (digitsOnly.length > 5) {
          formatted +=
              '.${digitsOnly.substring(5, digitsOnly.length >= 8 ? 8 : digitsOnly.length)}';
        }
        if (digitsOnly.length > 8) {
          formatted +=
              '/${digitsOnly.substring(8, digitsOnly.length >= 12 ? 12 : digitsOnly.length)}';
        }
        if (digitsOnly.length > 12) {
          formatted += '-${digitsOnly.substring(12, 14)}';
        }
        return formatted;
      }
    }
    return text;
  }

  static String formatCep(String text) {
    final digitsOnly = text.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length >= 5) {
      return '${digitsOnly.substring(0, 5)}-${digitsOnly.substring(5, digitsOnly.length >= 8 ? 8 : digitsOnly.length)}';
    }
    return digitsOnly;
  }

  static String formatCro(String text) {
    final digitsOnly = text.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length >= 2) {
      return '${digitsOnly.substring(0, 2)}.${digitsOnly.substring(2, digitsOnly.length >= 5 ? 5 : digitsOnly.length)}';
    }
    return digitsOnly;
  }

  static String formatBankAccount(String text, {bool isAgency = false}) {
    final digitsOnly = text.replaceAll(RegExp(r'[^\d]'), '');
    if (isAgency) {
      // Agência: 1234-5
      if (digitsOnly.length >= 4) {
        return '${digitsOnly.substring(0, 4)}-${digitsOnly.substring(4, digitsOnly.length >= 5 ? 5 : digitsOnly.length)}';
      }
    } else {
      // Conta: 1234567-8
      if (digitsOnly.length >= 7) {
        return '${digitsOnly.substring(0, 7)}-${digitsOnly.substring(7, digitsOnly.length >= 8 ? 8 : digitsOnly.length)}';
      }
    }
    return digitsOnly;
  }

  static String formatCardNumber(String text) {
    final digitsOnly = text.replaceAll(RegExp(r'[^\d]'), '');
    String formatted = '';
    for (int i = 0; i < digitsOnly.length && i < 16; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted += ' ';
      }
      formatted += digitsOnly[i];
    }
    return formatted;
  }
}

class ReembolsoFormUtils {
  static void showErrorSnackbar(BuildContext context, String message) {
    print('Mostrando erro para usuário: $message');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'DETALHES',
          textColor: Colors.white,
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Detalhes do Erro'),
                content: SingleChildScrollView(child: Text(message)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fechar'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  static void showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 50),
              ),
              const SizedBox(height: 20),
              const Text(
                'Sucesso!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Sua solicitação de reembolso foi enviada com sucesso!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Fecha dialog
                    Navigator.of(context).pop(); // Volta para tela anterior
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Continuar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<ImageSource?> showFileSourceBottomSheet(BuildContext context) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle visual
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Selecionar Arquivo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: AppColors.vinhoUltraUniodonto,
                size: 28,
              ),
              title: const Text(
                'Galeria de Fotos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              subtitle: const Text('Escolher arquivo da galeria'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),

            ListTile(
              leading: const Icon(
                Icons.camera_alt,
                color: AppColors.vinhoUltraUniodonto,
                size: 28,
              ),
              title: const Text(
                'Câmera',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              subtitle: const Text('Tirar uma nova foto'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
