import 'package:cloud_firestore/cloud_firestore.dart';

class Turno {
  final bool ativo;
  final String horaInicio;
  final String horaFim;

  const Turno({
    this.ativo = false,
    this.horaInicio = '09:00',
    this.horaFim = '12:00',
  });

  factory Turno.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const Turno();
    return Turno(
      ativo: map['ativo'] as bool? ?? false,
      horaInicio: map['horaInicio'] as String? ?? '09:00',
      horaFim: map['horaFim'] as String? ?? '12:00',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ativo': ativo,
      'horaInicio': horaInicio,
      'horaFim': horaFim,
    };
  }

  Turno copyWith({bool? ativo, String? horaInicio, String? horaFim}) {
    return Turno(
      ativo: ativo ?? this.ativo,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFim: horaFim ?? this.horaFim,
    );
  }
}

class HorarioFuncionamento {
  final List<String> diasFuncionamento;
  final Turno manha;
  final Turno tarde;
  final Turno noite;
  final int intervaloAgendamentoMinutos;

  const HorarioFuncionamento({
    this.diasFuncionamento = const ['segunda', 'terca', 'quarta', 'quinta', 'sexta'],
    this.manha = const Turno(ativo: true, horaInicio: '09:00', horaFim: '12:00'),
    this.tarde = const Turno(ativo: true, horaInicio: '14:00', horaFim: '18:00'),
    this.noite = const Turno(ativo: false, horaInicio: '19:00', horaFim: '22:00'),
    this.intervaloAgendamentoMinutos = 30,
  });

  static const List<int> opcoesIntervalo = [1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60];

  factory HorarioFuncionamento.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const HorarioFuncionamento();
    final turnosRaw = map['turnos'];
    final turnos = turnosRaw is Map ? Map<String, dynamic>.from(turnosRaw) : null;
    return HorarioFuncionamento(
      diasFuncionamento: (map['diasFuncionamento'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['segunda', 'terca', 'quarta', 'quinta', 'sexta'],
      manha: Turno.fromMap(turnos?['manha'] as Map<String, dynamic>?),
      tarde: Turno.fromMap(turnos?['tarde'] as Map<String, dynamic>?),
      noite: Turno.fromMap(turnos?['noite'] as Map<String, dynamic>?),
      intervaloAgendamentoMinutos: (map['intervaloAgendamentoMinutos'] as num?)?.toInt() ?? 30,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'diasFuncionamento': diasFuncionamento,
      'turnos': {
        'manha': manha.toMap(),
        'tarde': tarde.toMap(),
        'noite': noite.toMap(),
      },
      'intervaloAgendamentoMinutos': intervaloAgendamentoMinutos,
    };
  }

  HorarioFuncionamento copyWith({
    List<String>? diasFuncionamento,
    Turno? manha,
    Turno? tarde,
    Turno? noite,
    int? intervaloAgendamentoMinutos,
  }) {
    return HorarioFuncionamento(
      diasFuncionamento: diasFuncionamento ?? this.diasFuncionamento,
      manha: manha ?? this.manha,
      tarde: tarde ?? this.tarde,
      noite: noite ?? this.noite,
      intervaloAgendamentoMinutos:
          intervaloAgendamentoMinutos ?? this.intervaloAgendamentoMinutos,
    );
  }
}

class Pilar {
  final String titulo;
  final String descricao;

  const Pilar({
    required this.titulo,
    required this.descricao,
  });

  factory Pilar.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const Pilar(titulo: '', descricao: '');
    return Pilar(
      titulo: map['titulo'] as String? ?? '',
      descricao: map['descricao'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descricao': descricao,
    };
  }

  Pilar copyWith({String? titulo, String? descricao}) {
    return Pilar(
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
    );
  }

  static List<Pilar> listaFromDynamic(dynamic raw) {
    if (raw == null || raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => Pilar.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }
}

class SiteConfigModel {
  // Hero
  final String heroTitulo;
  final String heroSubtitulo;
  final String? heroImagemUrl;

  // Specialty
  final String specialtyTitulo;
  final String specialtyDescricao;

  // Galeria
  final String galeriaTitulo;
  final String galeriaSubtitulo;
  final List<String> galeriaImagens;

  // Essência
  final String essenciaTitulo;
  final String essenciaDescricao;

  // Pilares
  final String pilaresTitulo;
  final List<Pilar> pilares;

  // Testemunhos
  final String testemunhosTitulo;

  // Pronta a Brilhar
  final String prontaBrilharTitulo;
  final String prontaBrilharDescricao;

  // Footer
  final String footerNome;
  final String footerCopyright;
  final String footerRedesSociais;
  final String footerHorario;
  final String footerHorarioTexto;
  final String footerEmail;
  final String footerTelefone;
  final String footerEndereco;
  final String footerWhatsapp;
  final String footerInstagram;
  final String footerTiktok;

  // Horário de funcionamento
  final HorarioFuncionamento horarioFuncionamento;

  final DateTime? atualizadoEm;

  const SiteConfigModel({
    this.heroTitulo = '',
    this.heroSubtitulo = '',
    this.heroImagemUrl,
    this.specialtyTitulo = '',
    this.specialtyDescricao = '',
    this.galeriaTitulo = '',
    this.galeriaSubtitulo = '',
    this.galeriaImagens = const [],
    this.essenciaTitulo = '',
    this.essenciaDescricao = '',
    this.pilaresTitulo = '',
    this.pilares = const [],
    this.testemunhosTitulo = '',
    this.prontaBrilharTitulo = '',
    this.prontaBrilharDescricao = '',
    this.footerNome = '',
    this.footerCopyright = '',
    this.footerRedesSociais = '',
    this.footerHorario = '',
    this.footerHorarioTexto = '',
    this.footerEmail = '',
    this.footerTelefone = '',
    this.footerEndereco = '',
    this.footerWhatsapp = '',
    this.footerInstagram = '',
    this.footerTiktok = '',
    this.horarioFuncionamento = const HorarioFuncionamento(),
    this.atualizadoEm,
  });

  factory SiteConfigModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return SiteConfigModel.fromMap(data);
  }

  factory SiteConfigModel.fromMap(Map<String, dynamic> data) {
    return SiteConfigModel(
      heroTitulo: data['heroTitulo'] as String? ?? '',
      heroSubtitulo: data['heroSubtitulo'] as String? ?? '',
      heroImagemUrl: data['heroImagemUrl'] as String?,
      specialtyTitulo: data['specialtyTitulo'] as String? ?? '',
      specialtyDescricao: data['specialtyDescricao'] as String? ?? '',
      galeriaTitulo: data['galeriaTitulo'] as String? ?? '',
      galeriaSubtitulo: data['galeriaSubtitulo'] as String? ?? '',
      galeriaImagens: (data['galeriaImagens'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      essenciaTitulo: data['essenciaTitulo'] as String? ?? '',
      essenciaDescricao: data['essenciaDescricao'] as String? ?? '',
      pilaresTitulo: data['pilaresTitulo'] as String? ?? '',
      pilares: Pilar.listaFromDynamic(data['pilares']),
      testemunhosTitulo: data['testemunhosTitulo'] as String? ?? '',
      prontaBrilharTitulo: data['prontaBrilharTitulo'] as String? ?? '',
      prontaBrilharDescricao: data['prontaBrilharDescricao'] as String? ?? '',
      footerNome: data['footerNome'] as String? ?? '',
      footerCopyright: data['footerCopyright'] as String? ?? '',
      footerRedesSociais: data['footerRedesSociais'] as String? ?? '',
      footerHorario: data['footerHorario'] as String? ?? '',
      footerHorarioTexto: data['footerHorarioTexto'] as String? ?? '',
      footerEmail: data['footerEmail'] as String? ?? '',
      footerTelefone: data['footerTelefone'] as String? ?? '',
      footerEndereco: data['footerEndereco'] as String? ?? '',
      footerWhatsapp: data['footerWhatsapp'] as String? ?? '',
      footerInstagram: data['footerInstagram'] as String? ?? '',
      footerTiktok: data['footerTiktok'] as String? ?? '',
      horarioFuncionamento: HorarioFuncionamento.fromMap(
          data['horarioFuncionamento'] as Map<String, dynamic>?),
      atualizadoEm: (data['atualizadoEm'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'heroTitulo': heroTitulo,
      'heroSubtitulo': heroSubtitulo,
      'heroImagemUrl': heroImagemUrl,
      'specialtyTitulo': specialtyTitulo,
      'specialtyDescricao': specialtyDescricao,
      'galeriaTitulo': galeriaTitulo,
      'galeriaSubtitulo': galeriaSubtitulo,
      'galeriaImagens': galeriaImagens,
      'essenciaTitulo': essenciaTitulo,
      'essenciaDescricao': essenciaDescricao,
      'pilaresTitulo': pilaresTitulo,
      'pilares': pilares.map((p) => p.toMap()).toList(),
      'testemunhosTitulo': testemunhosTitulo,
      'prontaBrilharTitulo': prontaBrilharTitulo,
      'prontaBrilharDescricao': prontaBrilharDescricao,
      'footerNome': footerNome,
      'footerCopyright': footerCopyright,
      'footerRedesSociais': footerRedesSociais,
      'footerHorario': footerHorario,
      'footerHorarioTexto': footerHorarioTexto,
      'footerEmail': footerEmail,
      'footerTelefone': footerTelefone,
      'footerEndereco': footerEndereco,
      'footerWhatsapp': footerWhatsapp,
      'footerInstagram': footerInstagram,
      'footerTiktok': footerTiktok,
      'horarioFuncionamento': horarioFuncionamento.toMap(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    };
  }

  SiteConfigModel copyWith({
    String? heroTitulo,
    String? heroSubtitulo,
    String? heroImagemUrl,
    String? specialtyTitulo,
    String? specialtyDescricao,
    String? galeriaTitulo,
    String? galeriaSubtitulo,
    List<String>? galeriaImagens,
    String? essenciaTitulo,
    String? essenciaDescricao,
    String? pilaresTitulo,
    List<Pilar>? pilares,
    String? testemunhosTitulo,
    String? prontaBrilharTitulo,
    String? prontaBrilharDescricao,
    String? footerNome,
    String? footerCopyright,
    String? footerRedesSociais,
    String? footerHorario,
    String? footerHorarioTexto,
    String? footerEmail,
    String? footerTelefone,
      String? footerEndereco,
    String? footerWhatsapp,
    String? footerInstagram,
    String? footerTiktok,
    HorarioFuncionamento? horarioFuncionamento,
  }) {
    return SiteConfigModel(
      heroTitulo: heroTitulo ?? this.heroTitulo,
      heroSubtitulo: heroSubtitulo ?? this.heroSubtitulo,
      heroImagemUrl: heroImagemUrl ?? this.heroImagemUrl,
      specialtyTitulo: specialtyTitulo ?? this.specialtyTitulo,
      specialtyDescricao: specialtyDescricao ?? this.specialtyDescricao,
      galeriaTitulo: galeriaTitulo ?? this.galeriaTitulo,
      galeriaSubtitulo: galeriaSubtitulo ?? this.galeriaSubtitulo,
      galeriaImagens: galeriaImagens ?? this.galeriaImagens,
      essenciaTitulo: essenciaTitulo ?? this.essenciaTitulo,
      essenciaDescricao: essenciaDescricao ?? this.essenciaDescricao,
      pilaresTitulo: pilaresTitulo ?? this.pilaresTitulo,
      pilares: pilares ?? this.pilares,
      testemunhosTitulo: testemunhosTitulo ?? this.testemunhosTitulo,
      prontaBrilharTitulo: prontaBrilharTitulo ?? this.prontaBrilharTitulo,
      prontaBrilharDescricao: prontaBrilharDescricao ?? this.prontaBrilharDescricao,
      footerNome: footerNome ?? this.footerNome,
      footerCopyright: footerCopyright ?? this.footerCopyright,
      footerRedesSociais: footerRedesSociais ?? this.footerRedesSociais,
      footerHorario: footerHorario ?? this.footerHorario,
      footerHorarioTexto: footerHorarioTexto ?? this.footerHorarioTexto,
      footerEmail: footerEmail ?? this.footerEmail,
      footerTelefone: footerTelefone ?? this.footerTelefone,
           footerEndereco: footerEndereco ?? this.footerEndereco,
      footerWhatsapp: footerWhatsapp ?? this.footerWhatsapp,
      footerInstagram: footerInstagram ?? this.footerInstagram,
      footerTiktok: footerTiktok ?? this.footerTiktok,
      horarioFuncionamento: horarioFuncionamento ?? this.horarioFuncionamento,
      atualizadoEm: atualizadoEm,
    );
  }
}