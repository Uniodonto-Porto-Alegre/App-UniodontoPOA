import 'package:flutter/material.dart';
import 'app_theme.dart';

class AppStyles {
  // Textos
  static TextStyle get titleText {
    return const TextStyle(
      letterSpacing: 1,
      fontFamily: 'Georama',
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    );
  }

  static TextStyle get subtitleText {
    return const TextStyle(
      letterSpacing: 1,
      fontFamily: 'Georama',
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: AppColors.goiabaUniodonto,
    );
  }

  static TextStyle get bodyText {
    return const TextStyle(
      letterSpacing: 1,
      fontFamily: 'Georama',
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Colors.black87,
    );
  }

  static TextStyle get buttonText {
    return const TextStyle(
      letterSpacing: 1,
      fontFamily: 'Georama',
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: AppColors.limaUniodonto,
    );
  }

  // Botões
  static ButtonStyle get primaryButton {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.vinhoMedioUniodonto,
      foregroundColor: AppColors.limaUniodonto,
      textStyle: buttonText,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  static ButtonStyle get secondaryButton {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.cianoUniodonto,
      foregroundColor: Colors.black,
      textStyle: buttonText.copyWith(color: Colors.black),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  // Cards
  static BoxDecoration get cardDecoration {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // Inputs
  static InputDecoration get inputDecoration {
    return const InputDecoration(
      border: OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.vinhoMedioUniodonto),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}
