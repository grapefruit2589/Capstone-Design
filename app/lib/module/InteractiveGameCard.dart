import 'package:flutter/material.dart';

class InteractiveGameCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool enabled;
  final String? route;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;

  const InteractiveGameCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.enabled,
    this.route,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
  });

  @override
  State<InteractiveGameCard> createState() => _InteractiveGameCardState();
}

class _InteractiveGameCardState extends State<InteractiveGameCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final borderColor = _isPressed ? widget.iconColor : widget.borderColor;
    final backgroundColor = _isPressed
        ? widget.iconColor.withOpacity(0.1)
        : widget.borderColor.withOpacity(0.05);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          if (widget.enabled && widget.route != null) {
            Navigator.pushNamed(context, widget.route!);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('아직 구현되지 않은 게임입니다.')),
            );
          }
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 100),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 2), // 눌렀을 때 파란색 테두리
            borderRadius: BorderRadius.circular(12),
            color: backgroundColor, // 눌렀을 때 배경
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 48, color: widget.iconColor),
              SizedBox(height: 16),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 18,
                  color: widget.textColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (widget.subtitle.isNotEmpty) ...[
                SizedBox(height: 8),
                Text(
                  widget.subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
