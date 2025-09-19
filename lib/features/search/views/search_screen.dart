import 'package:flutter/material.dart';
import '../models/prestador_model.dart';
import '../services/prestador_service.dart';
import '../widgets/prestador_list_item.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  final PrestadorService _prestadorService = PrestadorService();
  final ScrollController _scrollController = ScrollController();

  // Controladores para os campos de texto
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _croController = TextEditingController();
  final TextEditingController _areaAtuacaoController = TextEditingController();

  // Listas para os resultados e filtros
  List<Prestador> _prestadores = [];
  List<String> _cidades = [];
  List<String> _bairros = [];

  // Variáveis de estado
  String? _selectedEstado;
  String? _selectedCidade;
  String? _selectedBairro;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  Pagination? _pagination;

  // Controladores de animação
  late AnimationController _mainAnimationController;
  late AnimationController _headerController;
  late AnimationController _buttonController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _headerSlideAnimation;
  late Animation<double> _buttonScaleAnimation;

  // Mapeamento de estados (sigla -> nome completo)
  final Map<String, String> _estadosMap = {
    'AC': 'Acre',
    'AL': 'Alagoas',
    'AP': 'Amapá',
    'AM': 'Amazonas',
    'BA': 'Bahia',
    'CE': 'Ceará',
    'DF': 'Distrito Federal',
    'ES': 'Espírito Santo',
    'GO': 'Goiás',
    'MA': 'Maranhão',
    'MT': 'Mato Grosso',
    'MS': 'Mato Grosso do Sul',
    'MG': 'Minas Gerais',
    'PA': 'Pará',
    'PB': 'Paraíba',
    'PR': 'Paraná',
    'PE': 'Pernambuco',
    'PI': 'Piauí',
    'RJ': 'Rio de Janeiro',
    'RN': 'Rio Grande do Norte',
    'RS': 'Rio Grande do Sul',
    'RO': 'Rondônia',
    'RR': 'Roraima',
    'SC': 'Santa Catarina',
    'SP': 'São Paulo',
    'SE': 'Sergipe',
    'TO': 'Tocantins',
  };

  // Lista de siglas de estados (para uso interno da API)
  final List<String> _estadosSiglas = [
    'AC',
    'AL',
    'AP',
    'AM',
    'BA',
    'CE',
    'DF',
    'ES',
    'GO',
    'MA',
    'MT',
    'MS',
    'MG',
    'PA',
    'PB',
    'PR',
    'PE',
    'PI',
    'RJ',
    'RN',
    'RS',
    'RO',
    'RR',
    'SC',
    'SP',
    'SE',
    'TO',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeScrollListener();
  }

  void _initializeAnimations() {
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainAnimationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _mainAnimationController,
            curve: Curves.elasticOut,
          ),
        );

    _headerSlideAnimation = Tween<double>(begin: -100.0, end: 0.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.elasticOut),
    );

    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );

    _headerController.forward();
    _mainAnimationController.forward();
  }

  void _initializeScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          _hasMore &&
          !_isLoadingMore &&
          _prestadores.isNotEmpty) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nomeController.dispose();
    _croController.dispose();
    _areaAtuacaoController.dispose();
    _mainAnimationController.dispose();
    _headerController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  // Função para capitalizar a primeira letra de cada palavra
  String _capitalizeCityName(String cityName) {
    if (cityName.isEmpty) return cityName;

    return cityName
        .toLowerCase()
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }

  Future<void> _search() async {
    HapticFeedback.lightImpact();

    setState(() {
      _isLoading = true;
      _prestadores.clear();
      _currentPage = 1;
      _hasMore = true;
    });

    try {
      final response = await _prestadorService.fetchPrestadores(
        page: _currentPage,
        estado: _selectedEstado ?? '',
        cidade: _selectedCidade ?? '',
        bairro: _selectedBairro ?? '',
        nome: _nomeController.text,
        cro: _croController.text,
        areaDeAtuacao: _areaAtuacaoController.text,
      );

      setState(() {
        _prestadores = response.data;
        _pagination = response.pagination;
        _hasMore = response.data.isNotEmpty && !(_pagination?.nolimit ?? true);
      });
    } catch (e) {
      _showErrorSnackBar('Erro ao buscar prestadores: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    try {
      final response = await _prestadorService.fetchPrestadores(
        page: _currentPage,
        estado: _selectedEstado ?? '',
        cidade: _selectedCidade ?? '',
        bairro: _selectedBairro ?? '',
        nome: _nomeController.text,
        cro: _croController.text,
        areaDeAtuacao: _areaAtuacaoController.text,
      );

      setState(() {
        _prestadores.addAll(response.data);
        _pagination = response.pagination;
        _hasMore = response.data.isNotEmpty;
      });
    } catch (e) {
      _showErrorSnackBar('Erro ao carregar mais: $e');
      setState(() {
        _currentPage--;
      });
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _updateCidades(String estadoSigla) async {
    setState(() {
      _cidades = [];
      _bairros = [];
      _selectedCidade = null;
      _selectedBairro = null;
    });

    try {
      final allPrestadores = await _prestadorService.fetchAllPrestadores(
        estado: estadoSigla,
      );
      final cidades = allPrestadores
          .map((p) => p.cidade ?? '')
          .where((c) => c.isNotEmpty)
          .toSet()
          .toList();

      // Capitaliza os nomes das cidades e ordena
      final cidadesCapitalizadas = cidades
          .map((cidade) => _capitalizeCityName(cidade))
          .toSet()
          .toList();

      cidadesCapitalizadas.sort();

      setState(() {
        _cidades = cidadesCapitalizadas;
      });
    } catch (e) {
      _showErrorSnackBar('Erro ao carregar cidades: $e');
    }
  }

  Future<void> _updateBairros(String cidade) async {
    setState(() {
      _bairros = [];
      _selectedBairro = null;
    });

    try {
      final allPrestadores = await _prestadorService.fetchAllPrestadores(
        estado: _selectedEstado!,
        cidade: cidade.toLowerCase(), // Envia em lowercase para a API
      );
      final bairros = allPrestadores
          .map((p) => p.bairro ?? '')
          .where((b) => b.isNotEmpty)
          .toSet()
          .toList();

      // Capitaliza os nomes dos bairros e ordena
      final bairrosCapitalizados = bairros
          .map((bairro) => _capitalizeCityName(bairro))
          .toSet()
          .toList();

      bairrosCapitalizados.sort();

      setState(() {
        _bairros = bairrosCapitalizados;
      });
    } catch (e) {
      _showErrorSnackBar('Erro ao carregar bairros: $e');
    }
  }

  void _clearForm() {
    setState(() {
      _nomeController.clear();
      _croController.clear();
      _areaAtuacaoController.clear();
      _selectedEstado = null;
      _selectedCidade = null;
      _selectedBairro = null;
      _cidades.clear();
      _bairros.clear();
      _prestadores.clear();
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(20),
        elevation: 8,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.vinhoUltraUniodonto,
              AppColors.vinhoMedioUniodonto,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: _buildScrollableContent(),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _headerSlideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _headerSlideAnimation.value),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Busca',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Encontre seu Dentista',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Localize profissionais credenciados próximos a você',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScrollableContent() {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _buildSearchForm(),
          ),
        ),
        if (_isLoading)
          SliverToBoxAdapter(child: _buildLoadingIndicator())
        else if (_prestadores.isNotEmpty)
          _buildResultsSliver()
        else if (_prestadores.isEmpty && !_isLoading)
          SliverToBoxAdapter(child: _buildEmptyState()),
      ],
    );
  }

  Widget _buildSearchForm() {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.vinhoUltraUniodonto.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Localização', Icons.location_on_rounded),
            const SizedBox(height: 16),

            _buildModernEstadoDropdown(),
            const SizedBox(height: 16),

            _buildModernCidadeDropdown(),
            const SizedBox(height: 16),

            _buildModernBairroDropdown(),

            const SizedBox(height: 32),

            _buildSectionTitle('Dados do Profissional', Icons.person_rounded),
            const SizedBox(height: 16),

            _buildModernTextField(
              _nomeController,
              'Nome do Prestador',
              Icons.person_rounded,
            ),
            const SizedBox(height: 16),

            _buildModernTextField(
              _croController,
              'CRO',
              Icons.badge_rounded,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            _buildModernTextField(
              _areaAtuacaoController,
              'Área de Atuação',
              Icons.medical_services_rounded,
            ),

            const SizedBox(height: 32),

            _buildActionButtons(),

            if (_prestadores.isNotEmpty || _isLoading) ...[
              const SizedBox(height: 32),
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.vinhoUltraUniodonto.withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildResultsHeader(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.vinhoUltraUniodonto.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.vinhoUltraUniodonto, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildModernTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.vinhoUltraUniodonto.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF2D3748),
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.vinhoUltraUniodonto.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.vinhoUltraUniodonto, size: 20),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          floatingLabelStyle: const TextStyle(
            color: AppColors.vinhoUltraUniodonto,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Dropdown personalizado para Estados
  Widget _buildModernEstadoDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.vinhoUltraUniodonto.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedEstado,
        hint: Text(
          'Estado',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        isExpanded: true,
        onChanged: (String? newValue) {
          setState(() {
            _selectedEstado = newValue;
            if (newValue != null) _updateCidades(newValue);
          });
        },
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.vinhoUltraUniodonto,
        ),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF2D3748),
        ),
        items: _estadosSiglas.map<DropdownMenuItem<String>>((String sigla) {
          return DropdownMenuItem<String>(
            value: sigla,
            child: Text(_estadosMap[sigla] ?? sigla), // Exibe nome completo
          );
        }).toList(),
        decoration: InputDecoration(
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.vinhoUltraUniodonto.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.map_rounded,
              color: AppColors.vinhoUltraUniodonto,
              size: 20,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
        ),
      ),
    );
  }

  // Dropdown personalizado para Cidades
  Widget _buildModernCidadeDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.vinhoUltraUniodonto.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedCidade,
        hint: Text(
          'Cidade',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        isExpanded: true,
        onChanged: _cidades.isEmpty
            ? null
            : (String? newValue) {
                setState(() {
                  _selectedCidade = newValue;
                  if (newValue != null) _updateBairros(newValue);
                });
              },
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.vinhoUltraUniodonto,
        ),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF2D3748),
        ),
        items: _cidades.map<DropdownMenuItem<String>>((String cidade) {
          return DropdownMenuItem<String>(
            value: cidade,
            child: Text(cidade), // Já capitalizado
          );
        }).toList(),
        decoration: InputDecoration(
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.vinhoUltraUniodonto.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.location_city_rounded,
              color: AppColors.vinhoUltraUniodonto,
              size: 20,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
        ),
      ),
    );
  }

  // Dropdown personalizado para Bairros
  Widget _buildModernBairroDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.vinhoUltraUniodonto.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedBairro,
        hint: Text(
          'Bairro',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        isExpanded: true,
        onChanged: _bairros.isEmpty
            ? null
            : (String? newValue) {
                setState(() => _selectedBairro = newValue);
              },
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.vinhoUltraUniodonto,
        ),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF2D3748),
        ),
        items: _bairros.map<DropdownMenuItem<String>>((String bairro) {
          return DropdownMenuItem<String>(
            value: bairro,
            child: Text(bairro), // Já capitalizado
          );
        }).toList(),
        decoration: InputDecoration(
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.vinhoUltraUniodonto.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.home_work_rounded,
              color: AppColors.vinhoUltraUniodonto,
              size: 20,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return AnimatedBuilder(
      animation: _buttonScaleAnimation,
      builder: (context, child) {
        return Column(
          children: [
            GestureDetector(
              onTapDown: (_) => _buttonController.forward(),
              onTapUp: (_) => _buttonController.reverse(),
              onTapCancel: () => _buttonController.reverse(),
              onTap: _clearForm,
              child: Transform.scale(
                scale: _buttonScaleAnimation.value,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.vinhoUltraUniodonto.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.clear_rounded,
                        color: AppColors.vinhoUltraUniodonto,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Limpar Filtros',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.vinhoUltraUniodonto,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTapDown: (_) => _buttonController.forward(),
              onTapUp: (_) => _buttonController.reverse(),
              onTapCancel: () => _buttonController.reverse(),
              onTap: _search,
              child: Transform.scale(
                scale: _buttonScaleAnimation.value,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.vinhoUltraUniodonto,
                        AppColors.vinhoMedioUniodonto,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.vinhoMedioUniodonto.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 12),
                      Text(
                        'Pesquisar Dentistas',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResultsHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.search_rounded,
            color: Colors.green,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Resultados da Pesquisa',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
            letterSpacing: -0.3,
          ),
        ),
        const Spacer(),
        if (_prestadores.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.vinhoUltraUniodonto.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_prestadores.length} encontrado${_prestadores.length > 1 ? 's' : ''}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.vinhoUltraUniodonto,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.vinhoUltraUniodonto,
              ),
              strokeWidth: 3,
            ),
            SizedBox(height: 20),
            Text(
              'Buscando dentistas...',
              style: TextStyle(
                color: AppColors.vinhoUltraUniodonto,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSliver() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index == _prestadores.length) {
          return _isLoadingMore
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.vinhoMedioUniodonto,
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink();
        }

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
                child: PrestadorListItem(prestador: _prestadores[index]),
              ),
            );
          },
        );
      }, childCount: _prestadores.length + (_isLoadingMore ? 1 : 0)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.vinhoUltraUniodonto.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 64,
                color: AppColors.vinhoMedioUniodonto,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nenhum dentista encontrado',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tente ajustar os filtros de pesquisa ou use termos diferentes para encontrar o profissional ideal.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
