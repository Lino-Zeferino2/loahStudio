class HomeDefaults {
  HomeDefaults._();

  static const heroTitulo = 'Realce a sua beleza\ncom elegância';
  static const heroSubtitulo =
      'Serviços de maquilhagem profissional para todos os tipos de eventos. Sinta-se confiante e única em qualquer ocasião.';

  static const specialtyTitulo = 'Nossas Especialidades';
  static const specialtyDescricao = 'Serviços pensados para realçar a sua beleza em qualquer ocasião.';

  static const galeriaTitulo = 'Galeria Loah';
  static const galeriaSubtitulo = 'Momentos de beleza que são a essência de cada cliente.';
  static const List<String> galeriaImagensFallback = [
    "https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=400",
    "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=400",
    "https://images.unsplash.com/photo-1519741497674-611481863552?w=400",
    "https://images.unsplash.com/photo-1487412912498-0447578fcca8?w=400",
    "https://images.unsplash.com/photo-1573496359142-b8d87734a7a2?w=400",
    "https://images.unsplash.com/photo-1607746882042-944635dfe10e?w=400",
  ];

  static const essenciaTitulo = 'Loah Essência';
  static const essenciaDescricao =
      'Descubra nossa linha exclusiva de essências naturais que harmonizam corpo e alma.';

  static const pilaresTitulo = 'Nossos Pilares';
  static const List<Map<String, String>> pilaresFallback = [
    {'titulo': 'Experiência', 'descricao': 'Anos de experiência em maquiagem profissional, com técnicas refinadas e conhecimento profundo.'},
    {'titulo': 'Atendimento Personalizado', 'descricao': 'Cada cliente é único. Adaptamos nossos serviços às suas necessidades e preferências.'},
    {'titulo': 'Produtos de Qualidade', 'descricao': 'Utilizamos apenas produtos premium para garantir resultados impecáveis e duradouros.'},
    {'titulo': 'Pontualidade', 'descricao': 'Respeitamos o seu tempo com horários cumpridos e eficiência em cada atendimento.'},
  ];

  static const prontaBrilharTitulo = 'Pronta para brilhar?';
  static const prontaBrilharDescricao =
      'Agende já o seu momento de beleza e conquiste o look perfeito.\nNossa equipa está pronta para tornar o seu visual inesquecível.';

  static const footerNome = 'LOAH STÚDIO';
  static const footerCopyright = '© 2026 Loah Stúdio. Todos os direitos reservados.';
  static const footerRedesSociais = 'Redes Sociais';
  static const footerHorario = 'Horário';
  static const footerHorarioTexto = 'Seg - Sex: 9h às 19h\nSábado: 9h às 14h\nDomingo: Encerrado';

  static String valorOuPadrao(String? valor, String padrao) {
    if (valor == null || valor.trim().isEmpty) return padrao;
    return valor;
  }
}