import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

import '../models/boleto_model.dart';
import '../services/boleto_service.dart';
import '../widgets/boleto_card.dart';

import '../../dashboard/views/dashboard_page.dart';

class BoletosView extends StatefulWidget {
  const BoletosView({Key? key}) : super(key: key);

  @override
  _BoletosViewState createState() => _BoletosViewState();
}

class _BoletosViewState extends State<BoletosView> {
  final BoletoService _boletoService = BoletoService();
  final TextEditingController _tokenController = TextEditingController();
  final List<TextEditingController> _digitControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _digitFocusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  String? _chaveConsulta;
  String? _telefoneDoTitular;
  List<Boleto> _boletos = [];
  bool _isLoading = false;

  // Etapas do fluxo: 1-Solicitando Token, 2-Token, 3-Lista, 4-Nenhum Boleto
  int _currentStep = 1;

  @override
  void initState() {
    super.initState();
    _inicializarDados();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    for (var controller in _digitControllers) {
      controller.dispose();
    }
    for (var focusNode in _digitFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _inicializarDados() async {
    setState(() => _isLoading = true);

    // Obter o telefone do titular para exibir na interface
    _telefoneDoTitular = await _boletoService.getTelefoneDoTitular();

    if (_telefoneDoTitular == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dados do beneficiário não encontrados.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Automaticamente solicitar o token
    _solicitarToken();
  }

  void _solicitarToken() async {
    setState(() => _isLoading = true);

    developer.log(
      'Solicitando token automaticamente usando telefone do titular',
      name: 'BoletosView',
    );

    final response = await _boletoService.gerarToken();

    developer.log(
      'Resposta da API (gerarToken): $response',
      name: 'BoletosView',
    );

    setState(() => _isLoading = false);

    if (response['Sucesso'] == true) {
      setState(() {
        _chaveConsulta = response['ChaveConsulta'];
        _currentStep = 2;
      });

      // Limpar campos de código quando solicitar novo token
      for (var controller in _digitControllers) {
        controller.clear();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response['MsgRetorno'] ?? 'Token enviado para $_telefoneDoTitular!',
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      final errorMessage =
          response['MsgRetorno'] ?? 'Ocorreu um erro desconhecido.';
      developer.log(
        'Falha ao solicitar token: $errorMessage',
        name: 'BoletosView',
        error: response,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _buscarBoletos() async {
    final token = _digitControllers.map((c) => c.text).join();

    if (_chaveConsulta == null || token.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira o código de 6 dígitos.'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final boletos = await _boletoService.getBoletos(_chaveConsulta!, token);

    setState(() {
      _boletos = boletos;
      _isLoading = false;
      if (boletos.isNotEmpty) {
        _currentStep = 3;
      } else {
        // Altera para a etapa de "Nenhum boleto encontrado"
        _currentStep = 4;
      }
    });
  }

  void _visualizarBoleto(String idContaReceber) async {
    final token = _digitControllers.map((c) => c.text).join();
    if (_chaveConsulta == null || token.isEmpty) return;

    setState(() => _isLoading = true);
    final pdfBase64 = await _boletoService.getBoletoPdf(
      _chaveConsulta!,
      token,
      idContaReceber,
    );
    setState(() => _isLoading = false);

    if (pdfBase64 != null) {
      final Uint8List pdfBytes = base64Decode(pdfBase64);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Visualizador de Boleto'),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            body: PDFView(pdfData: pdfBytes),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível carregar o boleto.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onDigitChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _digitFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _digitFocusNodes[index - 1].requestFocus();
    }

    // Verificar se todos os dígitos foram preenchidos
    final allFilled = _digitControllers.every((c) => c.text.isNotEmpty);
    if (allFilled) {
      _buscarBoletos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Meus Boletos'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: _currentStep > 2
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    // Se estiver na lista ou na tela de "nenhum encontrado", volta para a tela de token
                    if (_currentStep == 3 || _currentStep == 4) {
                      _currentStep = 2;
                    }
                  });
                },
              )
            : null,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Carregando...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : _buildCurrentStepWidget(),
    );
  }

  void _navigateToDash() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DashboardPage()),
    );
  }

  Widget _buildCurrentStepWidget() {
    switch (_currentStep) {
      case 1:
        return _buildSolicitandoToken();
      case 2:
        return _buildTokenInput();
      case 3:
        return _buildBoletosList();
      case 4:
        return _buildNenhumBoletoEncontrado();
      default:
        return _buildSolicitandoToken();
    }
  }

  Widget _buildSolicitandoToken() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.sms,
              size: 64,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _telefoneDoTitular != null
                ? 'Enviando código de verificação'
                : 'Carregando dados do beneficiário',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          if (_telefoneDoTitular != null)
            Text(
              'Para: $_telefoneDoTitular',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 24),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildTokenInput() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_read,
              size: 64,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Código enviado!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Enviamos um código de 6 dígitos para\n$_telefoneDoTitular',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          const Text(
            'Digite o código abaixo:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24),
          // Campo de 6 dígitos com máscara
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) {
              return Container(
                width: 45,
                height: 55,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: TextField(
                  controller: _digitControllers[index],
                  focusNode: _digitFocusNodes[index],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) => _onDigitChanged(value, index),
                ),
              );
            }),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _solicitarToken,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reenviar'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _buscarBoletos,
                  icon: const Icon(Icons.search),
                  label: const Text('Buscar Boletos'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBoletosList() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              Icon(
                Icons.receipt_long,
                size: 48,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                '${_boletos.length} boleto${_boletos.length != 1 ? 's' : ''} encontrado${_boletos.length != 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _boletos.length,
            itemBuilder: (context, index) {
              final boleto = _boletos[index];
              return BoletoCard(
                boleto: boleto,
                onViewPressed: () => _visualizarBoleto(boleto.idContaReceber),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNenhumBoletoEncontrado() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 24),
          const Text(
            'Nenhum boleto encontrado',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Não há boletos pendentes ou disponíveis para você no momento.',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: _navigateToDash,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Voltar para o Início'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
