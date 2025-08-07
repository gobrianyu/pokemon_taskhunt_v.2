import 'package:flutter/material.dart';

class AlertTab extends StatelessWidget {
  final double height;
  final double width;
  final double tabWidth;
  final double tabHeight;
  final double radius;
  final double innerRadius;
  final double borderWidth;
  final Color borderColour;
  final Color colour;

  const AlertTab({
    super.key,
    required this.height,
    required this.width,
    required this.tabWidth,
    required this.tabHeight,
    this.borderWidth = 0,
    this.radius = 0,
    this.innerRadius = 0,
    this.borderColour = Colors.transparent,
    this.colour = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        CustomPaint(
          size: Size(width, height),
          painter: AlertTabPainter(
            tabWidth: tabWidth,
            tabHeight: tabHeight,
            innerRadius: innerRadius,
            radius: radius,
            borderWidth: borderWidth,
            colour: colour,
            borderColour: borderColour,
          ),
        ),
      ],
    );
  }
}

class AlertTabPainter extends CustomPainter {
  final double tabWidth;
  final double tabHeight;
  final double innerRadius;
  final double radius;
  final double borderWidth;
  final Color colour;
  final Color borderColour;

  AlertTabPainter({
    required this.tabWidth,
    required this.tabHeight,
    required this.innerRadius,
    required this.radius,
    required this.borderWidth,
    required this.colour,
    required this.borderColour,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colour
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColour
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final path = Path();

    double w = size.width;
    double h = size.height;

    double tw = tabWidth;
    double th = tabHeight;
    double r = radius;
    double ir = innerRadius;

    // Start from top-left
    path.moveTo(r, 0);

    // Tab top horizontal
    path.lineTo(tw - r, 0);
    path.arcToPoint(Offset(tw, r), radius: Radius.circular(r));

    // Tab down vertical
    path.lineTo(tw, th - ir);
    path.arcToPoint(
      Offset(tw + ir, th),
      radius: Radius.circular(ir),
      clockwise: false,
    );

    // Right to top-right
    path.lineTo(w - r, th);
    path.arcToPoint(Offset(w, th + r), radius: Radius.circular(r));

    // Down to bottom-right
    path.lineTo(w, h - r);
    path.arcToPoint(Offset(w - r, h), radius: Radius.circular(r));

    // Left along bottom edge
    path.lineTo(r, h);
    path.arcToPoint(Offset(0, h - r), radius: Radius.circular(r));

    // Up left edge
    path.lineTo(0, r);
    path.arcToPoint(Offset(r, 0), radius: Radius.circular(r));

    path.close();
    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
