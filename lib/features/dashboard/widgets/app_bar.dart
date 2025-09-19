import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/theme/app_theme.dart';
import '../models/user_model.dart';

class DashboardAppBar extends StatefulWidget implements PreferredSizeWidget {
  final User user;
  const DashboardAppBar({Key? key, required this.user}) : super(key: key);

  @override
  State<DashboardAppBar> createState() => _DashboardAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(140);
}

class _DashboardAppBarState extends State<DashboardAppBar> {
  String? _profileImageBase64;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  // Carrega a imagem salva do SharedPreferences
  Future<void> _loadProfileImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final imageBase64 = prefs.getString('profile_image_${widget.user.id}');
      if (imageBase64 != null && mounted) {
        setState(() {
          _profileImageBase64 = imageBase64;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar imagem do perfil: $e');
    }
  }

  // Salva a imagem no SharedPreferences
  Future<void> _saveProfileImage(String base64Image) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_${widget.user.id}', base64Image);
    } catch (e) {
      debugPrint('Erro ao salvar imagem do perfil: $e');
    }
  }

  // Remove a imagem do SharedPreferences
  Future<void> _removeProfileImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('profile_image_${widget.user.id}');
      if (mounted) {
        setState(() {
          _profileImageBase64 = null;
        });
      }
    } catch (e) {
      debugPrint('Erro ao remover imagem do perfil: $e');
    }
  }

  // Converte XFile para base64 (compatível com Web e Mobile)
  Future<String?> _convertImageToBase64(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      debugPrint('Erro ao converter imagem para base64: $e');
      return null;
    }
  }

  // Seleciona imagem da galeria ou câmera
  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() => _isLoading = true);

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        final String? base64Image = await _convertImageToBase64(image);

        if (base64Image != null) {
          await _saveProfileImage(base64Image);
          if (mounted) {
            setState(() {
              _profileImageBase64 = base64Image;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Erro ao selecionar imagem: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao selecionar imagem. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Mostra opções para selecionar foto
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle visual
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Escolher foto do perfil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Georama',
                  ),
                ),
              ),

              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: AppColors.vinhoMedioUniodonto,
                ),
                title: const Text(
                  'Tirar foto',
                  style: TextStyle(fontFamily: 'Georama'),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppColors.vinhoMedioUniodonto,
                ),
                title: const Text(
                  'Escolher da galeria',
                  style: TextStyle(fontFamily: 'Georama'),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),

              if (_profileImageBase64 != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Remover foto',
                    style: TextStyle(fontFamily: 'Georama'),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _removeProfileImage();
                  },
                ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // Constrói o widget do avatar
  Widget _buildAvatar(bool isVerySmallScreen) {
    ImageProvider? imageProvider;

    // Prioriza a imagem local (base64) sobre a URL do usuário
    if (_profileImageBase64 != null) {
      try {
        final bytes = base64Decode(_profileImageBase64!);
        imageProvider = MemoryImage(bytes);
      } catch (e) {
        debugPrint('Erro ao decodificar imagem base64: $e');
      }
    } else if (widget.user.photoUrl != null) {
      imageProvider = NetworkImage(widget.user.photoUrl!);
    }

    return GestureDetector(
      onTap: _showImagePickerOptions,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            CircleAvatar(
              radius: isVerySmallScreen ? 25 : 30,
              backgroundColor: Colors.white,
              child: _isLoading
                  ? SizedBox(
                      width: isVerySmallScreen ? 20 : 24,
                      height: isVerySmallScreen ? 20 : 24,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.vinhoMedioUniodonto,
                      ),
                    )
                  : CircleAvatar(
                      radius: isVerySmallScreen ? 22 : 27,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: imageProvider,
                      child: imageProvider == null
                          ? Icon(
                              Icons.person_rounded,
                              size: isVerySmallScreen ? 30 : 36,
                              color: AppColors.vinhoMedioUniodonto,
                            )
                          : null,
                    ),
            ),

            // Indicador de status online
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: isVerySmallScreen ? 12 : 16,
                height: isVerySmallScreen ? 12 : 16,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: isVerySmallScreen ? 2 : 3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.vinhoUltraUniodonto,
            AppColors.vinhoMedioUniodonto,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.vinhoMedioUniodonto.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxWidth < 400;
              final isVerySmallScreen = constraints.maxWidth < 350;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Primeira linha - Avatar e info do usuário + ações
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar com funcionalidade de seleção
                      _buildAvatar(isVerySmallScreen),

                      const SizedBox(width: 12),

                      // Informações do usuário
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Saudação
                            Text(
                              _getGreeting(),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: isVerySmallScreen ? 12 : 14,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Georama',
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 4),
                            // Nome do usuário
                            Text(
                              widget.user.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isVerySmallScreen ? 16 : 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Georama',
                                letterSpacing: -0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),

                      // Botões de ação
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Segunda linha - Plano e informações extras
                  Row(
                    children: [
                      // Badge do plano
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_user_outlined,
                                color: Colors.white,
                                size: isSmallScreen ? 14 : 16,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  widget.user.plan,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isSmallScreen ? 10 : 12,
                                    fontFamily: 'Georama',
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Bom dia!';
    } else if (hour < 18) {
      return 'Boa tarde!';
    } else {
      return 'Boa noite!';
    }
  }
}
