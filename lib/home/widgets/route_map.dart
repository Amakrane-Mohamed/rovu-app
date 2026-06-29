import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class RouteMap extends StatelessWidget {
  const RouteMap({super.key, required this.seed, this.height = 150});

  final int seed;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF20202A), Color(0xFF111116)],
              ),
            ),
            child: CustomPaint(painter: _GridPainter()),
          ),
          CustomPaint(painter: _RoutePainter(seed)),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.6),
                ],
                stops: const [0.45, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;
    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => false;
}

class _RoutePainter extends CustomPainter {
  _RoutePainter(this.seed);
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(seed);
    final points = <Offset>[];
    const count = 6;
    for (int i = 0; i < count; i++) {
      final t = i / (count - 1);
      points.add(Offset(
        size.width * (0.1 + 0.8 * t),
        size.height * (0.22 + rng.nextDouble() * 0.4),
      ));
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final mid = Offset(
        (points[i].dx + points[i + 1].dx) / 2,
        (points[i].dy + points[i + 1].dy) / 2,
      );
      path.quadraticBezierTo(points[i].dx, points[i].dy, mid.dx, mid.dy);
    }

    // Glow under the route.
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..color = AppColors.primary.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.primary,
    );

    canvas.drawCircle(points.first, 5, Paint()..color = AppColors.green);
    canvas.drawCircle(points.last, 5, Paint()..color = AppColors.primary);
  }

  @override
  bool shouldRepaint(covariant _RoutePainter old) => old.seed != seed;
}
