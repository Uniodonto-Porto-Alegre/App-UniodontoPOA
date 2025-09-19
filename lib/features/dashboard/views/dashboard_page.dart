import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../widgets/app_bar.dart';
import '../widgets/bottom_navigation.dart';
import '../../../core/theme/app_theme.dart';
import '../../card/views/card_selection_screen.dart';
import '../widgets/dashboard_cards.dart';
import '../../feed/views/feed_page.dart';
import '../../config/views/config_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  // A variável _user agora pode ser nula inicialmente
  User? _user;

  // A lista de páginas será inicializada depois que o usuário for carregado
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Carrega os dados do usuário do SharedPreferences e atualiza a UI.
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userDataString = prefs.getString('beneficiario_data');

    if (userDataString != null && userDataString.isNotEmpty) {
      final List<dynamic> beneficiaries = jsonDecode(userDataString);
      if (beneficiaries.isNotEmpty) {
        // Pega o primeiro usuário da lista (o usuário logado)
        final firstUserJson = beneficiaries.first as Map<String, dynamic>;

        // Usa o factory constructor para criar o objeto User
        final loadedUser = User.fromJson(firstUserJson);

        // Atualiza o estado com o usuário real
        setState(() {
          _user = loadedUser;
          // Inicializa a lista de páginas aqui, com o usuário real
          _pages = [
            DashboardMainContent(onCardTap: _onCardTap),
            FeedPage(),
            ConfigPage(
              user: _user!,
            ), // Agora temos certeza que _user não é nulo
          ];
        });
      }
    } else {
      // Caso de erro: se os dados não forem encontrados, use o mock ou trate o erro
      setState(() {
        _user = User.mockUser;
        _pages = [
          DashboardMainContent(onCardTap: _onCardTap),
          FeedPage(),
          ConfigPage(user: _user!),
        ];
      });
    }
  }

  void _onCardTap(String cardName) {
    // ... seu código _onCardTap não muda ...
    if (cardName == 'Carteirinha') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CardSelectionScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Acessando $cardName'),
          duration: const Duration(seconds: 1),
          backgroundColor: AppColors.vinhoMedioUniodonto,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    // Enquanto _user for nulo, mostre um indicador de carregamento.
    // Isso acontece muito rápido, pois é uma leitura de disco, não de rede.
    if (_user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.vinhoMedioUniodonto,
          ),
        ),
      );
    }

    // Quando _user já foi carregado, construa a tela normal.
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 240, 240),
      appBar: DashboardAppBar(
        user: _user!,
      ), // Passa o usuário real para a AppBar
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: UltraModernBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
