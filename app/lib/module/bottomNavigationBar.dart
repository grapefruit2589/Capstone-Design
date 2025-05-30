import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final Color color;
  final String homeRoute;

  const CustomBottomNav({
    required this.color,
    required this.homeRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavIcon(context, Icons.home, '홈', homeRoute, color),
          _buildNavIcon(context, Icons.accessibility_new, '활동', '/activity', color),
          _buildNavIcon(context, Icons.help_outline, '도움말', '/help', color),
        ],
      ),
    );
  }

  Widget _buildNavIcon(BuildContext context, IconData icon, String label, String route, Color color) {
    return Expanded(
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 30, color: color),
            SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 18, color: color)),
          ],
        ),
      ),
    );
  }
}

