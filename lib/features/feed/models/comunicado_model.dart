class Comunicado {
  final int id;
  final String titulo;
  final String conteudo;
  final DateTime data;
  final String categoria;
  bool isLido;

  Comunicado({
    required this.id,
    required this.titulo,
    required this.conteudo,
    required this.data,
    required this.categoria,
    this.isLido = false,
  });

  // Mock data para desenvolvimento
  static List<Comunicado> mockComunicados = [
    Comunicado(
      id: 1,
      titulo: 'Atualização do Sistema',
      conteudo:
          'Implementamos melhorias no sistema para melhor performance e experiência do usuário.',
      data: DateTime.now().subtract(const Duration(hours: 2)),
      categoria: 'Atualização',
    ),
    Comunicado(
      id: 2,
      titulo: 'Manutenção Programada',
      conteudo:
          'No próximo domingo, das 02h às 06h, realizaremos manutenção no sistema.',
      data: DateTime.now().subtract(const Duration(days: 1)),
      categoria: 'Manutenção',
      isLido: true,
    ),
    Comunicado(
      id: 3,
      titulo: 'Novos Serviços Disponíveis',
      conteudo:
          'Temos o prazer de anunciar novos serviços em nossa plataforma.',
      data: DateTime.now().subtract(const Duration(days: 3)),
      categoria: 'Novidade',
      isLido: true,
    ),
  ];
}
