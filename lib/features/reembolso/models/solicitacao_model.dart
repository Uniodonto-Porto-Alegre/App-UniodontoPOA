class Solicitacao {
  final int idSolicitacao;
  final String descricaoSolicitacao;
  final String statusSolicitacao;
  final String prioridadeSolicitacao;
  final String dataCriacaoSolicitacao;
  final String? dataEncerramentoSolicitacao;
  final String? dataPrevistaEncerramentoSolicitacao;
  final String? dataCancelamentoSolicitacao;
  final String usuarioCriacaoSolicitacao;
  final String? usuarioEncerramentoSolicitacao;
  final String? usuarioResponsavelSolicitacao;
  final String? usuarioCancelamentoSolicitacao;
  final int idSolicitacaoMotivo;
  final String idUsuarioTitularSolicitante;
  final String numProtocolo;
  final String dddTelefoneOutros;
  final String telefoneOutros;
  final String emailOutros;
  final String idGrauParentescoFederacaoSolicitante;
  final bool ouvidoria;
  final bool notificouPrazoResposta;
  final bool notificouPrazoEncerramento;
  final int idCanalRecebimento;

  Solicitacao({
    required this.idSolicitacao,
    required this.descricaoSolicitacao,
    required this.statusSolicitacao,
    required this.prioridadeSolicitacao,
    required this.dataCriacaoSolicitacao,
    this.dataEncerramentoSolicitacao,
    this.dataPrevistaEncerramentoSolicitacao,
    this.dataCancelamentoSolicitacao,
    required this.usuarioCriacaoSolicitacao,
    this.usuarioEncerramentoSolicitacao,
    this.usuarioResponsavelSolicitacao,
    this.usuarioCancelamentoSolicitacao,
    required this.idSolicitacaoMotivo,
    required this.idUsuarioTitularSolicitante,
    required this.numProtocolo,
    required this.dddTelefoneOutros,
    required this.telefoneOutros,
    required this.emailOutros,
    required this.idGrauParentescoFederacaoSolicitante,
    required this.ouvidoria,
    required this.notificouPrazoResposta,
    required this.notificouPrazoEncerramento,
    required this.idCanalRecebimento,
  });

  factory Solicitacao.fromJson(Map<String, dynamic> json) {
    return Solicitacao(
      idSolicitacao: json['id_solicitacao'] ?? 0,
      descricaoSolicitacao: json['descricao_solicitacao'] ?? 'Sem descrição',
      statusSolicitacao: json['status_solicitacao'] ?? 'Desconhecido',
      prioridadeSolicitacao: json['prioridade_solicitacao'] ?? 'N/A',
      dataCriacaoSolicitacao: json['data_criacao_solicitacao'] ?? '',
      dataEncerramentoSolicitacao: json['data_encerramento_solicitacao'],
      dataPrevistaEncerramentoSolicitacao:
          json['data_prevista_encerramento_solicitacao'],
      dataCancelamentoSolicitacao: json['data_cancelamento_solicitacao'],
      usuarioCriacaoSolicitacao: json['usuario_criacao_solicitacao'] ?? 'N/A',
      usuarioEncerramentoSolicitacao: json['usuario_encerramento_solicitacao'],
      usuarioResponsavelSolicitacao: json['usuario_responsavel_solicitacao'],
      usuarioCancelamentoSolicitacao: json['usuario_cancelamento_solicitacao'],
      idSolicitacaoMotivo: json['id_solicitacao_motivo'] ?? 0,
      idUsuarioTitularSolicitante: json['id_usuario_titular_solicitante'] ?? '',
      numProtocolo: json['num_protocolo'] ?? 'N/A',
      dddTelefoneOutros: json['ddd_telefone_outros'] ?? '00',
      telefoneOutros: json['telefone_outros'] ?? '000000000',
      emailOutros: json['email_outros'] ?? '',
      idGrauParentescoFederacaoSolicitante:
          json['id_grau_parentesco_federacao_solicitante'] ?? '',
      ouvidoria: json['ouvidoria'] ?? false,
      notificouPrazoResposta: json['notificou_prazo_resposta'] ?? false,
      notificouPrazoEncerramento: json['notificou_prazo_encerramento'] ?? false,
      idCanalRecebimento: json['id_canal_recebimento'] ?? 0,
    );
  }

  // Métodos auxiliares para formatação
  String get statusFormatado {
    switch (statusSolicitacao.toUpperCase()) {
      case 'E':
        return 'Encerrada';
      case 'A':
        return 'Aberta';
      case 'P':
        return 'Em Processamento';
      case 'C':
        return 'Cancelada';
      default:
        return statusSolicitacao;
    }
  }

  String get prioridadeFormatada {
    switch (prioridadeSolicitacao.toUpperCase()) {
      case 'A':
        return 'Alta';
      case 'M':
        return 'Média';
      case 'B':
        return 'Baixa';
      default:
        return prioridadeSolicitacao;
    }
  }

  String get telefoneFormatado {
    if (telefoneOutros.length >= 9 && dddTelefoneOutros != '00') {
      return '($dddTelefoneOutros) ${telefoneOutros.substring(0, 5)}-${telefoneOutros.substring(5)}';
    }
    return telefoneOutros;
  }

  String get descricaoResumo {
    if (descricaoSolicitacao.length > 100) {
      return '${descricaoSolicitacao.substring(0, 100)}...';
    }
    return descricaoSolicitacao;
  }
}
