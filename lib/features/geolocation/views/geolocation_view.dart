import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/theme/app_theme.dart';
import '../models/provider_model.dart';
import '../services/geolocation_service.dart';
import '../services/cep_service.dart';
import '../widgets/map_widget.dart';
import '../widgets/provider_card_widget.dart';

class GeolocationView extends StatefulWidget {
  const GeolocationView({Key? key}) : super(key: key);

  @override
  State<GeolocationView> createState() => _GeolocationViewState();
}

class _GeolocationViewState extends State<GeolocationView>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  String? _errorMessage;
  Position? _currentPosition;
  Map<String, double>? _cepCoordinates;
  List<ProviderModel> _providers = [];

  // Controllers para os campos de entrada
  final TextEditingController _cepController = TextEditingController();
  bool _isUsingCep = false;
  String? _currentAddress;

  // Controle da expansão
  bool _isSearchOptionsExpanded = true;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Inicia expandido
    _animationController.forward();
  }

  @override
  void dispose() {
    _cepController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSearchOptions() {
    setState(() {
      _isSearchOptionsExpanded = !_isSearchOptionsExpanded;
      if (_isSearchOptionsExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  /// Busca prestadores usando localização atual do GPS
  Future<void> _searchNearbyProvidersGPS() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isUsingCep = false;
      _cepCoordinates = null;
      _currentAddress = null;
    });

    try {
      final position = await GeolocationService.getCurrentLocation();
      if (!mounted) return;

      if (position == null) {
        throw Exception(
          'Não foi possível obter sua localização. Verifique as permissões.',
        );
      }

      setState(() {
        _currentPosition = position;
      });

      final providers = await GeolocationService.getProvidersNearby(
        position.latitude,
        position.longitude,
      );
      if (!mounted) return;

      setState(() {
        _providers = providers;
        if (providers.isEmpty) {
          _errorMessage = 'Nenhum prestador encontrado num raio de 5km.';
        }
      });

      // Colapsa automaticamente após a busca bem-sucedida
      if (_providers.isNotEmpty) {
        _toggleSearchOptions();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll("Exception: ", "");
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Busca prestadores usando CEP
  Future<void> _searchNearbyProvidersCEP() async {
    if (!mounted) return;

    final cep = _cepController.text.trim();
    if (cep.isEmpty) {
      _showErrorMessage('Por favor, informe um CEP');
      return;
    }

    if (!GeolocationService.isValidCep(cep)) {
      _showErrorMessage('CEP inválido. Use o formato 00000-000');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isUsingCep = true;
      _currentPosition = null;
    });

    try {
      // Primeiro busca o endereço do CEP para mostrar ao usuário
      final address = await CepService.getAddressByCep(cep);
      if (!mounted) return;

      if (address != null) {
        setState(() {
          _currentAddress =
              '${address.logradouro}, ${address.bairro}, ${address.localidade} - ${address.uf}';
        });
      }

      // Busca prestadores próximos ao CEP
      final providers = await GeolocationService.getProvidersNearbyCep(cep);
      if (!mounted) return;

      // Obtem as coordenadas para o mapa
      final coordinates = await GeolocationService.getCoordinatesFromCep(cep);
      if (!mounted) return;

      setState(() {
        _providers = providers;
        _cepCoordinates = coordinates;
        if (providers.isEmpty) {
          _errorMessage =
              'Nenhum prestador encontrado num raio de 5km do CEP informado.';
        }
      });

      // Colapsa automaticamente após a busca bem-sucedida
      if (_providers.isNotEmpty) {
        _toggleSearchOptions();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll("Exception: ", "");
        _cepCoordinates = null;
        _currentAddress = null;
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
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
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: _buildContent(),
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
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            ],
          ),
          const SizedBox(height: 5),
          const Text(
            'Dentistas Próximos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Encontre especialistas por localização ou CEP.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildCollapsibleSearchOptions(),
        if (_isLoading)
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.vinhoUltraUniodonto,
              ),
            ),
          )
        else ...[
          _buildStatusInfo(),
          Expanded(
            child: _providers.isEmpty ? _buildEmptyState() : _buildMapView(),
          ),
        ],
      ],
    );
  }

  Widget _buildCollapsibleSearchOptions() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header sempre visível com botão de toggle
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _toggleSearchOptions,
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      color: AppColors.vinhoUltraUniodonto,
                      size: 24,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Opções de Busca',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.vinhoUltraUniodonto,
                            ),
                          ),
                          if (!_isSearchOptionsExpanded &&
                              _providers.isNotEmpty)
                            Text(
                              _isUsingCep
                                  ? 'Busca por CEP ativa'
                                  : 'Busca por localização ativa',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isSearchOptionsExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(
                        Icons.expand_more,
                        color: AppColors.vinhoMedioUniodonto,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Conteúdo expansível
          SizeTransition(
            sizeFactor: _expandAnimation,
            axisAlignment: -1,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 0),
                  const SizedBox(height: 16),

                  // Opção: Usar localização atual
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _searchNearbyProvidersGPS,
                      icon: const Icon(Icons.my_location),
                      label: const Text('Usar Minha Localização'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.vinhoMedioUniodonto,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Divisor com "OU"
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OU',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Campo de CEP
                  TextFormField(
                    controller: _cepController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(8),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Digite seu CEP',
                      hintText: '00000000',
                      prefixIcon: const Icon(Icons.location_on),
                      suffixIcon: _cepController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _cepController.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.clear),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.vinhoMedioUniodonto,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                      // Auto-formatação do CEP
                      if (value.length == 8) {
                        setState(() {
                          _cepController.value = TextEditingValue(
                            text: GeolocationService.formatCep(value),
                            selection: const TextSelection.collapsed(offset: 9),
                          );
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // Botão de busca por CEP
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _searchNearbyProvidersCEP,
                      icon: const Icon(Icons.search),
                      label: const Text('Buscar por CEP'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.vinhoMedioUniodonto,
                        side: const BorderSide(
                          color: AppColors.vinhoMedioUniodonto,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusInfo() {
    if (_errorMessage != null && _providers.isEmpty) {
      return _buildInfoContainer(
        message: _errorMessage!,
        icon: Icons.error_outline,
        color: Colors.red.shade700,
      );
    }

    if (!_isLoading && _providers.isNotEmpty) {
      return _buildInfoContainer(
        message: '${_providers.length} prestadores encontrados',
        icon: Icons.check_circle_outline,
        color: Colors.green.shade700,
        showExpandButton: true,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildInfoContainer({
    required String message,
    required IconData icon,
    required Color color,
    bool showExpandButton = false,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 16, 8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 1, 2, 1),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (showExpandButton && !_isSearchOptionsExpanded)
              TextButton.icon(
                onPressed: _toggleSearchOptions,
                icon: const Icon(
                  Icons.edit_location_alt,
                  size: 16,
                  color: AppColors.vinhoMedioUniodonto,
                ),
                label: const Text(
                  'Alterar',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.vinhoMedioUniodonto,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _errorMessage != null
                  ? Icons.error_outline
                  : Icons.location_off_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage != null ? 'Erro na busca' : 'Nenhum resultado',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ??
                  'Use uma das opções acima para buscar prestadores próximos.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView() {
    double latitude, longitude;

    if (_isUsingCep && _cepCoordinates != null) {
      latitude = _cepCoordinates!['latitude']!;
      longitude = _cepCoordinates!['longitude']!;
    } else if (_currentPosition != null) {
      latitude = _currentPosition!.latitude;
      longitude = _currentPosition!.longitude;
    } else {
      return const Center(
        child: Text('Localização não disponível para o mapa'),
      );
    }

    return MapWidget(
      userLatitude: latitude,
      userLongitude: longitude,
      providers: _providers,
      onProviderTap: _showProviderBottomSheet,
      isUsingCep: _isUsingCep,
      addressInfo: _currentAddress,
    );
  }

  void _showProviderBottomSheet(ProviderModel provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ProviderCardWidget(provider: provider),
        ),
      ),
    );
  }
}
