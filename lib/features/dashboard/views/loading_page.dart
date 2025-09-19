import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/dashboard_service.dart';
import 'dashboard_page.dart'; // Importe sua DashboardPage
import '../../auth/views/login_page.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    _loadAndNavigate();
  }

  Future<void> _loadAndNavigate() async {
    try {
      // Obtém a instância do SharedPreferences.
      final prefs = await SharedPreferences.getInstance();
      final String? storedCpf = prefs.getString('user_cpf');

      // Se o CPF não estiver armazenado, navega para a tela de login.
      if (storedCpf == null || storedCpf.isEmpty) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
        return;
      }

      // Se o CPF estiver armazenado, tenta carregar os dados do dashboard.
      await DashboardService.loadDashboardData();

      // Se os dados foram carregados com sucesso, navega para o Dashboard.
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardPage()),
        );
      }
    } catch (e) {
      // Se ocorrer um erro ao carregar os dados (por exemplo, falha na API),
      // exibe a mensagem e navega para a tela de login.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao carregar os dados: ${e.toString()}. Redirecionando para o login.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        await Future.delayed(const Duration(seconds: 2));

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: Center(child: CircularProgressIndicator(color: Colors.purple)),
    );
  }
}
