import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class OverlayService {
  static bool _isRunning = false;

  /// 오버레이 표시 권한 요청
  static Future<bool> requestPermission() async {
    final bool hasPermission = await FlutterOverlayWindow.isPermissionGranted();
    if (!hasPermission) {
      await FlutterOverlayWindow.requestPermission();
      return await FlutterOverlayWindow.isPermissionGranted();
    }
    return true;
  }

  /// 오버레이 시작 — 화면 최상위에 동물 위젯 표시
  static Future<void> startOverlay() async {
    if (_isRunning) return;

    final bool hasPermission = await requestPermission();
    if (!hasPermission) {
      debugPrint('[OverlayService] SYSTEM_ALERT_WINDOW 권한 없음');
      return;
    }

    await FlutterOverlayWindow.showOverlay(
      enableDrag: true,
      overlayTitle: 'PetWallpaper',
      overlayContent: '동물이 화면을 돌아다니는 중...',
      flag: OverlayFlag.defaultFlag,
      visibility: NotificationVisibility.visibilityPublic,
      positionGravity: PositionGravity.auto,
      width: 120,
      height: 120,
    );

    _isRunning = true;
    debugPrint('[OverlayService] 오버레이 시작됨');
  }

  /// 오버레이 종료
  static Future<void> stopOverlay() async {
    if (!_isRunning) return;
    await FlutterOverlayWindow.closeOverlay();
    _isRunning = false;
    debugPrint('[OverlayService] 오버레이 종료됨');
  }

  /// 오버레이 실행 여부
  static bool get isRunning => _isRunning;

  /// 오버레이 내부에서 메인 앱으로 데이터 전송
  static void sendData(dynamic data) {
    FlutterOverlayWindow.shareData(data);
  }

  /// 메인 앱에서 오버레이로 전달된 데이터 스트림
  static Stream<dynamic> get dataStream =>
      FlutterOverlayWindow.overlayListener;
}
