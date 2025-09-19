import 'package:flutter/material.dart';

import '../model/beneficiario_model.dart';
import 'form_controllers.dart';
import 'reembolso_form_widgets.dart';

class FormValidation {
  static bool validateStep(
    BuildContext context,
    int currentStep,
    BeneficiarioModel? selectedBeneficiario,
    FormControllers controllers,
    List<dynamic> anexosRecibos, // Alterado para aceitar File e XFile
  ) {
    switch (currentStep) {
      case 0: // Dados do Beneficiário
        return _validateBeneficiarioStep(
          context,
          selectedBeneficiario,
          controllers,
        );
      case 1: // Dados do Dentista
        return _validateDentistaStep(context, controllers);
      case 2: // Anexos e Banco
        return _validateAnexosAndBancoStep(context, controllers, anexosRecibos);
      default:
        return true;
    }
  }

  static bool _validateBeneficiarioStep(
    BuildContext context,
    BeneficiarioModel? selectedBeneficiario,
    FormControllers controllers,
  ) {
    if (selectedBeneficiario == null) {
      ReembolsoFormUtils.showErrorSnackbar(
        context,
        'Por favor, selecione um beneficiário.',
      );
      return false;
    }

    if (controllers.endereco.text.isEmpty ||
        controllers.cidadeUf.text.isEmpty ||
        controllers.telResidencial.text.isEmpty ||
        controllers.idUsuario.text.isEmpty ||
        controllers.emailUsuario.text.isEmpty) {
      ReembolsoFormUtils.showErrorSnackbar(
        context,
        'Por favor, preencha todos os campos obrigatórios.',
      );
      return false;
    }

    if (!controllers.emailUsuario.text.contains('@')) {
      ReembolsoFormUtils.showErrorSnackbar(
        context,
        'Por favor, insira um email válido.',
      );
      return false;
    }

    return true;
  }

  static bool _validateDentistaStep(
    BuildContext context,
    FormControllers controllers,
  ) {
    if (controllers.dentistaNome.text.isEmpty ||
        controllers.dentistaTelefone.text.isEmpty ||
        controllers.dentistaCro.text.isEmpty ||
        controllers.dentistaCpfCnpj.text.isEmpty) {
      ReembolsoFormUtils.showErrorSnackbar(
        context,
        'Por favor, preencha todos os dados do dentista.',
      );
      return false;
    }
    return true;
  }

  static bool _validateAnexosAndBancoStep(
    BuildContext context,
    FormControllers controllers,
    List<dynamic> anexosRecibos, // Alterado para aceitar File e XFile
  ) {
    if (anexosRecibos.isEmpty) {
      ReembolsoFormUtils.showErrorSnackbar(
        context,
        'Por favor, anexe pelo menos um recibo ou nota fiscal.',
      );
      return false;
    }

    if (controllers.bancoNome.text.isEmpty ||
        controllers.bancoNumero.text.isEmpty ||
        controllers.bancoAgencia.text.isEmpty ||
        controllers.bancoConta.text.isEmpty) {
      ReembolsoFormUtils.showErrorSnackbar(
        context,
        'Por favor, preencha todos os dados bancários.',
      );
      return false;
    }
    return true;
  }

  // Validadores para campos individuais
  static String? validateEmail(String? value) {
    if (value?.isEmpty ?? true) return 'Campo obrigatório';
    if (!value!.contains('@')) return 'Email inválido';
    return null;
  }

  static String? validateRequired(String? value) {
    return (value?.isEmpty ?? true) ? 'Campo obrigatório' : null;
  }
}
