import 'package:flutter/material.dart';
import '../../models/pet.dart';
import '../../services/animation_service.dart';

class PetWidget extends StatelessWidget {
  final Pet pet;
  final MoveDirection direction;
  final bool isJumping;
  final bool isEating;
  final int frameIndex;

  const PetWidget({
    super.key,
    required this.pet,
    required this.direction,
    required this.isJumping,
    required this.isEating,
    required this.frameIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: direction == MoveDirection.left ? -1 : 1,
      child: SizedBox(
        width: 80,
        height: 80,
        child: CustomPaint(
          painter: _PixelPetPainter(
            petType: pet.type,
            mood: pet.mood,
            frameIndex: frameIndex,
            isJumping: isJumping,
            isEating: isEating,
          ),
        ),
      ),
    );
  }
}

class _PixelPetPainter extends CustomPainter {
  final PetType petType;
  final PetMood mood;
  final int frameIndex;
  final bool isJumping;
  final bool isEating;

  _PixelPetPainter({
    required this.petType,
    required this.mood,
    required this.frameIndex,
    required this.isJumping,
    required this.isEating,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (petType) {
      case PetType.cat:
        _drawCat(canvas, size);
        break;
      case PetType.dog:
        _drawDog(canvas, size);
        break;
      case PetType.rabbit:
        _drawRabbit(canvas, size);
        break;
      case PetType.panda:
        _drawPanda(canvas, size);
        break;
      case PetType.hamster:
        _drawHamster(canvas, size);
        break;
    }
  }

  void _drawCat(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..style = PaintingStyle.fill;
    final legAnim = isJumping ? 0.0 : (frameIndex % 2 == 0 ? 3.0 : -3.0);

    // 몸통
    paint.color = const Color(0xFFFF9E5C);
    canvas.drawRoundRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.2, h * 0.4, w * 0.6, h * 0.42),
        Radius.circular(w * 0.15),
      ),
      paint,
    );

    // 머리
    canvas.drawCircle(Offset(w * 0.5, h * 0.3), w * 0.26, paint);

    // 귀
    _drawTriangle(canvas, paint, const Color(0xFFFF9E5C),
        Offset(w * 0.28, h * 0.12), Offset(w * 0.18, h * 0.02), Offset(w * 0.38, h * 0.12));
    _drawTriangle(canvas, paint, const Color(0xFFFF9E5C),
        Offset(w * 0.62, h * 0.12), Offset(w * 0.72, h * 0.02), Offset(w * 0.52, h * 0.12));

    // 귀 안
    _drawTriangle(canvas, paint, const Color(0xFFFFB8B8),
        Offset(w * 0.29, h * 0.13), Offset(w * 0.21, h * 0.05), Offset(w * 0.37, h * 0.13));
    _drawTriangle(canvas, paint, const Color(0xFFFFB8B8),
        Offset(w * 0.61, h * 0.13), Offset(w * 0.69, h * 0.05), Offset(w * 0.53, h * 0.13));

    // 줄무늬
    paint.color = const Color(0xFFD4703A);
    paint.strokeWidth = 2;
    paint.style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w * 0.38, h * 0.42), Offset(w * 0.38, h * 0.74), paint);
    canvas.drawLine(Offset(w * 0.5, h * 0.42), Offset(w * 0.5, h * 0.74), paint);
    canvas.drawLine(Offset(w * 0.62, h * 0.42), Offset(w * 0.62, h * 0.74), paint);
    paint.style = PaintingStyle.fill;

    // 눈
    if (mood == PetMood.sleeping) {
      paint.color = const Color(0xFF333333);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2.5;
      canvas.drawLine(Offset(w * 0.37, h * 0.29), Offset(w * 0.43, h * 0.29), paint);
      canvas.drawLine(Offset(w * 0.57, h * 0.29), Offset(w * 0.63, h * 0.29), paint);
      paint.style = PaintingStyle.fill;
    } else {
      paint.color = const Color(0xFF5DC87C);
      canvas.drawCircle(Offset(w * 0.4, h * 0.29), w * 0.09, paint);
      canvas.drawCircle(Offset(w * 0.6, h * 0.29), w * 0.09, paint);
      paint.color = const Color(0xFF1A1A1A);
      canvas.drawCircle(Offset(w * 0.41, h * 0.29), w * 0.055, paint);
      canvas.drawCircle(Offset(w * 0.61, h * 0.29), w * 0.055, paint);
      paint.color = Colors.white;
      canvas.drawCircle(Offset(w * 0.43, h * 0.265), w * 0.02, paint);
      canvas.drawCircle(Offset(w * 0.63, h * 0.265), w * 0.02, paint);
    }

    // 코
    paint.color = const Color(0xFFFF6B9D);
    _drawTriangle(canvas, paint, const Color(0xFFFF6B9D),
        Offset(w * 0.47, h * 0.36), Offset(w * 0.53, h * 0.36), Offset(w * 0.5, h * 0.39));

    // 수염
    paint.color = const Color(0xFFFFFFFF).withOpacity(0.8);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;
    canvas.drawLine(Offset(w * 0.5, h * 0.375), Offset(w * 0.22, h * 0.35), paint);
    canvas.drawLine(Offset(w * 0.5, h * 0.375), Offset(w * 0.22, h * 0.40), paint);
    canvas.drawLine(Offset(w * 0.5, h * 0.375), Offset(w * 0.78, h * 0.35), paint);
    canvas.drawLine(Offset(w * 0.5, h * 0.375), Offset(w * 0.78, h * 0.40), paint);
    paint.style = PaintingStyle.fill;

    // 꼬리
    paint.color = const Color(0xFFFF9E5C);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 5;
    paint.strokeCap = StrokeCap.round;
    final tailPath = Path()
      ..moveTo(w * 0.78, h * 0.75)
      ..cubicTo(w * 1.1, h * 0.65, w * 1.15, h * 0.35, w * 0.9, h * 0.25);
    canvas.drawPath(tailPath, paint);
    paint.style = PaintingStyle.fill;

    // 다리
    paint.color = const Color(0xFFFF9E5C);
    canvas.drawRoundRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.22, h * 0.76 + legAnim, w * 0.18, h * 0.18),
        Radius.circular(6),
      ),
      paint,
    );
    canvas.drawRoundRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.60, h * 0.76 - legAnim, w * 0.18, h * 0.18),
        Radius.circular(6),
      ),
      paint,
    );
  }

  void _drawDog(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..style = PaintingStyle.fill;
    final legAnim = isJumping ? 0.0 : (frameIndex % 2 == 0 ? 3.0 : -3.0);

    // 몸통
    paint.color = const Color(0xFFD4A056);
    canvas.drawRoundRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.15, h * 0.38, w * 0.65, h * 0.44),
        Radius.circular(w * 0.15),
      ),
      paint,
    );

    // 머리
    canvas.drawCircle(Offset(w * 0.5, h * 0.28), w * 0.28, paint);

    // 귀 (축 늘어진 강아지 귀)
    paint.color = const Color(0xFFB8893A);
    canvas.drawRoundRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.15, h * 0.12, w * 0.15, h * 0.28),
        Radius.circular(8),
      ),
      paint,
    );
    canvas.drawRoundRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.70, h * 0.12, w * 0.15, h * 0.28),
        Radius.circular(8),
      ),
      paint,
    );

    // 눈
    if (mood == PetMood.sleeping) {
      paint.color = const Color(0xFF333333);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2.5;
      canvas.drawLine(Offset(w * 0.37, h * 0.27), Offset(w * 0.43, h * 0.27), paint);
      canvas.drawLine(Offset(w * 0.57, h * 0.27), Offset(w * 0.63, h * 0.27), paint);
      paint.style = PaintingStyle.fill;
    } else {
      paint.color = const Color(0xFF4A3728);
      canvas.drawCircle(Offset(w * 0.4, h * 0.27), w * 0.09, paint);
      canvas.drawCircle(Offset(w * 0.6, h * 0.27), w * 0.09, paint);
      paint.color = Colors.white;
      canvas.drawCircle(Offset(w * 0.42, h * 0.255), w * 0.025, paint);
      canvas.drawCircle(Offset(w * 0.62, h * 0.255), w * 0.025, paint);
    }

    // 코 (강아지 코는 크고 둥글게)
    paint.color = const Color(0xFF2D1A0A);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.35), width: w * 0.22, height: h * 0.1), paint);

    // 혀
    if (mood == PetMood.happy || mood == PetMood.excited) {
      paint.color = const Color(0xFFFF6B9D);
      canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.43), width: w * 0.16, height: h * 0.1), paint);
    }

    // 꼬리
    paint.color = const Color(0xFFD4A056);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 6;
    paint.strokeCap = StrokeCap.round;
    final tailPath = Path()
      ..moveTo(w * 0.8, h * 0.55)
      ..cubicTo(w * 1.05, h * 0.40, w * 1.05, h * 0.25, w * 0.88, h * 0.22);
    canvas.drawPath(tailPath, paint);
    paint.style = PaintingStyle.fill;

    // 다리
    paint.color = const Color(0xFFD4A056);
    canvas.drawRoundRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.2, h * 0.76 + legAnim, w * 0.18, h * 0.18), Radius.circular(6)),
      paint,
    );
    canvas.drawRoundRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.62, h * 0.76 - legAnim, w * 0.18, h * 0.18), Radius.circular(6)),
      paint,
    );
  }

  void _drawRabbit(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..style = PaintingStyle.fill;

    // 몸통
    paint.color = const Color(0xFFF0F0F0);
    canvas.drawOval(Rect.fromLTWH(w * 0.2, h * 0.38, w * 0.6, h * 0.48), paint);

    // 머리
    canvas.drawCircle(Offset(w * 0.5, h * 0.30), w * 0.24, paint);

    // 긴 귀
    paint.color = const Color(0xFFF0F0F0);
    canvas.drawRoundRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.29, h * 0.0, w * 0.13, h * 0.28), Radius.circular(10)),
      paint,
    );
    canvas.drawRoundRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.58, h * 0.0, w * 0.13, h * 0.28), Radius.circular(10)),
      paint,
    );

    // 귀 안쪽 (분홍)
    paint.color = const Color(0xFFFFB8C8);
    canvas.drawRoundRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.32, h * 0.02, w * 0.07, h * 0.22), Radius.circular(7)),
      paint,
    );
    canvas.drawRoundRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.61, h * 0.02, w * 0.07, h * 0.22), Radius.circular(7)),
      paint,
    );

    // 눈 (빨간 눈)
    paint.color = const Color(0xFFFF4466);
    canvas.drawCircle(Offset(w * 0.40, h * 0.28), w * 0.07, paint);
    canvas.drawCircle(Offset(w * 0.60, h * 0.28), w * 0.07, paint);
    paint.color = Colors.white;
    canvas.drawCircle(Offset(w * 0.415, h * 0.265), w * 0.02, paint);
    canvas.drawCircle(Offset(w * 0.615, h * 0.265), w * 0.02, paint);

    // 코
    paint.color = const Color(0xFFFFAABB);
    canvas.drawCircle(Offset(w * 0.5, h * 0.33), w * 0.05, paint);

    // 꼬리 (작고 동그랗게)
    paint.color = const Color(0xFFF8F8F8);
    canvas.drawCircle(Offset(w * 0.22, h * 0.62), w * 0.1, paint);
  }

  void _drawPanda(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..style = PaintingStyle.fill;

    // 몸통 (흰색)
    paint.color = Colors.white;
    canvas.drawRoundRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.18, h * 0.38, w * 0.64, h * 0.46), Radius.circular(w * 0.18)),
      paint,
    );

    // 머리
    canvas.drawCircle(Offset(w * 0.5, h * 0.28), w * 0.27, paint);

    // 귀 (검정)
    paint.color = const Color(0xFF1A1A1A);
    canvas.drawCircle(Offset(w * 0.27, h * 0.09), w * 0.12, paint);
    canvas.drawCircle(Offset(w * 0.73, h * 0.09), w * 0.12, paint);

    // 눈 주변 검정 패치
    paint.color = const Color(0xFF1A1A1A);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.37, h * 0.27), width: w * 0.2, height: h * 0.18), paint);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.63, h * 0.27), width: w * 0.2, height: h * 0.18), paint);

    // 눈 (흰자)
    paint.color = Colors.white;
    canvas.drawCircle(Offset(w * 0.38, h * 0.27), w * 0.075, paint);
    canvas.drawCircle(Offset(w * 0.62, h * 0.27), w * 0.075, paint);

    // 눈동자
    paint.color = const Color(0xFF1A1A1A);
    canvas.drawCircle(Offset(w * 0.39, h * 0.27), w * 0.05, paint);
    canvas.drawCircle(Offset(w * 0.63, h * 0.27), w * 0.05, paint);
    paint.color = Colors.white;
    canvas.drawCircle(Offset(w * 0.41, h * 0.255), w * 0.018, paint);
    canvas.drawCircle(Offset(w * 0.65, h * 0.255), w * 0.018, paint);

    // 코
    paint.color = const Color(0xFF2D2D2D);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.35), width: w * 0.14, height: h * 0.07), paint);

    // 팔다리 (검정)
    paint.color = const Color(0xFF1A1A1A);
    canvas.drawRoundRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.18, h * 0.60, w * 0.18, h * 0.30), Radius.circular(8)),
      paint,
    );
    canvas.drawRoundRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.64, h * 0.60, w * 0.18, h * 0.30), Radius.circular(8)),
      paint,
    );
  }

  void _drawHamster(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..style = PaintingStyle.fill;

    // 몸통 (통통하게)
    paint.color = const Color(0xFFD4956A);
    canvas.drawOval(Rect.fromLTWH(w * 0.12, h * 0.32, w * 0.76, h * 0.58), paint);

    // 볼살
    paint.color = const Color(0xFFFFB89A);
    canvas.drawCircle(Offset(w * 0.22, h * 0.48), w * 0.14, paint);
    canvas.drawCircle(Offset(w * 0.78, h * 0.48), w * 0.14, paint);

    // 머리
    paint.color = const Color(0xFFD4956A);
    canvas.drawCircle(Offset(w * 0.5, h * 0.30), w * 0.26, paint);

    // 귀 (작고 동그란)
    canvas.drawCircle(Offset(w * 0.30, h * 0.11), w * 0.1, paint);
    canvas.drawCircle(Offset(w * 0.70, h * 0.11), w * 0.1, paint);
    paint.color = const Color(0xFFFFB8B8);
    canvas.drawCircle(Offset(w * 0.30, h * 0.11), w * 0.065, paint);
    canvas.drawCircle(Offset(w * 0.70, h * 0.11), w * 0.065, paint);

    // 눈
    paint.color = const Color(0xFF1A1A1A);
    canvas.drawCircle(Offset(w * 0.40, h * 0.27), w * 0.075, paint);
    canvas.drawCircle(Offset(w * 0.60, h * 0.27), w * 0.075, paint);
    paint.color = Colors.white;
    canvas.drawCircle(Offset(w * 0.415, h * 0.255), w * 0.022, paint);
    canvas.drawCircle(Offset(w * 0.615, h * 0.255), w * 0.022, paint);

    // 코
    paint.color = const Color(0xFFFF9090);
    canvas.drawCircle(Offset(w * 0.5, h * 0.34), w * 0.05, paint);

    // 앞발 (작게)
    paint.color = const Color(0xFFD4956A);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.28, h * 0.76), width: w * 0.22, height: h * 0.14), paint);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.72, h * 0.76), width: w * 0.22, height: h * 0.14), paint);
  }

  void _drawTriangle(Canvas canvas, Paint paint, Color color, Offset p1, Offset p2, Offset p3) {
    paint.color = color;
    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_PixelPetPainter old) =>
      old.frameIndex != frameIndex ||
      old.mood != mood ||
      old.isJumping != isJumping ||
      old.isEating != isEating;
}
