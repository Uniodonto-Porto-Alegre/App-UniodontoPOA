import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/solicitacao_model.dart';
import '../../../core/theme/app_theme.dart';
import '../services/reembolso_service.dart';
import '../widgets/reembolso_list_item.dart';
// Adicione o import para ReembolsoFormView (ajuste o caminho conforme necessário)
import '../../reembolso-form/views/reembolso_form_view.dart'; // ← IMPORTANTE: Adicione este import

class ReembolsoListaView extends StatefulWidget {
  const ReembolsoListaView({super.key});

  @override
  State<ReembolsoListaView> createState() => _ReembolsoListaViewState();
}

class _ReembolsoListaViewState extends State<ReembolsoListaView> {
  final ReembolsoService _reembolsoService = ReembolsoService();
  final TextEditingController _searchController = TextEditingController();

  List<Solicitacao> _allReembolsos = [];
  List<Solicitacao> _filteredReembolsos = [];
  String _selectedStatusFilter = 'Todos';
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReembolsos();
    _searchController.addListener(_filterReembolsos);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadReembolsos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final reembolsos = await _reembolsoService.fetchReembolsos();
      setState(() {
        _allReembolsos = reembolsos;
        _filteredReembolsos = reembolsos;
        _isLoading = false;
      });
    } on ReembolsoServiceException catch (e) {
      setState(() {
        _errorMessage = e.userFriendlyMessage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro inesperado. Tente novamente.';
        _isLoading = false;
      });
    }
  }

  void _filterReembolsos() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredReembolsos = _allReembolsos.where((solicitacao) {
        final matchesSearch =
            query.isEmpty ||
            solicitacao.numProtocolo.toLowerCase().contains(query) ||
            solicitacao.descricaoResumo.toLowerCase().contains(query) ||
            solicitacao.statusFormatado.toLowerCase().contains(query);

        final matchesStatus =
            _selectedStatusFilter == 'Todos' ||
            solicitacao.statusFormatado == _selectedStatusFilter;

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  void _onStatusFilterChanged(String status) {
    setState(() {
      _selectedStatusFilter = status;
    });
    _filterReembolsos();
  }

  Future<void> _onRefresh() async {
    await _loadReembolsos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Meus Reembolsos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.vinhoUltraUniodonto,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _onRefresh,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(child: _buildContent()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navega para a nova tela de formulário
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ModernReembolsoFormView(),
            ),
          );
        },
        label: const Text('Solicitar Reembolso'),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.vinhoUltraUniodonto,
        foregroundColor: Colors.white,
      ),
    ); // ← FECHAMENTO CORRETO DO SCAFFOLD
  }

  // ... o restante dos métodos permanece igual ...
  Widget _buildSearchAndFilters() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, offset: Offset(0, 2), blurRadius: 4),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Barra de pesquisa moderna
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Pesquisar por protocolo ou descrição...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey[500]),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),

            if (_allReembolsos.isNotEmpty) ...[
              const SizedBox(height: 16),
              // Filtros de status
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildStatusFilter('Todos'),
                    _buildStatusFilter('Encerrada'),
                    _buildStatusFilter('Aberta'),
                    _buildStatusFilter('Em Processamento'),
                    _buildStatusFilter('Cancelada'),
                  ],
                ),
              ),

              // Contador de resultados
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${_filteredReembolsos.length} ${_filteredReembolsos.length == 1 ? 'solicitação encontrada' : 'solicitações encontradas'}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFilter(String status) {
    final isSelected = _selectedStatusFilter == status;

    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: FilterChip(
        label: Text(
          status,
          style: TextStyle(
            color: isSelected
                ? AppColors.vinhoUltraUniodonto
                : AppColors.vinhoUltraUniodonto,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => _onStatusFilterChanged(status),
        backgroundColor: Colors.transparent,
        selectedColor: AppColors.limaUniodonto,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.vinhoUltraUniodonto, width: 1.5),
        ),
        elevation: 0,
        pressElevation: 2,
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    if (_filteredReembolsos.isEmpty) {
      return _buildEmptyWidget();
    }

    return _buildReembolsosList();
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.vinhoUltraUniodonto,
            strokeWidth: 3,
          ),
          SizedBox(height: 20),
          Text(
            'Carregando suas solicitações...',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Ops! Algo deu errado',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadReembolsos,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.vinhoUltraUniodonto,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    final hasSearch =
        _searchController.text.isNotEmpty || _selectedStatusFilter != 'Todos';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                hasSearch ? Icons.search_off : Icons.receipt_long,
                size: 64,
                color: Colors.blue[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              hasSearch
                  ? 'Nenhum resultado encontrado'
                  : 'Nenhuma solicitação encontrada',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              hasSearch
                  ? 'Tente ajustar os filtros ou termos de pesquisa'
                  : 'Você ainda não possui solicitações de reembolso.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            if (hasSearch) ...[
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: () {
                  _searchController.clear();
                  _onStatusFilterChanged('Todos');
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('Limpar Filtros'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.vinhoUltraUniodonto,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReembolsosList() {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.vinhoUltraUniodonto,
      backgroundColor: Colors.white,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _filteredReembolsos.length,
        itemBuilder: (context, index) {
          return ReembolsoListItem(solicitacao: _filteredReembolsos[index]);
        },
      ),
    );
  }
}
