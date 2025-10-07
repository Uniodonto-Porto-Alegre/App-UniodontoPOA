import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../../core/theme/app_theme.dart';
import '../model/beneficiario_model.dart';
import '../widgets/form_controllers.dart';
import '../widgets/form_validation.dart';
import '../widgets/reembolso_form_widgets.dart';

class ReembolsoFormSteps {
  final FormControllers controllers;
  final List<BeneficiarioModel> beneficiarios;
  final BeneficiarioModel? selectedBeneficiario;
  final Function(BeneficiarioModel?) onBeneficiarioChanged;
  final bool isLoadingBeneficiarios;
  final List<dynamic> anexosRecibos; // Alterado para aceitar File e XFile
  final int maxFiles;
  final VoidCallback onPickFile;
  final Function(int) onRemoveFile;
  final List<String> stepTitles;
  final List<IconData> stepIcons;

  // Máscaras de formatação
  static final _telefoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  static final _telefoneComercialMask = MaskTextInputFormatter(
    mask: '(##) ####-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  static final _cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  static final _cnpjMask = MaskTextInputFormatter(
    mask: '##.###.###/####-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  static final _cartaoMask = MaskTextInputFormatter(
    mask: '#### #### #### ####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  static final _agenciaMask = MaskTextInputFormatter(
    mask: '####-#',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  static final _contaMask = MaskTextInputFormatter(
    mask: '#######-#',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  static final _croMask = MaskTextInputFormatter(
    mask: '##.###',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  const ReembolsoFormSteps({
    required this.controllers,
    required this.beneficiarios,
    required this.selectedBeneficiario,
    required this.onBeneficiarioChanged,
    required this.isLoadingBeneficiarios,
    required this.anexosRecibos,
    required this.maxFiles,
    required this.onPickFile,
    required this.onRemoveFile,
    required this.stepTitles,
    required this.stepIcons,
  });

  // Função para detectar se é CPF ou CNPJ e aplicar máscara dinamicamente
  List<TextInputFormatter> _getCpfCnpjFormatters() {
    return [
      FilteringTextInputFormatter.digitsOnly,
      TextInputFormatter.withFunction((oldValue, newValue) {
        final text = newValue.text;
        if (text.length <= 11) {
          // CPF
          return _cpfMask.formatEditUpdate(oldValue, newValue);
        } else {
          // CNPJ
          return _cnpjMask.formatEditUpdate(oldValue, newValue);
        }
      }),
    ];
  }

  Widget buildStepBeneficiario() {
    return Column(
      children: [
        if (isLoadingBeneficiarios)
          const Center(
            child: CircularProgressIndicator(
              color: AppColors.vinhoUltraUniodonto,
            ),
          )
        else
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButtonFormField<BeneficiarioModel>(
              initialValue: selectedBeneficiario,
              hint: const Text('Selecione o Beneficiário'),
              isExpanded: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.person,
                  color: AppColors.vinhoUltraUniodonto,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              items: beneficiarios.map((BeneficiarioModel beneficiario) {
                return DropdownMenuItem<BeneficiarioModel>(
                  value: beneficiario,
                  child: Text('${beneficiario.nome} (${beneficiario.tipo})'),
                );
              }).toList(),
              onChanged: onBeneficiarioChanged,
              validator: (value) => value == null ? 'Campo obrigatório' : null,
            ),
          ),

        ReembolsoFormWidgets.buildModernTextField(
          controller: controllers.beneficiarioNome,
          label: 'Nome do Cliente',
          icon: Icons.person_outline,
          readOnly: true,
        ),

        ReembolsoFormWidgets.buildModernTextField(
          controller: controllers.beneficiarioCartao,
          label: 'Número do Cartão',
          icon: Icons.credit_card,
          readOnly: true,
          inputFormatters: [_cartaoMask],
        ),

        ReembolsoFormWidgets.buildModernTextField(
          controller: controllers.beneficiarioPlano,
          label: 'Plano',
          icon: Icons.medical_services_outlined,
          readOnly: true,
        ),

        ReembolsoFormWidgets.buildModernTextField(
          controller: controllers.beneficiarioEmpresa,
          label: 'Empresa',
          icon: Icons.business,
          readOnly: true,
        ),

        ReembolsoFormWidgets.buildModernTextField(
          controller: controllers.titularNome,
          label: 'Nome do Titular',
          icon: Icons.person_pin,
          readOnly: true,
        ),

        // Novos campos obrigatórios
        ReembolsoFormWidgets.buildModernTextField(
          controller: controllers.idUsuario,
          label: 'ID do Usuário *',
          icon: Icons.account_circle,
          validator: FormValidation.validateRequired,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),

        ReembolsoFormWidgets.buildModernTextField(
          controller: controllers.emailUsuario,
          label: 'Email do Usuário *',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          validator: FormValidation.validateEmail,
        ),

        ReembolsoFormWidgets.buildModernTextField(
          controller: controllers.endereco,
          label: 'Endereço',
          icon: Icons.location_on_outlined,
          validator: FormValidation.validateRequired,
        ),

        ReembolsoFormWidgets.buildModernTextField(
          controller: controllers.cidadeUf,
          label: 'Cidade/UF',
          icon: Icons.location_city,
          validator: FormValidation.validateRequired,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ÿ\s\-\/]')),
            TextInputFormatter.withFunction((oldValue, newValue) {
              // Formatar como "Cidade/UF"
              String text = newValue.text;
              if (text.contains('/')) {
                List<String> parts = text.split('/');
                if (parts.length == 2) {
                  String cidade = parts[0].trim();
                  String uf = parts[1].trim().toUpperCase();
                  if (uf.length > 2) uf = uf.substring(0, 2);
                  text = '$cidade/$uf';
                }
              }
              return TextEditingValue(
                text: text,
                selection: TextSelection.collapsed(offset: text.length),
              );
            }),
          ],
        ),

        ReembolsoFormWidgets.buildModernTextField(
          controller: controllers.telComercial,
          label: 'Tel. Comercial (Opcional)',
          icon: Icons.business_center,
          keyboardType: TextInputType.phone,
          inputFormatters: [_telefoneComercialMask],
        ),

        ReembolsoFormWidgets.buildModernTextField(
          controller: controllers.telResidencial,
          label: 'Tel. Residencial / Celular',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          validator: FormValidation.validateRequired,
          inputFormatters: [_telefoneMask],
        ),
      ],
    );
  }

  Widget buildStepDentista() {
    return Column(
      children: [
        ReembolsoFormWidgets.buildModernTextField(
          controller: controllers.dentistaNome,
          label: 'Nome do Cirurgião-dentista',
          icon: Icons.medical_services,
          validator: FormValidation.validateRequired,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ÿ\s\.]')),
          ],
        ),

        ReembolsoFormWidgets.buildModernTextField(
          controller: controllers.dentistaTelefone,
          label: 'Telefone do consultório',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          validator: FormValidation.validateRequired,
          inputFormatters: [_telefoneMask],
        ),

        ReembolsoFormWidgets.buildModernTextField(
          controller: controllers.dentistaCro,
          label: 'CRO',
          icon: Icons.badge,
          validator: FormValidation.validateRequired,
          keyboardType: TextInputType.number,
          inputFormatters: [_croMask],
        ),

        ReembolsoFormWidgets.buildModernTextField(
          controller: controllers.dentistaCpfCnpj,
          label: 'CPF/CNPJ',
          icon: Icons.document_scanner,
          validator: FormValidation.validateRequired,
          keyboardType: TextInputType.number,
          inputFormatters: _getCpfCnpjFormatters(),
        ),

        ReembolsoFormWidgets.buildModernTextField(
          controller: controllers.dentistaEndereco,
          label: 'Endereço do Dentista (Opcional)',
          icon: Icons.location_on_outlined,
        ),

        ReembolsoFormWidgets.buildModernTextField(
          controller: controllers.dentistaCidadeUf,
          label: 'Cidade/UF do Dentista (Opcional)',
          icon: Icons.location_city,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ÿ\s\-\/]')),
            TextInputFormatter.withFunction((oldValue, newValue) {
              // Formatar como "Cidade/UF"
              String text = newValue.text;
              if (text.contains('/')) {
                List<String> parts = text.split('/');
                if (parts.length == 2) {
                  String cidade = parts[0].trim();
                  String uf = parts[1].trim().toUpperCase();
                  if (uf.length > 2) uf = uf.substring(0, 2);
                  text = '$cidade/$uf';
                }
              }
              return TextEditingValue(
                text: text,
                selection: TextSelection.collapsed(offset: text.length),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget buildStepReciboBancario() {
    return Column(
      children: [
        // Seção de Anexos
        _buildAnexosSection(),
        const SizedBox(height: 24),
        // Seção Bancária
        _buildDadosBancariosSection(),
      ],
    );
  }

  Widget _buildAnexosSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: anexosRecibos.isNotEmpty ? Colors.green : Colors.grey[300]!,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            anexosRecibos.isNotEmpty ? Icons.check_circle : Icons.attach_file,
            size: 48,
            color: anexosRecibos.isNotEmpty
                ? Colors.green
                : AppColors.vinhoUltraUniodonto,
          ),
          const SizedBox(height: 16),
          const Text(
            'Anexar Recibos ou Notas Fiscais',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            anexosRecibos.isNotEmpty
                ? '${anexosRecibos.length} arquivo(s) anexado(s)'
                : 'Toque para selecionar arquivos (máximo $maxFiles)',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 16),

          // Botão para adicionar arquivos
          if (anexosRecibos.length < maxFiles)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onPickFile,
                icon: const Icon(Icons.add_circle),
                label: Text(
                  anexosRecibos.isEmpty
                      ? 'Selecionar Arquivos'
                      : 'Adicionar Outro Arquivo (${anexosRecibos.length}/$maxFiles)',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.vinhoUltraUniodonto,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

          // Lista de arquivos anexados
          if (anexosRecibos.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...List.generate(anexosRecibos.length, (index) {
              final arquivo = anexosRecibos[index];
              String fileName;

              if (kIsWeb && arquivo is XFile) {
                fileName = arquivo.name;
              } else if (arquivo is File) {
                fileName = arquivo.path.split('/').last;
              } else {
                fileName = 'Arquivo ${index + 1}';
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      fileName.toLowerCase().endsWith('.pdf')
                          ? Icons.picture_as_pdf
                          : Icons.image,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        fileName,
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => onRemoveFile(index),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildDadosBancariosSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.vinhoUltraUniodonto.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance,
                  color: AppColors.vinhoUltraUniodonto,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Dados Bancários do Titular',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),

          ReembolsoFormWidgets.buildModernTextField(
            controller: controllers.bancoNome,
            label: 'Nome do Banco',
            icon: Icons.business,
            validator: FormValidation.validateRequired,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ÿ\s\.]')),
            ],
          ),

          ReembolsoFormWidgets.buildModernTextField(
            controller: controllers.bancoNumero,
            label: 'Número do Banco',
            icon: Icons.numbers,
            keyboardType: TextInputType.number,
            validator: FormValidation.validateRequired,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3), // Máximo 3 dígitos
            ],
          ),

          ReembolsoFormWidgets.buildModernTextField(
            controller: controllers.bancoAgencia,
            label: 'Agência / Dígito',
            icon: Icons.account_tree,
            validator: FormValidation.validateRequired,
            keyboardType: TextInputType.number,
            inputFormatters: [_agenciaMask],
          ),

          ReembolsoFormWidgets.buildModernTextField(
            controller: controllers.bancoConta,
            label: 'Conta Corrente / Dígito',
            icon: Icons.account_balance_wallet,
            validator: FormValidation.validateRequired,
            keyboardType: TextInputType.number,
            inputFormatters: [_contaMask],
          ),
        ],
      ),
    );
  }

  Widget buildStepRevisao() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.vinhoUltraUniodonto.withOpacity(0.1),
                AppColors.vinhoUltraUniodonto.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.vinhoUltraUniodonto.withOpacity(0.2),
            ),
          ),
          child: const Column(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 64,
                color: AppColors.vinhoUltraUniodonto,
              ),
              SizedBox(height: 16),
              Text(
                'Revisão Final',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.vinhoUltraUniodonto,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Por favor, revise todas as informações antes de enviar sua solicitação.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Resumo dos dados
        _buildSummaryCard('Beneficiário', [
          'Nome: ${controllers.beneficiarioNome.text}',
          'Cartão: ${controllers.beneficiarioCartao.text}',
          'Plano: ${controllers.beneficiarioPlano.text}',
          'Email: ${controllers.emailUsuario.text}',
          'ID Usuário: ${controllers.idUsuario.text}',
        ], Icons.person),

        _buildSummaryCard('Dentista', [
          'Nome: ${controllers.dentistaNome.text}',
          'Telefone: ${controllers.dentistaTelefone.text}',
          'CRO: ${controllers.dentistaCro.text}',
          'CPF/CNPJ: ${controllers.dentistaCpfCnpj.text}',
        ], Icons.medical_services),

        _buildSummaryCard('Dados Bancários', [
          'Banco: ${controllers.bancoNome.text}',
          'Agência: ${controllers.bancoAgencia.text}',
          'Conta: ${controllers.bancoConta.text}',
        ], Icons.account_balance),

        _buildSummaryCard('Anexos', [
          anexosRecibos.isNotEmpty
              ? 'Arquivos (${anexosRecibos.length}): ${anexosRecibos.map((arquivo) {
                  if (kIsWeb && arquivo is XFile) {
                    return arquivo.name;
                  } else if (arquivo is File) {
                    return arquivo.path.split('/').last;
                  }
                  return 'Arquivo desconhecido';
                }).join(', ')}'
              : 'Nenhum arquivo anexado',
        ], Icons.attach_file),
      ],
    );
  }

  Widget _buildSummaryCard(String title, List<String> items, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.vinhoUltraUniodonto, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.vinhoUltraUniodonto,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                item,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
