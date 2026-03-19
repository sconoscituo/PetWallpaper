import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// 오버레이 위에서 자유롭게 돌아다니는 픽셀아트 동물 위젯
class OverlayPetWidget extends StatefulWidget {
  const OverlayPetWidget({super.key});

  @override
  State<OverlayPetWidget> createState() => _OverlayPetWidgetState();
}

enum PetAction { walking, sitting, jumping }

class _OverlayPetWidgetState extends State<OverlayPetWidget>
    with TickerProviderStateMixin {
  final Random _random = Random();

  // 화면 내 위치
  double _x = 100;
  double _y = 200;

  // 이동 방향 (dx, dy)
  double _dx = 2.0;
  double _dy = 1.5;

  // 현재 동작 상태
  PetAction _action = PetAction.walking;

  // 하트 이펙트 표시 여부
  bool _showHeart = false;

  // 애니메이션 프레임 인덱스 (걷기 2프레임)
  int _walkFrame = 0;

  late Timer _moveTimer;
  late Timer _actionTimer;
  late Timer _walkFrameTimer;

  // 화면 크기 (오버레이 창 크기에 맞게 조정)
  static const double _petSize = 64.0;
  static const double _areaWidth = 360.0;
  static const double _areaHeight = 640.0;

  @override
  void initState() {
    super.initState();
    _startMovement();
    _startActionCycle();
    _startWalkFrameTimer();
  }

  /// 이동 타이머 — 16ms마다 위치 갱신 (약 60fps)
  void _startMovement() {
    _moveTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (_action == PetAction.sitting) return;

      setState(() {
        _x += _dx * (_action == PetAction.jumping ? 1.8 : 1.0);
        _y += _dy * (_action == PetAction.jumping ? 1.8 : 1.0);

        // 수평 경계 반사
        if (_x <= 0) {
          _x = 0;
          _dx = _dx.abs();
        } else if (_x >= _areaWidth - _petSize) {
          _x = _areaWidth - _petSize;
          _dx = -_dx.abs();
        }

        // 수직 경계 반사
        if (_y <= 0) {
          _y = 0;
          _dy = _dy.abs();
        } else if (_y >= _areaHeight - _petSize) {
          _y = _areaHeight - _petSize;
          _dy = -_dy.abs();
        }
      });
    });
  }

  /// 동작 사이클 타이머 — 2~5초마다 랜덤으로 동작 변경
  void _startActionCycle() {
    _actionTimer = Timer.periodic(
      Duration(seconds: 2 + _random.nextInt(4)),
      (_) {
        final actions = PetAction.values;
        setState(() {
          _action = actions[_random.nextInt(actions.length)];
          // 방향도 살짝 랜덤 변화
          _dx = (_random.nextDouble() * 3 + 1) * (_dx.isNegative ? -1 : 1);
          _dy = (_random.nextDouble() * 2 + 0.5) * (_dy.isNegative ? -1 : 1);
        });
      },
    );
  }

  /// 걷기 애니메이션 프레임 전환 타이머
  void _startWalkFrameTimer() {
    _walkFrameTimer =
        Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (_action == PetAction.walking) {
        setState(() {
          _walkFrame = (_walkFrame + 1) % 2;
        });
      }
    });
  }

  /// 터치 시 하트 이펙트
  void _onTap() {
    setState(() => _showHeart = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showHeart = false);
    });
  }

  @override
  void dispose() {
    _moveTimer.cancel();
    _actionTimer.cancel();
    _walkFrameTimer.cancel();
    super.dispose();
  }

  // ---- 픽셀아트 고양이 이모지 기반 렌더링 ----

  String get _petEmoji {
    switch (_action) {
      case PetAction.walking:
        return _walkFrame == 0 ? '🐱' : '🐈';
      case PetAction.sitting:
        return '😸';
      case PetAction.jumping:
        return '🙀';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _areaWidth,
      height: _areaHeight,
      child: Stack(
        children: [
          // 동물 본체
          Positioned(
            left: _x,
            top: _y,
            child: GestureDetector(
              onTap: _onTap,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 하트 이펙트
                  if (_showHeart)
                    const Text(
                      '💕',
                      style: TextStyle(fontSize: 24),
                    ),
                  // 동물 이모지 (픽셀아트 스타일 컨테이너)
                  Container(
                    width: _petSize,
                    height: _petSize,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        _petEmoji,
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
