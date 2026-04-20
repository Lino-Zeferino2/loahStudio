import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/view/user_views/home/home_page.dart';
import 'package:loahstudio/view/user_views/agendamento/agendamento_page.dart';
import 'package:loahstudio/view/user_views/produtos/produtos_page.dart';

class ServicosPage extends StatefulWidget {
  @override
  _ServicosPageState createState() => _ServicosPageState();
}

class _ServicosPageState extends State<ServicosPage> {
  int selectedIndex = 1;
  int? hoverIndex;
  Map<String, String>? selectedServico;
  DateTime? selectedDate;
  String? selectedTime;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final telefoneController = TextEditingController();
  final observacaoController = TextEditingController();

  final List<String> menuItems = [
    "Início",
    "Serviços",
    "Produtos",
    "Agendamento",
  ];

  final List<Map<String, String>> servicos = [
    {
      "titulo": "Maquilhagem para Eventos",
      "descricao": "Maquilhagem profissional adaptada ao seu evento. Destacamos a sua beleza natural com técnicas personalizadas.",
      "preço": "€80",
      "duracao": "1h30",
      "tipo": "Básico",
      "imagem": "https://images.unsplash.com/photo-1487412912498-0447578fcca8",
    },
    {
      "titulo": "Maquilhagem Noiva",
      "descricao": "Maquilhagem exclusiva para noivas, com teste prévio e retoques para o grande dia.",
      "preço": "€150",
      "duracao": "2h",
      "tipo": "Premium",
      "imagem": "https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e",
    },
    {
      "titulo": "Sessão Fotográfica",
      "descricao": "Look perfeito para sessões de fotos, com estilo personalizado conforme o tema.",
      "preço": "€100",
      "duracao": "1h30",
      "tipo": "Premium",
      "imagem": "https://images.unsplash.com/photo-1519741497674-611481863552",
    },
    {
      "titulo": "Maquilhagem Masculina",
      "descricao": "Maquilhagem masculina discreta para eventos profissionais e sociais.",
      "preço": "€50",
      "duracao": "45min",
      "tipo": "Básico",
      "imagem": "https://images.unsplash.com/photo-1607746882042-944635dfe10e",
    },
    {
      "titulo": "Pacote Noiva + Madrinha",
      "descricao": "Maquilhagem da noiva + 2 madrinhas, com teste prévio incluído.",
      "preço": "€250",
      "duracao": "3h",
      "tipo": "Premium",
      "imagem": "https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9",
    },
    {
      "titulo": "Maquilhagem Corporate",
      "descricao": "Look profissional para apresentações, reuniões e eventos corporativos.",
      "preço": "€60",
      "duracao": "1h",
      "tipo": "Básico",
      "imagem": "https://images.unsplash.com/photo-1573496359142-b8d87734a7a2",
    },
  ];

  // Datas disponíveis (próximos 14 dias)
  final List<DateTime> availableDates = List.generate(
    14,
    (i) => DateTime.now().add(Duration(days: i + 1)),
  );

  // Horários disponíveis
  final List<String> availableTimes = [
    "09:00",
    "10:00",
    "11:00",
    "14:00",
    "15:00",
    "16:00",
    "17:00",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text(
                "LOAH STÚDIO",
                style: TextStyle(
                  color: AppColors.brown,
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                  letterSpacing: 3,
                ),
              ),
            ),
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
                        } else if (index == 2) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => ProdutosPage()));
                        } else if (index == 3) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => AgendamentoPage()));
                        } else {
                          setState(() => selectedIndex = index);
                        }
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        margin: EdgeInsets.symmetric(horizontal: 12),
                        padding: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: isSelected
                              ? Border(bottom: BorderSide(color: AppColors.pinkNude, width: 2))
                              : null,
                        ),
                        child: Text(
                          menuItems[index],
                          style: TextStyle(
                            color: isSelected || isHover ? AppColors.pinkNude : AppColors.brown,
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pinkStrong,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AgendamentoPage())),
                  child: Text("Agendar", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 40),
            // Secção Título + Intro
            _introSection(),
            SizedBox(height: 60),
            // Lista de Serviços
            _servicosList(),
            SizedBox(height: 60),
            // Secção Calendário
            _calendarSection(),
            SizedBox(height: 60),
            // Secção Formulário
            _formSection(),
            SizedBox(height: 100),
            // Footer
            _footerSection(),
          ],
        ),
      ),
    );
  }

  Widget _introSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Os nossos serviços",
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5A4A42),
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Oferecemos serviços de maquilhagem profissional adaptados às suas necessidades.\nCada tratamento é personalizado para destacar a sua beleza única.",
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF7A6A62),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 40),
          Expanded(
            flex: 4,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
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
          ),
        ],
      ),
    );
  }

  Widget _servicosList() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Escolha o seu serviço",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5A4A42),
            ),
          ),
          SizedBox(height: 30),
          ...servicos.map((servico) => _servicoCard(
            servico["titulo"]!,
            servico["descricao"]!,
            servico["preço"]!,
            servico["duracao"]!,
            servico["tipo"]!,
            servico["imagem"]!,
          )),
        ],
      ),
    );
  }

  Widget _servicoCard(String titulo, String descricao, String preco, String duracao, String tipo, String imagem) {
    final isPremium = tipo == "Premium";
    final isSelected = selectedServico?["titulo"] == titulo;
    return GestureDetector(
      onTap: () => setState(() => selectedServico = {
        "titulo": titulo,
        "preço": preco,
        "descricao": descricao,
        "duracao": duracao,
        "tipo": tipo,
        "imagem": imagem,
      }),
      child: Container(
        margin: EdgeInsets.only(bottom: 24),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: AppColors.pinkStrong, width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imagem,
                width: 180,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          titulo,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5A4A42),
                          ),
                        ),
                      ),
                      Text(
                        preco,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.pinkStrong,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    descricao,
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF7A6A62),
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(0xFFF7F4F2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time, size: 16, color: Color(0xFF5A4A42)),
                            SizedBox(width: 6),
                            Text(duracao, style: TextStyle(fontSize: 14, color: Color(0xFF5A4A42))),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isPremium ? AppColors.pinkStrong : Color(0xFF5A4A42),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          tipo,
                          style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.pinkStrong, width: 2),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    onPressed: () => setState(() => selectedServico = {
                      "titulo": titulo,
                      "preço": preco,
                      "descricao": descricao,
                      "duracao": duracao,
                      "tipo": tipo,
                      "imagem": imagem,
                    }),
                    child: Text(
                      "Selecionar",
                      style: TextStyle(fontSize: 16, color: AppColors.pinkStrong),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _calendarSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 60),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Selecione a Data",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5A4A42),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: availableDates.map((date) {
                      final isSelected = selectedDate?.day == date.day && selectedDate?.month == date.month;
                      return GestureDetector(
                        onTap: () => setState(() => selectedDate = date),
                        child: Container(
                          width: 70,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.pinkStrong : Color(0xFFF7F4F2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _getDayName(date.weekday),
                                style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Color(0xFF7A6A62)),
                              ),
                              SizedBox(height: 4),
                              Text(
                                date.day.toString(),
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Color(0xFF5A4A42)),
                              ),
                              SizedBox(height: 4),
                              Text(
                                _getMonthName(date.month),
                                style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Color(0xFF7A6A62)),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 40),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Selecione o Horário",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5A4A42),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: availableTimes.map((time) {
                      final isSelected = selectedTime == time;
                      return GestureDetector(
                        onTap: () => setState(() => selectedTime = time),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.pinkStrong : Color(0xFFF7F4F2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            time,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : Color(0xFF5A4A42),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _formSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Dados Pessoais",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5A4A42),
            ),
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildTextField(controller: nameController, label: "Nome", hint: "Digite o seu nome completo"),
                SizedBox(height: 20),
                _buildTextField(controller: emailController, label: "Email", hint: "Digite o seu email", keyboardType: TextInputType.emailAddress),
                SizedBox(height: 20),
                _buildTextField(controller: telefoneController, label: "Número de Telemóvel", hint: "Digite o seu número", keyboardType: TextInputType.phone),
                SizedBox(height: 20),
                _buildTextField(controller: observacaoController, label: "Observação (opcional)", hint: "Alguma informação adicional?", maxLines: 3),
                SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pinkStrong,
                      padding: EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 4,
                    ),
                    onPressed: () {
                      if (selectedServico != null && selectedDate != null && selectedTime != null &&
                          nameController.text.isNotEmpty && emailController.text.isNotEmpty && telefoneController.text.isNotEmpty) {
                        _showConfirmationDialog();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Preencha todos os campos e selecione um serviço"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Text("Confirmar Agendamento", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF5A4A42))),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Color(0xFF7A6A62)),
            filled: true,
            fillColor: Color(0xFFF7F4F2),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.pinkStrong, width: 2)),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Agendamento Confirmado!", style: TextStyle(color: Color(0xFF5A4A42))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Serviço: ${selectedServico?["titulo"]}"),
            SizedBox(height: 8),
            Text("Data: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"),
            SizedBox(height: 8),
            Text("Hora: $selectedTime"),
            SizedBox(height: 8),
            Text("Nome: ${nameController.text}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: Text("OK", style: TextStyle(color: AppColors.pinkStrong)),
          ),
        ],
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = ["Seg", "Ter", "Qua", "Qui", "Sex", "Sáb", "Dom"];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = ["", "Jan", "Fev", "Mar", "Abr", "Mai", "Jun", "Jul", "Ago", "Set", "Out", "Nov", "Dez"];
    return months[month];
  }

  Widget _footerSection() {
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
                Text("Seg - Sex: 9h às 19h\nSábado: 9h às 14h\nDomingo: Encerrado", style: TextStyle(fontSize: 14, color: Color(0xFF7A6A62), height: 1.6)),
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