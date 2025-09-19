import 'package:flutter/material.dart';

class FormControllers {
  // Dados do Beneficiário
  final beneficiarioNome = TextEditingController();
  final beneficiarioCartao = TextEditingController();
  final beneficiarioPlano = TextEditingController();
  final beneficiarioEmpresa = TextEditingController();
  final titularNome = TextEditingController();
  final endereco = TextEditingController();
  final cidadeUf = TextEditingController();
  final telComercial = TextEditingController();
  final telResidencial = TextEditingController();
  final idUsuario = TextEditingController();
  final emailUsuario = TextEditingController();

  // Dados do Dentista
  final dentistaNome = TextEditingController();
  final dentistaTelefone = TextEditingController();
  final dentistaCro = TextEditingController();
  final dentistaCpfCnpj = TextEditingController();
  final dentistaEndereco = TextEditingController();
  final dentistaCidadeUf = TextEditingController();

  // Dados Bancários
  final bancoNome = TextEditingController();
  final bancoNumero = TextEditingController();
  final bancoAgencia = TextEditingController();
  final bancoConta = TextEditingController();

  void dispose() {
    // Dados do Beneficiário
    beneficiarioNome.dispose();
    beneficiarioCartao.dispose();
    beneficiarioPlano.dispose();
    beneficiarioEmpresa.dispose();
    titularNome.dispose();
    endereco.dispose();
    cidadeUf.dispose();
    telComercial.dispose();
    telResidencial.dispose();
    idUsuario.dispose();
    emailUsuario.dispose();

    // Dados do Dentista
    dentistaNome.dispose();
    dentistaTelefone.dispose();
    dentistaCro.dispose();
    dentistaCpfCnpj.dispose();
    dentistaEndereco.dispose();
    dentistaCidadeUf.dispose();

    // Dados Bancários
    bancoNome.dispose();
    bancoNumero.dispose();
    bancoAgencia.dispose();
    bancoConta.dispose();
  }
}

class FormDataHelper {
  static Map<String, String> buildFormData(FormControllers controllers) {
    return {
      'beneficiarioNome': controllers.beneficiarioNome.text,
      'beneficiarioCartao': controllers.beneficiarioCartao.text,
      'beneficiarioPlano': controllers.beneficiarioPlano.text,
      'beneficiarioEmpresa': controllers.beneficiarioEmpresa.text,
      'titularNome': controllers.titularNome.text,
      'endereco': controllers.endereco.text,
      'cidadeUf': controllers.cidadeUf.text,
      'telComercial': controllers.telComercial.text,
      'telResidencial': controllers.telResidencial.text,
      'idUsuario': controllers.idUsuario.text,
      'emailUsuario': controllers.emailUsuario.text,
      'dentistaNome': controllers.dentistaNome.text,
      'dentistaTelefone': controllers.dentistaTelefone.text,
      'dentistaCro': controllers.dentistaCro.text,
      'dentistaCpfCnpj': controllers.dentistaCpfCnpj.text,
      'dentistaEndereco': controllers.dentistaEndereco.text,
      'dentistaCidadeUf': controllers.dentistaCidadeUf.text,
      'bancoNome': controllers.bancoNome.text,
      'bancoNumero': controllers.bancoNumero.text,
      'bancoAgencia': controllers.bancoAgencia.text,
      'bancoConta': controllers.bancoConta.text,
    };
  }
}
