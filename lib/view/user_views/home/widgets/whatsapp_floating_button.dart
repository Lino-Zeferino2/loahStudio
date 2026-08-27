import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsappFloatingButton extends StatelessWidget {
  final String numeroWhatsapp; // já sanitizado (só dígitos, com código do país)

  const WhatsappFloatingButton({super.key, required this.numeroWhatsapp});

  Future<void> _abrirWhatsapp() async {
    final mensagem = Uri.encodeComponent('Olá! Vim através do site da Loah Stúdio e gostaria de saber mais.');
    final uri = Uri.parse('https://wa.me/$numeroWhatsapp?text=$mensagem');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    if (numeroWhatsapp.trim().isEmpty) return const SizedBox.shrink();

    return Material(
      color: Color(0xFF25D366),
      shape: const CircleBorder(),
      elevation: 6,
      child: InkWell(
        onTap: _abrirWhatsapp,
        customBorder: const CircleBorder(),
        child: Padding(padding: const EdgeInsets.all(16), child: FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white, size: 28)),
      ),
    );
  }
}