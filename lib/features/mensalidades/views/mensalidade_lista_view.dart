import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/mensalidade_model.dart';
import '../../../core/theme/app_theme.dart'; // Mantenha seu import de tema
import '../services/mensalidade_service.dart';
import '../widgets/mensalidade_list_item.dart';

class MensalidadeListaView extends StatefulWidget {
  const MensalidadeListaView({super.key});

  @override
  State<MensalidadeListaView> createState() => _MensalidadeListaViewState();
}

class _MensalidadeListaViewState extends State<MensalidadeListaView> {
  final MensalidadeService _mensalidadeService = MensalidadeService();
  final TextEditingController _searchController = TextEditingController();

  List<Mensalidade> _allMensalidades = [];
  List<Mensalidade> _filteredMensalidades = [];
  String _selectedStatusFilter = 'Todas';
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMensalidades();
    _searchController.addListener(_filterMensalidades);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMensalidades() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final mensalidades = await _mensalidadeService.fetchMensalidades();
      setState(() {
        _allMensalidades = mensalidades;
        _isLoading = false;
        // Aplica o filtro inicial
        _filterMensalidades();
      });
    } on MensalidadeServiceException catch (e) {
      setState(() {
        _errorMessage = e.userFriendlyMessage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro inesperado. Tente novamente mais tarde.';
        _isLoading = false;
      });
    }
  }

  void _filterMensalidades() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredMensalidades = _allMensalidades.where((mensalidade) {
        final matchesSearch =
            query.isEmpty ||
            (mensalidade.idFatura?.toString().contains(query) ?? false) ||
            (mensalidade.strObservacoes?.toLowerCase().contains(query) ??
                false);

        final matchesStatus =
            _selectedStatusFilter == 'Todas' ||
            mensalidade.statusFormatado == _selectedStatusFilter;

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  void _onStatusFilterChanged(String status) {
    setState(() {
      _selectedStatusFilter = status;
    });
    _filterMensalidades();
  }

  Future<void> _onRefresh() async {
    await _loadMensalidades();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Minhas Mensalidades',
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
    );
  }

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
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Pesquisar por fatura, observações...',
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
            if (_allMensalidades.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildStatusFilter('Todas'),
                    _buildStatusFilter('Em Aberto'),
                    _buildStatusFilter('Paga'),
                    _buildStatusFilter('Vencida'),
                    _buildStatusFilter('Cancelada'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${_filteredMensalidades.length} ${_filteredMensalidades.length == 1 ? 'mensalidade encontrada' : 'mensalidades encontradas'}',
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
          side: const BorderSide(
            color: AppColors.vinhoUltraUniodonto,
            width: 1.5,
          ),
        ),
        elevation: 0,
        pressElevation: 2,
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.vinhoUltraUniodonto),
      );
    }
    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }
    if (_filteredMensalidades.isEmpty) {
      return const Center(child: Text('Nenhuma mensalidade encontrada.'));
    }
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.vinhoUltraUniodonto,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _filteredMensalidades.length,
        itemBuilder: (context, index) {
          return MensalidadeListItem(mensalidade: _filteredMensalidades[index]);
        },
      ),
    );
  }
}
