import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

enum MoveDirection { left, right, up, down, idle }

class AnimationService extends ChangeNotifier {
  Offset _position = const Offset(200, 400);
  MoveDirection _direction = MoveDirection.right;
  bool _isJumping = false;
  bool _isEating = false;
  double _jumpHeight = 0;
  int _frameIndex = 0;
  Timer? _moveTimer;
  Timer? _frameTimer;
  Timer? _actionTimer;
  double _screenWidth = 400;
  double _screenHeight = 700;
  final double _petSize = 60;
  final Random _random = Random();
  double _velX = 1.5;
  double _velY = 0;

  Offset get position => _position;
  MoveDirection get direction => _direction;
  bool get isJumping => _isJumping;
  bool get isEating => _isEating;
  double get jumpHeight => _jumpHeight;
  int get frameIndex => _frameIndex;

  void setScreenSize(double width, double height) {
    _screenWidth = width;
    _screenHeight = height;
  }

  void start() {
    _position = Offset(_screenWidth / 2, _screenHeight * 0.6);
    _startMoving();
    _startFrameAnimation();
    _scheduleRandomAction();
  }

  void stop() {
    _moveTimer?.cancel();
    _frameTimer?.cancel();
    _actionTimer?.cancel();
  }

  void _startMoving() {
    _moveTimer?.cancel();
    _moveTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (_isJumping) {
        _updateJump();
      } else if (!_isEating) {
        _updateWalk();
      }
      notifyListeners();
    });
  }

  void _startFrameAnimation() {
    _frameTimer?.cancel();
    _frameTimer = Timer.periodic(const Duration(milliseconds: 150), (_) {
      _frameIndex = (_frameIndex + 1) % 4;
      notifyListeners();
    });
  }

  void _scheduleRandomAction() {
    final delay = 3 + _random.nextInt(5);
    _actionTimer?.cancel();
    _actionTimer = Timer(Duration(seconds: delay), () {
      final action = _random.nextInt(4);
      switch (action) {
        case 0:
          _changeDirection();
          break;
        case 1:
          triggerJump();
          break;
        case 2:
          _pause();
          break;
        default:
          _changeDirection();
      }
      _scheduleRandomAction();
    });
  }

  void _updateWalk() {
    double newX = _position.dx + _velX;
    double newY = _position.dy + _velY;

    // 벽 반사
    if (newX < _petSize) {
      newX = _petSize;
      _velX = _velX.abs();
      _direction = MoveDirection.right;
    } else if (newX > _screenWidth - _petSize) {
      newX = _screenWidth - _petSize;
      _velX = -_velX.abs();
      _direction = MoveDirection.left;
    }

    if (newY < _petSize * 2) {
      newY = _petSize * 2;
      _velY = _velY.abs();
    } else if (newY > _screenHeight - _petSize) {
      newY = _screenHeight - _petSize;
      _velY = -_velY.abs();
    }

    _position = Offset(newX, newY);
  }

  void _updateJump() {
    _jumpHeight += _velY;
    _velY += 1.2;

    double newY = _position.dy - _jumpHeight;

    if (newY > _screenHeight - _petSize) {
      newY = _screenHeight - _petSize;
      _isJumping = false;
      _jumpHeight = 0;
      _velY = 0;
    }

    // 수평 이동도 계속
    double newX = _position.dx + _velX;
    newX = newX.clamp(_petSize, _screenWidth - _petSize);

    _position = Offset(newX, newY);
  }

  void _changeDirection() {
    final angle = _random.nextDouble() * pi / 2 - pi / 4;
    final speed = 1.0 + _random.nextDouble() * 2.0;
    final currentDir = _velX > 0 ? 1 : -1;
    _velX = cos(angle) * speed * currentDir;
    _velY = sin(angle) * speed * 0.3;

    if (_velX > 0) {
      _direction = MoveDirection.right;
    } else {
      _direction = MoveDirection.left;
    }
    notifyListeners();
  }

  void _pause() {
    _isEating = true;
    notifyListeners();
    Timer(const Duration(seconds: 2), () {
      _isEating = false;
      notifyListeners();
    });
  }

  void triggerJump() {
    if (!_isJumping) {
      _isJumping = true;
      _velY = -15.0;
      _jumpHeight = 0;
      notifyListeners();
    }
  }

  void onTapPet() {
    triggerJump();
  }

  void feedPet(Offset feedPosition) {
    _isEating = true;
    notifyListeners();
    // 먹이 위치로 이동
    final dx = feedPosition.dx - _position.dx;
    final dist = dx.abs();
    if (dist > 10) {
      _velX = (dx / dist) * 2.0;
      _direction = dx > 0 ? MoveDirection.right : MoveDirection.left;
    }
    Timer(const Duration(seconds: 3), () {
      _isEating = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
