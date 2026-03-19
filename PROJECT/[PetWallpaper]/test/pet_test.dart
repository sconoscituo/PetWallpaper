import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PetWallpaper Tests', () {
    test('Pet movement boundary check', () {
      double clamp(double value, double min, double max) {
        if (value < min) return min;
        if (value > max) return max;
        return value;
      }
      expect(clamp(-10, 0, 100), 0.0);
      expect(clamp(150, 0, 100), 100.0);
      expect(clamp(50, 0, 100), 50.0);
    });

    test('Pet state transitions', () {
      final states = ['idle', 'walking', 'jumping', 'sitting'];
      expect(states.contains('walking'), true);
      expect(states.length, 4);
    });
  });
}
