import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/services/auth_provider.dart';
import 'features/auth/views/login_page.dart';
import 'features/dashboard/views/dashboard_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Função para verificar o status do login no SharedPreferences
  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    // Retorna true se a chave 'beneficiario_data' existir
    return prefs.containsKey('beneficiario_data');
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: MaterialApp(
        title: 'Meu App Uniodonto',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        // Usa FutureBuilder para decidir a tela inicial
        home: FutureBuilder<bool>(
          future: _checkLoginStatus(),
          builder: (context, snapshot) {
            // Se o Future estiver carregando, mostra um indicador de progresso
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            // Se o Future retornar true, navega para a DashboardPage
            if (snapshot.hasData && snapshot.data == true) {
              return const DashboardPage();
            } else {
              // Se o Future retornar false, navega para a LoginPage
              return const LoginPage();
            }
          },
        ),
      ),
    );
  }
}
