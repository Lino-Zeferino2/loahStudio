import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:loahstudio/constants/colors.dart';
import 'package:loahstudio/constants/responsive.dart';
import 'package:loahstudio/model/site_config_model.dart';
import 'package:loahstudio/view/user_views/home/widgets/home_defaults.dart';

class FooterSection extends StatelessWidget {
  final SiteConfigModel config;
  const FooterSection({super.key, required this.config});

  Future<void> _abrirLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _abrirWhatsapp() {
    final numero = config.footerWhatsapp.replaceAll(RegExp(r'[^0-9]'), '');
    if (numero.isEmpty) return;
    _abrirLink('https://wa.me/$numero');
  }

  List<Widget> _buildIconesRedesSociais(bool isMobile) {
    final icones = <Widget>[];
    final espaco = SizedBox(width: isMobile ? 10 : 12);

    if (config.footerWhatsapp.trim().isNotEmpty) {
      icones.add(_socialIcon(FaIcon(FontAwesomeIcons.whatsapp, color: AppColors.brown, size: 18), _abrirWhatsapp));
    }
    if (config.footerInstagram.trim().isNotEmpty) {
      if (icones.isNotEmpty) icones.add(espaco);
      icones.add(_socialIcon(FaIcon(FontAwesomeIcons.instagram, color: AppColors.brown, size: 18), () => _abrirLink(config.footerInstagram)));
    }
    if (config.footerTiktok.trim().isNotEmpty) {
      if (icones.isNotEmpty) icones.add(espaco);
      icones.add(_socialIcon(FaIcon(FontAwesomeIcons.tiktok, color: AppColors.brown, size: 18), () => _abrirLink(config.footerTiktok)));
    }

    if (icones.isEmpty) {
      return [
        _socialIcon(FaIcon(FontAwesomeIcons.instagram, color: AppColors.brown, size: 18), null),
        espaco,
        _socialIcon(FaIcon(FontAwesomeIcons.whatsapp, color: AppColors.brown, size: 18), null),
      ];
    }
    return icones;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final nome = HomeDefaults.valorOuPadrao(config.footerNome, HomeDefaults.footerNome);
    final copyright = HomeDefaults.valorOuPadrao(config.footerCopyright, HomeDefaults.footerCopyright);
    final tituloRedes = HomeDefaults.valorOuPadrao(config.footerRedesSociais, HomeDefaults.footerRedesSociais);
    final tituloHorario = HomeDefaults.valorOuPadrao(config.footerHorario, HomeDefaults.footerHorario);
    final textoHorario = HomeDefaults.valorOuPadrao(config.footerHorarioTexto, HomeDefaults.footerHorarioTexto);

    return isMobile ? _buildMobile(nome, copyright, tituloRedes, tituloHorario, textoHorario) : _buildDesktop(nome, copyright, tituloRedes, tituloHorario, textoHorario);
  }

  Widget _buildMobile(String nome, String copyright, String tituloRedes, String tituloHorario, String textoHorario) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      color: Color(0xFFF5F5F5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(nome, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.brown)),
          SizedBox(height: 10),
          Text(copyright, style: TextStyle(fontSize: 12, color: AppColors.grey, height: 1.5)),
          SizedBox(height: 20),
          Text(tituloRedes, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.brown)),
          SizedBox(height: 10),
          Row(children: _buildIconesRedesSociais(true)),
          SizedBox(height: 20),
          Text(tituloHorario, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.brown)),
          SizedBox(height: 10),
          Text(textoHorario, style: TextStyle(fontSize: 12, color: AppColors.grey, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildDesktop(String nome, String copyright, String tituloRedes, String tituloHorario, String textoHorario) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 40),
      color: Color(0xFFF5F5F5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(nome, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.brown)), SizedBox(height: 12), Text(copyright, style: TextStyle(fontSize: 14, color: AppColors.grey, height: 1.5))])),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(tituloRedes, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.brown)), SizedBox(height: 12), Row(children: _buildIconesRedesSociais(false))])),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(tituloHorario, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.brown)), SizedBox(height: 12), Text(textoHorario, style: TextStyle(fontSize: 14, color: AppColors.grey, height: 1.6))])),
        ],
      ),
    );
  }

    Widget _socialIcon(Widget icone, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(color: Color(0xFFE8E4E2), borderRadius: BorderRadius.circular(8)),
        child: icone,
      ),
    );
  }
}