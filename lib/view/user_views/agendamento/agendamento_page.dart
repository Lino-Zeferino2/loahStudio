import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/constants/responsive.dart';
import 'package:loahstudio/view/user_views/home/home_page.dart';
import 'package:loahstudio/view/user_views/servicos/servicos_page.dart';
import 'package:loahstudio/view/user_views/produtos/produtos_page.dart';

class AgendamentoPage extends StatefulWidget {
  @override
  _AgendamentoPageState createState() => _AgendamentoPageState();
}

class _AgendamentoPageState extends State<AgendamentoPage> {
  int selectedIndex = 3;
  int? hoverIndex;
  final emailController = TextEditingController();
  bool isLoading = false;
  bool hasSearched = false;

  final List<String> menuItems = [
    "Início",
    "Serviços",
    "Produtos",
    "Agendamento",
  ];

  // Simulação de dados - em produção viriam de uma API/banco de dados
  final List<Map<String, String>> _mockAgendamentos = [
    {
      "servico": "Maquilhagem Noiva",
      "data": "25/04/2026",
      "hora": "14:00",
      "estado": "Pendente",
      "preco": "€150",
    },
    {
      "servico": "Maquilhagem para Eventos",
      "data": "20/04/2026",
      "hora": "10:00",
      "estado": "Confirmado",
      "preco": "€80",
    },
    {
      "servico": "Sessão Fotográfica",
      "data": "10/03/2026",
      "hora": "15:00",
      "estado": "Concluido",
      "preco": "€100",
    },
  ];

  List<Map<String, String>> get _agendamentosFiltrados {
    if (!hasSearched) return [];
    // Filtra apenas Pendente e Confirmado para mostrar
    return _mockAgendamentos
        .where((a) => a["estado"] != "Concluido")
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final headerTitleSize = ResponsiveHelper.headerTitleSize(context);

    return Scaffold(
      endDrawer: isMobile ? _buildMobileDrawer() : null,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 600;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    "LOAH STÚDIO",
                    style: TextStyle(
                      color: AppColors.brown,
                      fontWeight: FontWeight.w600,
                      fontSize: headerTitleSize,
                      letterSpacing: 3,
                    ),
                  ),
                ),
                if (!isCompact)
                  Row(
                    children: [
                      ...List.generate(menuItems.length, (index) {
                        final isSelected = selectedIndex == index;
                        final isHover = hoverIndex == index;
                        return MouseRegion(
                          onEnter: (_) => setState(() => hoverIndex = index),
                          onExit: (_) => setState(() => hoverIndex = null),
                          child: GestureDetector(
                            onTap: () {
                              if (index == 0) {
                                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => HomePage()), (route) => route.isFirst);
                              } else if (index == 1) {
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ServicosPage()));
                              } else if (index == 2) {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => ProdutosPage()));
                              } else {
                                setState(() => selectedIndex = index);
                              }
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              margin: EdgeInsets.symmetric(horizontal: isMobile ? 8.0 : 12.0),
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              decoration: BoxDecoration(
                                border: isSelected
                                    ? Border(bottom: BorderSide(color: AppColors.pinkNude, width: 2))
                                    : null,
                              ),
                              child: Text(
                                menuItems[index],
                                style: TextStyle(
                                  color: isSelected || isHover ? AppColors.pinkNude : AppColors.brown,
                                  fontSize: isMobile ? 14.0 : 16.0,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                      SizedBox(width: isMobile ? 10.0 : 20.0),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.pinkStrong,
                          padding: EdgeInsets.symmetric(horizontal: isMobile ? 14.0 : 20.0, vertical: isMobile ? 8.0 : 12.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ServicosPage())),
                        child: Text("Agendar", style: TextStyle(color: Colors.white, fontSize: isMobile ? 13.0 : 14.0)),
                      ),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: isMobile ? 20.0 : 40.0),
            // Secção Título
            _introSection(),
            SizedBox(height: isMobile ? 30.0 : 60.0),
            // Secção Buscar Email
            _searchSection(),
            SizedBox(height: isMobile ? 30.0 : 40.0),
            // Lista de Agendamentos
            if (hasSearched) _agendamentosList(),
            SizedBox(height: isMobile ? 50.0 : 100.0),
            // Footer
            _footerSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileDrawer() {
    return Container(
      width: 280,
      padding: EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("LOAH STÚDIO", style: TextStyle(color: AppColors.brown, fontWeight: FontWeight.w600, fontSize: 18, letterSpacing: 2)),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.close, color: AppColors.brown),
              ),
            ],
          ),
          SizedBox(height: 30),
          Divider(),
          SizedBox(height: 20),
          ...List.generate(menuItems.length, (index) {
            final isSelected = selectedIndex == index;
            return ListTile(
              leading: Icon(index == 0 ? Icons.home_outlined : index == 1 ? Icons.spa_outlined : index == 2 ? Icons.shopping_bag_outlined : Icons.calendar_today_outlined, color: isSelected ? AppColors.pinkStrong : AppColors.brown),
              title: Text(menuItems[index], style: TextStyle(color: isSelected ? AppColors.pinkStrong : AppColors.brown, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                if (index == 0) {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => HomePage()), (route) => route.isFirst);
                } else if (index == 1) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ServicosPage()));
                } else if (index == 2) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ProdutosPage()));
                } else {
                  setState(() => selectedIndex = index);
                }
              },
            );
          }),
          Spacer(),
          Divider(),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.pinkStrong, padding: EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => ServicosPage()));
              },
              child: Text("Agendar", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _introSection() {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20.0 : 60.0),
      child: Column(
        children: [
          Text(
            "Os meus Agendamentos",
            style: TextStyle(
              fontSize: isMobile ? 28.0 : 48.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5A4A42),
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 12.0 : 20.0),
          Text(
            "Consulte o histórico dos seus agendamentos.\nCanceled agendamentos aparecem listados abaixo.",
            style: TextStyle(
              fontSize: isMobile ? 14.0 : 18.0,
              color: Color(0xFF7A6A62),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _searchSection() {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 60.0),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 16.0 : 30.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Digite o seu email",
              style: TextStyle(
                fontSize: isMobile ? 16.0 : 18.0,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5A4A42),
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Utilizamos o seu email para encontrar os seus agendamentos.",
              style: TextStyle(
                fontSize: isMobile ? 12.0 : 14.0,
                color: Color(0xFF7A6A62),
              ),
            ),
            SizedBox(height: isMobile ? 16.0 : 20.0),
            // Mobile: column, Desktop: row
            isMobile
                ? Column(
                    children: [
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "Digite o seu email",
                          hintStyle: TextStyle(color: Color(0xFF7A6A62)),
                          filled: true,
                          fillColor: Color(0xFFF7F4F2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.pinkStrong, width: 2),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                      SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.pinkStrong,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (emailController.text.isNotEmpty &&
                                      emailController.text.contains("@")) {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    // Simula busca
                                    Future.delayed(Duration(seconds: 1), () {
                                      setState(() {
                                        isLoading = false;
                                        hasSearched = true;
                                      });
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Digite um email válido"),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                          child: isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  "Buscar",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "Digite o seu email",
                            hintStyle: TextStyle(color: Color(0xFF7A6A62)),
                            filled: true,
                            fillColor: Color(0xFFF7F4F2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.pinkStrong, width: 2),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.pinkStrong,
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isLoading
                            ? null
                            : () {
                                if (emailController.text.isNotEmpty &&
                                    emailController.text.contains("@")) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  // Simula busca
                                  Future.delayed(Duration(seconds: 1), () {
                                    setState(() {
                                      isLoading = false;
                                      hasSearched = true;
                                    });
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Digite um email válido"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                        child: isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                "Buscar",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _agendamentosList() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final agendamentos = _agendamentosFiltrados;

    if (agendamentos.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 60.0),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 24.0 : 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Icon(
                Icons.event_available,
                size: isMobile ? 40.0 : 60.0,
                color: Color(0xFF7A6A62),
              ),
              SizedBox(height: 16),
              Text(
                "Nenhum agendamento encontrado",
                style: TextStyle(
                  fontSize: isMobile ? 16.0 : 18.0,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5A4A42),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                "Não tem agendamentos pendentes ou confirmados.",
                style: TextStyle(
                  fontSize: isMobile ? 12.0 : 14.0,
                  color: Color(0xFF7A6A62),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 60.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Histórico de Agendamentos",
            style: TextStyle(
              fontSize: isMobile ? 18.0 : 20.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5A4A42),
            ),
          ),
          SizedBox(height: isMobile ? 12.0 : 20.0),
          ...agendamentos.map((agendamento) => _agendamentoCard(
            agendamento["servico"]!,
            agendamento["data"]!,
            agendamento["hora"]!,
            agendamento["estado"]!,
            agendamento["preco"]!,
          )),
        ],
      ),
    );
  }

  Widget _agendamentoCard(String servico, String data, String hora, String estado, String preco) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isPendente = estado == "Pendente";
    final isConfirmado = estado == "Confirmado";

    if (isMobile) {
      // Mobile card layout
      return Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Ícone de serviço
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Color(0xFFF7F4F2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.face,
                    size: 22,
                    color: AppColors.pinkStrong,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        servico,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5A4A42),
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 12, color: Color(0xFF7A6A62)),
                          SizedBox(width: 4),
                          Text(
                            data,
                            style: TextStyle(fontSize: 12, color: Color(0xFF7A6A62)),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.access_time, size: 12, color: Color(0xFF7A6A62)),
                          SizedBox(width: 4),
                          Text(
                            hora,
                            style: TextStyle(fontSize: 12, color: Color(0xFF7A6A62)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      preco,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.pinkStrong,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isPendente
                            ? Color(0xFFFF9800)
                            : isConfirmado
                                ? Color(0xFF4CAF50)
                                : Color(0xFF9E9E9E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        estado,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                // Botão Cancelar (só para Pendente ou Confirmado)
                if (isPendente || isConfirmado)
                  GestureDetector(
                    onTap: () => _showCancelDialog(servico, data, hora),
                    child: Text(
                      "Cancelar",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
    }

    // Desktop card layout
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ícone de serviço
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Color(0xFFF7F4F2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.face,
              size: 30,
              color: AppColors.pinkStrong,
            ),
          ),
          SizedBox(width: 20),
          // Informações
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  servico,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5A4A42),
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Color(0xFF7A6A62)),
                    SizedBox(width: 6),
                    Text(
                      data,
                      style: TextStyle(fontSize: 14, color: Color(0xFF7A6A62)),
                    ),
                    SizedBox(width: 16),
                    Icon(Icons.access_time, size: 16, color: Color(0xFF7A6A62)),
                    SizedBox(width: 6),
                    Text(
                      hora,
                      style: TextStyle(fontSize: 14, color: Color(0xFF7A6A62)),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      preco,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.pinkStrong,
                      ),
                    ),
                    SizedBox(width: 16),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPendente
                            ? Color(0xFFFF9800)
                            : isConfirmado
                                ? Color(0xFF4CAF50)
                                : Color(0xFF9E9E9E),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        estado,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Botão Cancelar (só para Pendente ou Confirmado)
          if (isPendente || isConfirmado)
            TextButton(
              onPressed: () => _showCancelDialog(servico, data, hora),
              child: Text(
                "Cancelar",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showCancelDialog(String servico, String data, String hora) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Cancelar Agendamento?"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Serviço: $servico"),
            SizedBox(height: 8),
            Text("Data: $data às $hora"),
            SizedBox(height: 16),
            Text(
           "Tem a certeza que deseja cancelar este agendamento?",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Não", style: TextStyle(color: Color(0xFF7A6A62))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Agendamento cancelado com sucesso!"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text("Sim, cancelar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _footerSection() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final horizontalPad = isMobile ? 16.0 : 60.0;

    if (isMobile) {
      // Mobile: coluna
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 24.0),
        color: Color(0xFFF5F5F5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("LOAH STÚDIO", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Color(0xFF5A4A42))),
            SizedBox(height: 8),
            Text("© 2026 Loah Stúdio.\nTodos os direitos reservados.", style: TextStyle(fontSize: 12.0, color: Color(0xFF7A6A62), height: 1.5)),
            SizedBox(height: 16),
            Text("Redes Sociais", style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600, color: Color(0xFF5A4A42))),
            SizedBox(height: 8),
            Row(children: [
              _socialIcon(Icons.camera_alt_outlined),
              SizedBox(width: 8),
              _socialIcon(Icons.facebook_outlined),
              SizedBox(width: 8),
              _socialIcon(Icons.alternate_email),
            ]),
            SizedBox(height: 16),
            Text("Horário", style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600, color: Color(0xFF5A4A42))),
            SizedBox(height: 8),
            Text("Seg - Sex: 9h às 19h\nSábado: 9h às 14h\nDomingo: Encerrado", style: TextStyle(fontSize: 12.0, color: Color(0xFF7A6A62), height: 1.6)),
          ],
        ),
      );
    }

    // Desktop: row
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 40.0),
      color: Color(0xFFF5F5F5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("LOAH STÚDIO", style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Color(0xFF5A4A42))),
                SizedBox(height: 12),
                Text("© 2026 Loah Stúdio.\nTodos os direitos reservados.", style: TextStyle(fontSize: 14.0, color: Color(0xFF7A6A62), height: 1.5)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Redes Sociais", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600, color: Color(0xFF5A4A42))),
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
                Text("Horário", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600, color: Color(0xFF5A4A42))),
                SizedBox(height: 12),
                Text(
                  "Seg - Sex: 9h às 19h\nSábado: 9h às 14h\nDomingo: Encerrado",
                  style: TextStyle(fontSize: 14.0, color: Color(0xFF7A6A62), height: 1.6),
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