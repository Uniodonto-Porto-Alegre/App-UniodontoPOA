import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

// Custom exception for form errors
class FormSubmitException implements Exception {
  final String message;
  FormSubmitException(this.message);

  @override
  String toString() => message; // Esta linha é crucial para exibir a mensagem correta
}

class ReembolsoFormService {
  final String _baseUrl =
      'https://beneficiario-src.uniodontopoa.com.br:2083'; // ⚠️ Substitua pela URL da sua API
  static const int _maxFiles = 4;

  /// Obtém o CPF do usuário armazenado no SharedPreferences
  Future<String> _getUserCpf() async {
    final prefs = await SharedPreferences.getInstance();
    final cpf = prefs.getString('user_cpf');

    print('CPF encontrado no SharedPreferences: $cpf'); // Debug

    if (cpf == null || cpf.isEmpty) {
      throw FormSubmitException(
        'CPF do usuário não encontrado. Faça login novamente.',
      );
    }

    return cpf;
  }

  /// Valida se o arquivo tem extensão aceita
  bool _isValidFileType(String fileExtension) {
    return ['jpg', 'jpeg', 'pdf'].contains(fileExtension.toLowerCase());
  }

  /// Converte um arquivo para o formato base64 esperado pela API
  Future<Map<String, String>> _convertFileToBase64(dynamic arquivo) async {
    try {
      Uint8List? bytes;
      String fileName = 'arquivo_${DateTime.now().millisecondsSinceEpoch}';

      if (kIsWeb) {
        // No web, arquivo pode ser XFile
        if (arquivo is XFile) {
          bytes = await arquivo.readAsBytes();
          fileName = arquivo.name;
        } else {
          throw FormSubmitException('Tipo de arquivo não suportado na web');
        }
      } else {
        // No mobile/desktop, arquivo é File
        if (arquivo is File) {
          if (!arquivo.existsSync()) {
            throw FormSubmitException(
              'Arquivo não encontrado: ${arquivo.path}',
            );
          }
          bytes = await arquivo.readAsBytes();
          fileName = arquivo.path.split('/').last;
        } else {
          throw FormSubmitException('Tipo de arquivo não suportado');
        }
      }

      // Converte para base64
      String base64Image = base64Encode(bytes);

      // Extrai a extensão do arquivo
      String fileExtension = fileName.split('.').last.toLowerCase();

      // Se não tiver extensão, tenta detectar pelo tipo MIME ou assume JPG
      if (fileExtension == fileName || fileExtension.isEmpty) {
        fileExtension = 'jpg'; // padrão
      }

      // Valida se é um tipo de arquivo aceito
      if (!_isValidFileType(fileExtension)) {
        throw FormSubmitException(
          'Tipo de arquivo não aceito: $fileExtension. Use apenas JPG, JPEG ou PDF.',
        );
      }

      print(
        'Arquivo convertido com sucesso: $fileName (${bytes.length} bytes)',
      );

      return {
        "file_data": base64Image,
        "file_name": fileName,
        "file_type": fileExtension,
      };
    } catch (e) {
      if (e is FormSubmitException) {
        rethrow;
      }
      throw FormSubmitException('Erro ao processar arquivo: $e');
    }
  }

  /// Processa a lista de arquivos e converte para base64
  Future<List<Map<String, String>>> _processFiles(
    List<dynamic> arquivos,
  ) async {
    // Valida o número máximo de arquivos
    if (arquivos.length > _maxFiles) {
      throw FormSubmitException(
        'Máximo de $_maxFiles arquivos permitidos. Você selecionou ${arquivos.length}.',
      );
    }

    if (arquivos.isEmpty) {
      throw FormSubmitException('Nenhum arquivo foi selecionado.');
    }

    List<Map<String, String>> anexos = [];

    for (int i = 0; i < arquivos.length; i++) {
      dynamic arquivo = arquivos[i];
      String arquivoInfo = kIsWeb
          ? (arquivo is XFile ? arquivo.name : 'arquivo_desconhecido')
          : (arquivo is File ? arquivo.path : 'arquivo_desconhecido');

      print('Processando arquivo ${i + 1}/${arquivos.length}: $arquivoInfo');

      try {
        final anexo = await _convertFileToBase64(arquivo);
        anexos.add(anexo);
      } catch (e) {
        if (e is FormSubmitException) {
          rethrow;
        }
        throw FormSubmitException('Erro ao processar arquivo $arquivoInfo: $e');
      }
    }

    print('Total de ${anexos.length} arquivos processados com sucesso');
    return anexos;
  }

  /// Valida se os campos obrigatórios estão presentes
  void _validateRequiredFields(Map<String, dynamic> formData) {
    final requiredFields = [
      'beneficiarioCartao',
      'beneficiarioNome',
      'beneficiarioPlano',
      'beneficiarioEmpresa',
      'titularNome',
      'endereco',
      'cidadeUf',
      'telResidencial', // telComercial é opcional
      'idUsuario',
      'emailUsuario',
      'dentistaNome',
      'dentistaTelefone',
      'dentistaCro',
      'dentistaCpfCnpj',
      'bancoNome',
      'bancoNumero',
      'bancoAgencia',
      'bancoConta',
    ];

    List<String> missingFields = [];

    for (String field in requiredFields) {
      if (formData[field] == null ||
          formData[field].toString().trim().isEmpty) {
        missingFields.add(field);
      }
    }

    if (missingFields.isNotEmpty) {
      throw FormSubmitException(
        'Campos obrigatórios não preenchidos: ${missingFields.join(', ')}',
      );
    }
  }

  /// Submete o formulário de reembolso para a API
  Future<void> submitReembolso({
    required Map<String, dynamic> formData,
    required List<dynamic>
    arquivos, // Alterado para aceitar tanto File quanto XFile
  }) async {
    try {
      print('Iniciando validação dos campos...');

      // Valida campos obrigatórios
      _validateRequiredFields(formData);
      print('Campos validados com sucesso');

      print('Buscando CPF do usuário...');

      // Obtém o CPF do SharedPreferences
      final userCpf = await _getUserCpf();
      print('CPF obtido: $userCpf');

      print('Processando arquivos...');

      // Processa os arquivos
      final anexos = await _processFiles(arquivos);
      print('Arquivos processados: ${anexos.length}');

      // Define a URL do endpoint
      final url = Uri.parse('$_baseUrl/email-reembolso');
      print('URL da requisição: $url');

      // Cria o body da requisição no formato JSON atualizado
      final requestBody = {
        "numero_cartao_cliente": formData['beneficiarioCartao'],
        "nome_cliente": formData['beneficiarioNome'],
        "plano": formData['beneficiarioPlano'],
        "empresa": formData['beneficiarioEmpresa'],
        "nome_titular": formData['titularNome'],
        "endereco": formData['endereco'],
        "cidade_uf": formData['cidadeUf'],
        "tel_com": formData['telComercial'] ?? '',
        "tel_res_cel": formData['telResidencial'],
        "id_usuario": formData['idUsuario'],
        "cpf": userCpf,
        "email_usuario": formData['emailUsuario'],
        "nome_cirurgiao": formData['dentistaNome'],
        "tel_consultorio": formData['dentistaTelefone'],
        "cro": formData['dentistaCro'],
        "cpf_cnpj": formData['dentistaCpfCnpj'],
        "endereco_cirurgiao": formData['dentistaEndereco'] ?? '',
        "cidade_uf_cirurgiao": formData['dentistaCidadeUf'] ?? '',
        "nome_banco": formData['bancoNome'],
        "numero_banco": formData['bancoNumero'],
        "agencia_digito": formData['bancoAgencia'],
        "conta_corrente_digito": formData['bancoConta'],
        "anexos": anexos,
      };

      final body = jsonEncode(requestBody);

      // Define os cabeçalhos da requisição
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      print('Enviando requisição para: $url');
      print('Número de anexos: ${anexos.length}');
      print('Tamanho do body: ${body.length} caracteres');

      // Faz a requisição POST
      final response = await http.post(url, headers: headers, body: body);

      print('Status da resposta: ${response.statusCode}');
      print('Headers da resposta: ${response.headers}');

      // Analisa a resposta
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Reembolso solicitado com sucesso!');

        try {
          final responseBody = jsonDecode(response.body);
          print('Resposta da API (JSON): $responseBody');
        } catch (e) {
          print('Resposta da API (texto): ${response.body}');
        }
      } else {
        // Tenta obter mais detalhes do erro da API
        String errorMessage =
            'Erro ao enviar o formulário. Status: ${response.statusCode}';

        print('Corpo da resposta de erro: ${response.body}');

        try {
          final errorBody = jsonDecode(response.body);
          if (errorBody['message'] != null) {
            errorMessage = errorBody['message'];
          } else if (errorBody['error'] != null) {
            errorMessage = errorBody['error'];
          } else if (errorBody['detail'] != null) {
            errorMessage = errorBody['detail'];
          }
        } catch (e) {
          // Se não conseguir fazer parse do JSON, usa a mensagem padrão
          if (response.body.isNotEmpty) {
            errorMessage += '\nDetalhes: ${response.body}';
          }
        }

        throw FormSubmitException(errorMessage);
      }
    } on SocketException catch (e) {
      print('SocketException: $e');
      throw FormSubmitException(
        'Não foi possível conectar ao servidor. Verifique sua conexão com a internet.',
      );
    } on HttpException catch (e) {
      print('HttpException: $e');
      throw FormSubmitException(
        'Erro na comunicação com o servidor: ${e.message}',
      );
    } on FormatException catch (e) {
      print('FormatException: $e');
      throw FormSubmitException('Erro no formato dos dados: ${e.message}');
    } on FormSubmitException catch (e) {
      print('FormSubmitException: ${e.message}');
      // Re-throw FormSubmitException sem modificar
      rethrow;
    } catch (e, stackTrace) {
      print('Erro genérico: $e');
      print('Stack trace: $stackTrace');
      throw FormSubmitException('Ocorreu um erro inesperado: $e');
    }
  }
}
