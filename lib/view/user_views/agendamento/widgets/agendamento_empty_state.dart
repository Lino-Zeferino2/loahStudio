import 'package:flutter/material.dart';

class AgendamentoEmptyState extends StatelessWidget {
  const AgendamentoEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 60.0),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 24.0 : 40),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            Icon(Icons.event_available, size: isMobile ? 40.0 : 60.0, color: const Color(0xFF7A6A62)),
            const SizedBox(height: 16),
            Text(
              "Nenhum agendamento encontrado",
              style: TextStyle(
                fontSize: isMobile ? 16.0 : 18.0,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF5A4A42),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "Não tem agendamentos pendentes ou confirmados.",
              style: TextStyle(fontSize: 12.0, color: Color(0xFF7A6A62)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}