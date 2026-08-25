import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';

class ConfigSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const ConfigSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: AppColors.pinkStrong, size: 24),
            SizedBox(width: 8),
            Text(title,
                style: TextStyle(
                    color: AppColors.brown,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ]),
          SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}