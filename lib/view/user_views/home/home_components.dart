import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/view/user_views/servicos/servicos_page.dart';

// 🔹 Seção Hero (Cabeçalho principal)
class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  void _navigateToServicos(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ServicosPage()));
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    if (isMobile) {
      return _buildMobile(context);
    }
    return _buildDesktop(context);
  }

  Widget _buildMobile(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Imagem no topo
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  "assets/images/loahcapa.png",
                  height: 320,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: -25,
                left: 16,
                child: Container(
                  width: 180,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: RichText(
                    text: TextSpan(
                      text: '"A verdadeira ',
                      style: TextStyle(
                        color: Color(0xFF5A4A42),
                        fontSize: 12,
                      ),
                      children: [
                        TextSpan(
                          text: 'beleza',
                          style: TextStyle(
                            color: Color(0xFFC87F6A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(text: ' nasce de dentro"'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 36),
          // Texto abaixo
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Realce a sua beleza\ncom elegância",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 14, 13, 13),
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                "Serviços de maquilhagem profissional para todos os tipos de eventos.",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7A6A62),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              // Botões em coluna
              Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pinkStrong,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () => _navigateToServicos(context),
                    child: Text(
                      "Agendar",
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 8),
                  TextButton(
                    onPressed: () => _navigateToServicos(context),
                    child: Text(
                      "Conhecer espaço",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF5A4A42),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Lado Esquerdo (Texto + CTA)
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Realce a sua beleza\ncom elegância",
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 14, 13, 13),
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Serviços de maquilhagem profissional para todos os tipos de eventos. "
                  "Sinta-se confiante e única em qualquer ocasião.",
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF7A6A62),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pinkStrong,
                        padding: EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () => _navigateToServicos(context),
                      child: Text(
                        "Agendar",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 20),
                    TextButton(
                      onPressed: () => _navigateToServicos(context),
                      child: Text(
                        "Conhecer espaço",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF5A4A42),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          SizedBox(width: 40),
          // Lado Direito (Imagem)
          Expanded(
            flex: 4,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    "assets/images/loahcapa.png",
                    height: 600,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: -40,
                  left: 30,
                  child: Container(
                    width: 260,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: RichText(
                      text: TextSpan(
                        text: '"A verdadeira ',
                        style: TextStyle(
                          color: Color(0xFF5A4A42),
                          fontSize: 16,
                        ),
                        children: [
                          TextSpan(
                            text: 'beleza',
                            style: TextStyle(
                              color: Color(0xFFC87F6A),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(text: ' nasce de dentro"'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 🔹 Seção Especialidades
class SpecialtySection extends StatelessWidget {
   SpecialtySection({super.key});

  void _navigateToServicos(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ServicosPage()));
  }

  final List<Map<String, String>> specialties = [
    {
      "titulo": "Maquilhagem para Eventos",
      "descricao": "Look profissional para qualquer evento especial",
      "preco": "A partir de €80",
      "imagem": "https://images.unsplash.com/photo-1487412912498-0447578fcca8?w=400",
    },
    {
      "titulo": "Noivas",
      "descricao": "Maquilhagem exclusiva para o seu grande dia",
      "preco": "A partir de €150",
      "imagem": "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=400",
    },
    {
      "titulo": "Sessões Fotográficas",
      "descricao": "Look perfeito para fotos inesquecíveis",
      "preco": "A partir de €100",
      "imagem": "https://images.unsplash.com/photo-1519741497674-611481863552?w=400",
    },
    {
      "titulo": "Maquilhagem Masculina",
      "descricao": "Realce a sua masculinidade com elegância",
      "preco": "A partir de €50",
      "imagem": "https://images.unsplash.com/photo-1607746882042-944635dfe10e?w=400",
    },
    {
      "titulo": "Pacote Noiva + Madrinhas",
      "descricao": "Pacote completo para o casamento",
      "preco": "A partir de €250",
      "imagem": "https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=400",
    },
    {
      "titulo": "Maquilhagem Corporate",
      "descricao": "Look profissional para negócios",
      "preco": "A partir de €60",
      "imagem": "https://images.unsplash.com/photo-1573496359142-b8d87734a7a2?w=400",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    if (isMobile) {
      return _buildMobile(context);
    }
    return _buildDesktop(context);
  }

  Widget _buildMobile(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      color: Color(0xFFF7F4F2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Nossas Especialidades",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5A4A42),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Serviços pensados para realçar a sua beleza em qualquer ocasião.",
                style: TextStyle(fontSize: 14, color: Color(0xFF7A6A62)),
              ),
            ],
          ),
          SizedBox(height: 30),
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: specialties.length,
              itemBuilder: (context, index) {
                final specialty = specialties[index];
                return _specialtyCardMobile(
                  context,
                  specialty["titulo"]!,
                  specialty["descricao"]!,
                  specialty["preco"]!,
                  specialty["imagem"]!,
                );
              },
            ),
          ),
          SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pinkStrong,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
              ),
              onPressed: () => _navigateToServicos(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Ver todos os serviços",
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 60),
      color: Color(0xFFF7F4F2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Nossas Especialidades",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5A4A42),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Serviços pensados para realçar a sua beleza em qualquer ocasião.",
                style: TextStyle(fontSize: 16, color: Color(0xFF7A6A62)),
              ),
            ],
          ),
          SizedBox(height: 40),
          SizedBox(
            height: 340,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: specialties.length,
              itemBuilder: (context, index) {
                final specialty = specialties[index];
                return _specialtyCard(
                  context,
                  specialty["titulo"]!,
                  specialty["descricao"]!,
                  specialty["preco"]!,
                  specialty["imagem"]!,
                );
              },
            ),
          ),
          SizedBox(height: 30),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pinkStrong,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
              ),
              onPressed: () => _navigateToServicos(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Ver todos os serviços",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _specialtyCard(BuildContext context, String titulo, String descricao, String preco, String imagem) {
    return GestureDetector(
      onTap: () => _navigateToServicos(context),
      child: Container(
        width: 260,
        margin: EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                imagem,
                height: 160,
                width: 260,
                fit: BoxFit.cover,
              ),
            ),
            // Conteúdo
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5A4A42),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    descricao,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF7A6A62),
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        preco,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.pinkStrong,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.pinkStrong,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    ));
  }

  Widget _specialtyCardMobile(BuildContext context, String titulo, String descricao, String preco, String imagem) {
    return GestureDetector(
      onTap: () => _navigateToServicos(context),
      child: Container(
        width: 200,
        margin: EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                imagem,
                height: 120,
                width: 200,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5A4A42),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    descricao,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7A6A62),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        preco,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.pinkStrong,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.pinkStrong,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🔹 Seção Galeria Loah
class GaleriaLoahSection extends StatelessWidget {
   GaleriaLoahSection({super.key});

  final List<String> galeriaImagens = [
    "https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=400",
    "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=400",
    "https://images.unsplash.com/photo-1519741497674-611481863552?w=400",
    "https://images.unsplash.com/photo-1487412912498-0447578fcca8?w=400",
    "https://images.unsplash.com/photo-1573496359142-b8d87734a7a2?w=400",
    "https://images.unsplash.com/photo-1607746882042-944635dfe10e?w=400",
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    if (isMobile) {
      return _buildMobile(context);
    }
    return _buildDesktop(context);
  }

  Widget _buildMobile(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Galeria Loah",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5A4A42),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Momentos de beleza que é a essência de cada cliente.",
                style: TextStyle(fontSize: 14, color: Color(0xFF7A6A62)),
              ),
            ],
          ),
          SizedBox(height: 30),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: galeriaImagens.length,
              itemBuilder: (context, index) {
                return _galeriaCardMobile(galeriaImagens[index]);
              },
            ),
          ),
          SizedBox(height: 24),
          Center(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.pinkStrong, width: 2),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {},
              icon: Icon(Icons.camera_alt, color: AppColors.pinkStrong, size: 18),
              label: Text(
                "Ver nosso Instagram",
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.pinkStrong,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 60),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Galeria Loah",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5A4A42),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Momentos de beleza que é a essência de cada cliente.",
                style: TextStyle(fontSize: 16, color: Color(0xFF7A6A62)),
              ),
            ],
          ),
          SizedBox(height: 40),
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: galeriaImagens.length,
              itemBuilder: (context, index) {
                return _galeriaCard(galeriaImagens[index]);
              },
            ),
          ),
          SizedBox(height: 30),
          Center(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.pinkStrong, width: 2),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {},
              icon: Icon(Icons.camera_alt, color: AppColors.pinkStrong),
              label: Text(
                "Ver nosso Instagram",
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.pinkStrong,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _galeriaCard(String imagem) {
    return Container(
      width: 200,
      height: 250,
      margin: EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imagem,
              fit: BoxFit.cover,
            ),
            // Overlay com ícone
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.zoom_in,
                  color: AppColors.pinkStrong,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _galeriaCardMobile(String imagem) {
    return Container(
      width: 140,
      height: 160,
      margin: EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imagem,
              fit: BoxFit.cover,
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.zoom_in,
                  color: AppColors.pinkStrong,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🔹 Seção Loah Essência
class LoahEssenciaSection extends StatelessWidget {
  const LoahEssenciaSection({super.key});

  void _navigateToServicos(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ServicosPage()));
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    if (isMobile) {
      return _buildMobile(context);
    }
    return _buildDesktop(context);
  }

  Widget _buildMobile(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image on top for mobile
          Container(
            height: 280,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset("assets/images/logo.png", fit: BoxFit.cover),
            ),
          ),
          SizedBox(height: 24),
          // Text below
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Loah Essência",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5A4A42),
                  height: 1.1,
                ),
              ),
              SizedBox(height: 12),
              Text(
                "Descubra nossa linha exclusiva de essências naturais que harmonizam corpo e alma.",
                style: TextStyle(fontSize: 14, color: Color(0xFF7A6A62), height: 1.5),
              ),
              SizedBox(height: 24),
              _essenceItemMobile("01", "Serum Iluminador Aura", "Ilumina e revitaliza a pele com extratos naturais."),
              SizedBox(height: 10),
              _essenceItemMobile("02", "Elixir de Harmonia", "Equilibra energias internas com óleos essenciais puros."),
              SizedBox(height: 10),
              _essenceItemMobile("03", "Néctar Regenerador", "Restaura e nutre profundamente a pele cansada."),
              SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pinkStrong,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 4,
                ),
                onPressed: () => _navigateToServicos(context),
                icon: Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                label: Text("Explorar coleção completa", style: TextStyle(fontSize: 14, color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Logo card
              Expanded(
                flex: 4,
                child: Container(
                  height: 500,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 30,
                        offset: Offset(0, 15),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset("assets/images/logo.png", fit: BoxFit.cover),
                  ),
                ),
              ),
              SizedBox(width: 40),
              // Right: Textos
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Loah Essência",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5A4A42),
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Descubra nossa linha exclusiva de essências naturais que harmonizam corpo e alma.",
                      style: TextStyle(fontSize: 18, color: Color(0xFF7A6A62), height: 1.5),
                    ),
                    SizedBox(height: 32),
                    _essenceItem("01", "Serum Iluminador Aura", "Ilumina e revitaliza a pele com extratos naturais."),
                    SizedBox(height: 12),
                    _essenceItem("02", "Elixir de Harmonia", "Equilibra energias internas com óleos essenciais puros."),
                    SizedBox(height: 12),
                    _essenceItem("03", "Néctar Regenerador", "Restaura e nutre profundamente a pele cansada."),
                    SizedBox(height: 32),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pinkStrong,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        elevation: 4,
                      ),
                      onPressed: () => _navigateToServicos(context),
                      icon: Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                      label: Text("Explorar coleção completa", style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _essenceItem(String number, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: Color(0xFFC87F6A), borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(number, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF5A4A42))),
              SizedBox(height: 4),
              Text(desc, style: TextStyle(fontSize: 14, color: Color(0xFF7A6A62), height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _essenceItemMobile(String number, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: Color(0xFFC87F6A), borderRadius: BorderRadius.circular(8)),
          child: Center(child: Text(number, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF5A4A42))),
              SizedBox(height: 2),
              Text(desc, style: TextStyle(fontSize: 12, color: Color(0xFF7A6A62), height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}

// 🔹 Seção Nossos Pilares
class NossosPilaresSection extends StatelessWidget {
   NossosPilaresSection({super.key});

  final List<Map<String, String>> pilares = [
    {
      "icone": "stars",
      "titulo": "Experiência",
      "descricao": "Anos de experiência em maquiagem profissional, com técnicas refinadas e conhecimento profundo.",
    },
    {
      "icone": "favorite",
      "titulo": "Atendimento Personalizado",
      "descricao": "Cada cliente é único. Adaptamos nossos serviços às suas necessidades e preferências.",
    },
    {
      "icone": "verified",
      "titulo": "Produtos de Qualidade",
      "descricao": "Utilizamos apenas produtos premium para garantir resultados impecáveis e duradouros.",
    },
    {
      "icone": "schedule",
      "titulo": "Pontualidade",
      "descricao": "Respeitamos o seu tempo com horários cumpridos e eficiência em cada atendimento.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    if (isMobile) {
      return _buildMobile(context);
    }
    return _buildDesktop(context);
  }

  Widget _buildMobile(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      color: Color(0xFFF7F4F2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Nossos Pilares",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5A4A42),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Os fundamentos que guiam o nosso trabalho e garantem a sua satisfação.",
                style: TextStyle(fontSize: 14, color: Color(0xFF7A6A62)),
              ),
            ],
          ),
          SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: pilares.map((pilar) => _pilarCardMobile(
              context,
              pilar["icone"]!,
              pilar["titulo"]!,
              pilar["descricao"]!,
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 60),
      color: Color(0xFFF7F4F2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Nossos Pilares",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5A4A42),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Os fundamentos que guiam o nosso trabalho e garantem a sua satisfação.",
                style: TextStyle(fontSize: 16, color: Color(0xFF7A6A62)),
              ),
            ],
          ),
          SizedBox(height: 40),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: pilares.map((pilar) => _pilarCard(
              pilar["icone"]!,
              pilar["titulo"]!,
              pilar["descricao"]!,
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _pilarCard(String icone, String titulo, String descricao) {
    IconData iconData;
    switch (icone) {
      case "stars":
        iconData = Icons.stars;
        break;
      case "favorite":
        iconData = Icons.favorite;
        break;
      case "verified":
        iconData = Icons.verified;
        break;
      case "schedule":
        iconData = Icons.schedule;
        break;
      default:
        iconData = Icons.star;
    }

    return Container(
      width: 260,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícone
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.pinkStrong.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              iconData,
              color: AppColors.pinkStrong,
              size: 26,
            ),
          ),
          SizedBox(height: 16),
          // Título
          Text(
            titulo,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5A4A42),
            ),
          ),
          SizedBox(height: 8),
          // Descrição
          Text(
            descricao,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7A6A62),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pilarCardMobile(BuildContext context, String icone, String titulo, String descricao) {
    IconData iconData;
    switch (icone) {
      case "stars":
        iconData = Icons.stars;
        break;
      case "favorite":
        iconData = Icons.favorite;
        break;
      case "verified":
        iconData = Icons.verified;
        break;
      case "schedule":
        iconData = Icons.schedule;
        break;
      default:
        iconData = Icons.star;
    }

    return Container(
      width: (MediaQuery.of(context).size.width - 52) / 2,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.pinkStrong.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              iconData,
              color: AppColors.pinkStrong,
              size: 22,
            ),
          ),
          SizedBox(height: 12),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5A4A42),
            ),
          ),
          SizedBox(height: 6),
          Text(
            descricao,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF7A6A62),
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// 🔹 Seção Depoimentos
class TestemunhosSection extends StatelessWidget {
   TestemunhosSection({super.key});

  final List<Map<String, String>> depoimentos = [
    {
      "nome": "Sofia Martins",
      "categoria": "Noiva",
      "mensagem": "Fiquei absolutamente maravilhada com o serviço. A maquiagem foi impecável e durou toda a festa!",
      "imagem": "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e",
    },
    {
      "nome": "Ana Rita",
      "categoria": "Evento Corporativo",
      "mensagem": "Profissionalismo excecional! O resultado foi perfeito.",
      "imagem": "https://images.unsplash.com/photo-1487412912498-0447578fcca8",
    },
    {
      "nome": "Carla Nascimento",
      "categoria": "Sessão Fotográfica",
      "mensagem": "O trabalho da Loah é simplesmente deslumbrante!",
      "imagem": "https://images.unsplash.com/photo-1519741497674-611481863552",
    },
    {
      "nome": "Patrícia Silva",
      "categoria": "Noiva",
      "mensagem": "Recomendo a 100%! Muito carinho e profissionalismo.",
      "imagem": "https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    if (isMobile) {
      return _buildMobile(context);
    }
    return _buildDesktop(context);
  }

  Widget _buildMobile(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      color: Color(0xFFFAF8F6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "O que dizem os nossos clientes",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF5A4A42)),
          ),
          SizedBox(height: 8),
          Text("Depoimentos de quem já confiou no nosso trabalho.", style: TextStyle(fontSize: 14, color: Color(0xFF7A6A62))),
          SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: depoimentos.length,
              itemBuilder: (context, index) {
                return _depoimentoCardMobile(context, depoimentos[index]["nome"]!, depoimentos[index]["categoria"]!, depoimentos[index]["mensagem"]!, depoimentos[index]["imagem"]!);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 60),
      color: Color(0xFFFAF8F6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "O que dizem os nossos clientes",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF5A4A42)),
          ),
          SizedBox(height: 10),
          Text("Depoimentos de quem já confiou no nosso trabalho.", style: TextStyle(fontSize: 16, color: Color(0xFF7A6A62))),
          SizedBox(height: 40),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: depoimentos.map((d) => _depoimentoCard(d["nome"]!, d["categoria"]!, d["mensagem"]!, d["imagem"]!)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _depoimentoCard(String nome, String categoria, String mensagem, String imagem) {
    return Container(
      width: 340,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.format_quote, color: Color(0xFFC87F6A), size: 32),
              Spacer(),
              Row(children: List.generate(5, (i) => Icon(Icons.star, color: Color(0xFFFFB800), size: 18))),
            ],
          ),
          SizedBox(height: 16),
          Text(mensagem, style: TextStyle(fontSize: 15, color: Color(0xFF5A4A42), height: 1.6, fontStyle: FontStyle.italic)),
          SizedBox(height: 20),
          Container(height: 1, color: Color(0xFFEDEAE8)),
          SizedBox(height: 16),
          Row(
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(30), child: Image.network(imagem, width: 50, height: 50, fit: BoxFit.cover)),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nome, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF5A4A42))),
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Color(0xFFFAF0EB), borderRadius: BorderRadius.circular(12)),
                    child: Text(categoria, style: TextStyle(fontSize: 12, color: Color(0xFFC87F6A))),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _depoimentoCardMobile(BuildContext context, String nome, String categoria, String mensagem, String imagem) {
    return Container(
      width: 260,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.format_quote, color: Color(0xFFC87F6A), size: 24),
              Spacer(),
              Row(children: List.generate(5, (i) => Icon(Icons.star, color: Color(0xFFFFB800), size: 14))),
            ],
          ),
          SizedBox(height: 12),
          Text(mensagem, style: TextStyle(fontSize: 13, color: Color(0xFF5A4A42), height: 1.5, fontStyle: FontStyle.italic), maxLines: 3, overflow: TextOverflow.ellipsis),
          SizedBox(height: 16),
          Container(height: 1, color: Color(0xFFEDEAE8)),
          SizedBox(height: 12),
          Row(
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(imagem, width: 36, height: 36, fit: BoxFit.cover)),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nome, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF5A4A42))),
                  SizedBox(height: 2),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Color(0xFFFAF0EB), borderRadius: BorderRadius.circular(8)),
                    child: Text(categoria, style: TextStyle(fontSize: 10, color: Color(0xFFC87F6A))),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 🔹 Seção Pronta para Brilhar
class ProntaBrilharSection extends StatelessWidget {
  const ProntaBrilharSection({super.key});

  void _navigateToServicos(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ServicosPage()));
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    if (isMobile) {
      return _buildMobile(context);
    }
    return _buildDesktop(context);
  }

  Widget _buildMobile(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF5A4A42), Color(0xFF3D3230)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Text(
            "Pronta para brilhar?",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            "Agende já o seu momento de beleza e conquiste o look perfeito.\nNossa equipa está pronta para tornar o seu visual inesquecível.",
            style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9), height: 1.5),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pinkStrong,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 6,
            ),
            onPressed: () => _navigateToServicos(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Agendar agora", style: TextStyle(fontSize: 16, color: Colors.white)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, color: Colors.white, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 80),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF5A4A42), Color(0xFF3D3230)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Text(
            "Pronta para brilhar?",
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Text(
            "Agende já o seu momento de beleza e conquiste o look perfeito.\nNossa equipa está pronta para tornar o seu visual inesquecível.",
            style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.9), height: 1.6),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pinkStrong,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 8,
            ),
            onPressed: () => _navigateToServicos(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Agendar agora", style: TextStyle(fontSize: 18, color: Colors.white)),
                SizedBox(width: 10),
                Icon(Icons.arrow_forward, color: Colors.white, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 🔹 Seção Footer
class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    if (isMobile) {
      return _buildMobile(context);
    }
    return _buildDesktop(context);
  }

  Widget _buildMobile(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      color: Color(0xFFF5F5F5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("LOAH STÚDIO", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF5A4A42))),
          SizedBox(height: 10),
          Text("© 2026 Loah Stúdio.\nTodos os direitos reservados.", style: TextStyle(fontSize: 12, color: Color(0xFF7A6A62), height: 1.5)),
          SizedBox(height: 20),
          Text("Redes Sociais", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF5A4A42))),
          SizedBox(height: 10),
          Row(children: [
            _socialIcon(Icons.camera_alt_outlined),
            SizedBox(width: 10),
            _socialIcon(Icons.facebook_outlined),
            SizedBox(width: 10),
            _socialIcon(Icons.alternate_email),
          ]),
          SizedBox(height: 20),
          Text("Horário", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF5A4A42))),
          SizedBox(height: 10),
          Text(
            "Seg - Sex: 9h às 19h\nSábado: 9h às 14h\nDomingo: Encerrado",
            style: TextStyle(fontSize: 12, color: Color(0xFF7A6A62), height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 40),
      color: Color(0xFFF5F5F5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("LOAH STÚDIO", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF5A4A42))),
                SizedBox(height: 12),
                Text("© 2026 Loah Stúdio.\nTodos os direitos reservados.", style: TextStyle(fontSize: 14, color: Color(0xFF7A6A62), height: 1.5)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Redes Sociais", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF5A4A42))),
                SizedBox(height: 12),
                Row(children: [
                  _socialIcon(Icons.camera_alt_outlined),
                  SizedBox(width: 12),
                  _socialIcon(Icons.facebook_outlined),
                  SizedBox(width: 12),
                  _socialIcon(Icons.alternate_email),
                ]),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Horário", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF5A4A42))),
                SizedBox(height: 12),
                Text(
                  "Seg - Sex: 9h às 19h\nSábado: 9h às 14h\nDomingo: Encerrado",
                  style: TextStyle(fontSize: 14, color: Color(0xFF7A6A62), height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialIcon(IconData icon) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(color: Color(0xFFE8E4E2), borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: Color(0xFF5A4A42), size: 20),
    );
  }
}