import 'package:flutter/material.dart';

class AppColors {
  // Cores baseadas no seu CSS
  static const Color roxoUniodonto = Color(0xFFBF9CFF);
  static const Color pessegoUniodonto = Color(0xFFFF9FAD);
  static const Color cianoUniodonto = Color(0xFF60EBFF);
  static const Color limaUniodonto = Color(0xFFE1FF7B);
  static const Color goiabaUniodonto = Color(0xFF4F4F4F);
  static const Color vinhoMedioUniodonto = Color(0xFFA60069);
  static const Color vinhoUltraUniodonto = Color(0xFF550039);
  static const Color vinhoClaroUniodonto = Color(0xFFBC5688);
  static const Color fundoConteudo = Color(0xFFECF0F1);
  static const Color corTexto = Color(0xFFFFFFFF);
  static const Color hoverLink = Color(0xFFE1FF7B); // mesma que limaUniodonto
  static const Color fundoSidebar = Color(
    0xFFA60069,
  ); // mesma que vinhoMedioUniodonto
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      // Configuração de cores
      primaryColor: AppColors.vinhoMedioUniodonto,
      primaryColorDark: AppColors.vinhoUltraUniodonto,
      primaryColorLight: AppColors.vinhoClaroUniodonto,
      scaffoldBackgroundColor: AppColors.fundoConteudo,
      colorScheme: const ColorScheme.light(
        primary: AppColors.vinhoMedioUniodonto,
        secondary: AppColors.cianoUniodonto,
        surface: Colors.white,
        onPrimary: AppColors.corTexto,
        onSecondary: Colors.black,
        onSurface: Colors.black,
      ),

      // Configuração de texto com letterSpacing consistente
      fontFamily: 'Georama',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Colors.black,
          letterSpacing: 1, // Adicionado
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: Colors.black,
          letterSpacing: 1, // Adicionado
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.black,
          letterSpacing: 1, // Adicionado
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.black,
          letterSpacing: 1, // Adicionado
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black,
          letterSpacing: 1, // Adicionado
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.black,
          letterSpacing: 1, // Adicionado
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black,
          letterSpacing: 1, // Adicionado
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black,
          letterSpacing: 1, // Adicionado
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.black,
          letterSpacing: 1, // Adicionado
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.black,
          letterSpacing: 1, // Adicionado
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.black,
          letterSpacing: 1, // Adicionado
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Colors.black87,
          letterSpacing: 1, // Adicionado
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black,
          letterSpacing: 1, // Adicionado
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.black,
          letterSpacing: 1, // Adicionado
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w400,
          color: Colors.black87,
          letterSpacing: 1, // Adicionado
        ),
      ),

      // Configuração de botões
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.vinhoMedioUniodonto,
          foregroundColor: AppColors.corTexto,
          textStyle: const TextStyle(
            letterSpacing: 1,
            fontFamily: 'Georama',
            fontWeight: FontWeight.w500,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // Configuração de inputs
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.goiabaUniodonto),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.vinhoMedioUniodonto),
        ),
        labelStyle: const TextStyle(
          color: AppColors.goiabaUniodonto,
          letterSpacing: 1, // Adicionado para inputs
        ),
        hintStyle: const TextStyle(
          letterSpacing: 1, // Adicionado para inputs
        ),
      ),

      // Configuração do AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.vinhoMedioUniodonto,
        foregroundColor: AppColors.corTexto,
        titleTextStyle: TextStyle(
          color: AppColors.corTexto,
          fontFamily: 'Georama',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 1, // Adicionado
        ),
      ),

      // Configuração adicional para outros componentes
      chipTheme: const ChipThemeData(labelStyle: TextStyle(letterSpacing: 1)),
      //   cardTheme: const CardTheme(margin: EdgeInsets.all(8)),
    );
  }

  // Tema escuro com letterSpacing consistente
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: AppColors.vinhoMedioUniodonto,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.vinhoMedioUniodonto,
        secondary: AppColors.cianoUniodonto,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(letterSpacing: 1),
        displayMedium: TextStyle(letterSpacing: 1),
        displaySmall: TextStyle(letterSpacing: 1),
        headlineLarge: TextStyle(letterSpacing: 1),
        headlineMedium: TextStyle(letterSpacing: 1),
        headlineSmall: TextStyle(letterSpacing: 1),
        titleLarge: TextStyle(letterSpacing: 1),
        titleMedium: TextStyle(letterSpacing: 1),
        titleSmall: TextStyle(letterSpacing: 1),
        bodyLarge: TextStyle(letterSpacing: 1),
        bodyMedium: TextStyle(letterSpacing: 1),
        bodySmall: TextStyle(letterSpacing: 1),
        labelLarge: TextStyle(letterSpacing: 1),
        labelMedium: TextStyle(letterSpacing: 1),
        labelSmall: TextStyle(letterSpacing: 1),
      ).apply(fontFamily: 'Georama'),
    );
  }
}
