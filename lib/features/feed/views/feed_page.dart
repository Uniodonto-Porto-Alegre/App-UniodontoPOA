import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/comunicado_model.dart';
import '../services/feed_service.dart';

// Mock User class para desenvolvimento
class MockUser {
  static final mockUser = MockUser();

  final String nome = 'João Silva';
  final String email = 'joao.silva@email.com';
  final String avatarUrl = '';

  MockUser();
}

class FeedPage extends StatefulWidget {
  const FeedPage({Key? key}) : super(key: key);

  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  //final MockUser _user = MockUser.mockUser;
  bool _isLoading = false;
  List<Comunicado> _comunicados = [];

  @override
  void initState() {
    super.initState();
    _loadComunicados();
  }

  Future<void> _loadComunicados() async {
    setState(() => _isLoading = true);
    try {
      final comunicados = await FeedService.getComunicados();
      setState(() => _comunicados = comunicados);
    } catch (e) {
      // Tratar erro
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onComunicadoTap(Comunicado comunicado) {
    // Marcar como lido e mostrar detalhes
    setState(() {
      comunicado.isLido = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Visualizando: ${comunicado.titulo}'),
        duration: const Duration(seconds: 1),
        backgroundColor: AppColors.vinhoMedioUniodonto,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _onRefresh() async {
    await _loadComunicados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.vinhoMedioUniodonto,
              ),
            )
          : RefreshIndicator(
              color: AppColors.vinhoMedioUniodonto,
              backgroundColor: Colors.white,
              onRefresh: _onRefresh,
              child: _buildComunicadosList(),
            ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      title: const Text(
        'Comunicados',
        style: TextStyle(
          fontFamily: 'Georama',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.vinhoMedioUniodonto,
        ),
      ),
      centerTitle: true,
      leading: Container(margin: const EdgeInsets.all(8)),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: Colors.transparent,
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildComunicadosList() {
    if (_comunicados.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.announcement_rounded,
              size: 64,
              color: AppColors.goiabaUniodonto.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum comunicado disponível',
              style: TextStyle(
                fontFamily: 'Georama',
                fontSize: 16,
                color: AppColors.goiabaUniodonto.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _comunicados.length,
      itemBuilder: (context, index) {
        final comunicado = _comunicados[index];
        return _buildComunicadoCard(comunicado);
      },
    );
  }

  Widget _buildComunicadoCard(Comunicado comunicado) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => _onComunicadoTap(comunicado),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header com categoria e data
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoriaColor(
                          comunicado.categoria,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        comunicado.categoria,
                        style: TextStyle(
                          fontFamily: 'Georama',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getCategoriaColor(comunicado.categoria),
                        ),
                      ),
                    ),
                    Text(
                      _formatDate(comunicado.data),
                      style: TextStyle(
                        fontFamily: 'Georama',
                        fontSize: 12,
                        color: AppColors.goiabaUniodonto.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Título
                Text(
                  comunicado.titulo,
                  style: const TextStyle(
                    fontFamily: 'Georama',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.vinhoMedioUniodonto,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 12),

                // Conteúdo
                Text(
                  comunicado.conteudo,
                  style: TextStyle(
                    fontFamily: 'Georama',
                    fontSize: 14,
                    color: AppColors.goiabaUniodonto.withOpacity(0.8),
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 16),

                // Footer com indicador de não lido
                Row(
                  children: [
                    if (!comunicado.isLido)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.vinhoMedioUniodonto,
                          shape: BoxShape.circle,
                        ),
                      ),
                    const Spacer(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoriaColor(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'urgente':
        return Colors.red;
      case 'manutenção':
        return Colors.orange;
      case 'atualização':
        return AppColors.vinhoMedioUniodonto;
      case 'novidade':
        return Colors.green;
      case 'saúde':
        return Colors.blue;
      default:
        return AppColors.goiabaUniodonto;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h atrás';
    } else {
      return 'Agora';
    }
  }
}
