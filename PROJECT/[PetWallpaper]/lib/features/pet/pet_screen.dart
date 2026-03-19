import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/pet.dart';
import '../../services/animation_service.dart';
import '../../core/theme/app_theme.dart';
import 'pet_widget.dart';

class PetScreen extends StatefulWidget {
  const PetScreen({super.key});

  @override
  State<PetScreen> createState() => _PetScreenState();
}

class _PetScreenState extends State<PetScreen> with TickerProviderStateMixin {
  late AnimationController _bounceController;
  Timer? _tickTimer;
  Offset? _foodPosition;
  Timer? _foodTimer;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      context.read<AnimationService>().setScreenSize(size.width, size.height * 0.75);
      context.read<AnimationService>().start();
    });

    _tickTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      context.read<PetProvider>().tick();
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _tickTimer?.cancel();
    _foodTimer?.cancel();
    context.read<AnimationService>().stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<PetProvider, AnimationService>(
      builder: (context, petProvider, animService, _) {
        final pet = petProvider.currentPet;

        return Scaffold(
          backgroundColor: const Color(0xFF1A1A2E),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Row(
              children: [
                Text(pet.emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text(pet.name),
              ],
            ),
            actions: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Text(
                      '${petProvider.coins}',
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
          body: Stack(
            children: [
              // 배경 - 밤하늘
              _buildBackground(),

              // 바닥
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 80,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF2D5A27), Color(0xFF1A3A15)],
                    ),
                  ),
                ),
              ),

              // 먹이 표시
              if (_foodPosition != null)
                Positioned(
                  left: _foodPosition!.dx - 15,
                  top: _foodPosition!.dy - 15,
                  child: const Text('🐟', style: TextStyle(fontSize: 28)),
                ),

              // 펫 위젯
              Positioned(
                left: animService.position.dx - 40,
                top: animService.position.dy - 40,
                child: GestureDetector(
                  onTap: () {
                    animService.onTapPet();
                    petProvider.playWithPet();
                    _bounceController.forward(from: 0);
                  },
                  child: PetWidget(
                    pet: pet,
                    direction: animService.direction,
                    isJumping: animService.isJumping,
                    isEating: animService.isEating,
                    frameIndex: animService.frameIndex,
                  ),
                ),
              ),

              // 감정 상태 말풍선
              Positioned(
                left: animService.position.dx - 50,
                top: animService.position.dy - 90,
                child: _MoodBubble(mood: pet.moodText, color: pet.moodColor),
              ),

              // 상태 바 (하단)
              Positioned(
                bottom: 90,
                left: 16,
                right: 16,
                child: _buildStatusBars(pet),
              ),

              // 액션 버튼
              Positioned(
                bottom: 90,
                right: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ActionButton(
                      emoji: '🐟',
                      label: '먹이',
                      onTap: () => _feedPet(context, animService, petProvider),
                    ),
                    const SizedBox(height: 8),
                    _ActionButton(
                      emoji: '🎾',
                      label: '놀기',
                      onTap: () {
                        animService.triggerJump();
                        petProvider.playWithPet();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _feedPet(BuildContext context, AnimationService animService, PetProvider petProvider) {
    final size = MediaQuery.of(context).size;
    final feedPos = Offset(
      size.width * 0.3 + (size.width * 0.4) * (DateTime.now().millisecondsSinceEpoch % 100) / 100,
      size.height * 0.5,
    );
    setState(() => _foodPosition = feedPos);
    animService.feedPet(feedPos);
    petProvider.feedPet();
    _foodTimer?.cancel();
    _foodTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _foodPosition = null);
    });
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0D0D2B),
            Color(0xFF1A1A3E),
            Color(0xFF2A2A5E),
          ],
        ),
      ),
      child: CustomPaint(
        painter: _StarsPainter(),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildStatusBars(Pet pet) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StatusBar(label: '배고픔', value: pet.hunger, color: const Color(0xFFFF9800), emoji: '🍖'),
          const SizedBox(height: 6),
          _StatusBar(label: '행복', value: pet.happiness, color: const Color(0xFFFF6B9D), emoji: '💕'),
          const SizedBox(height: 6),
          _StatusBar(label: '에너지', value: pet.energy, color: const Color(0xFF4CAF50), emoji: '⚡'),
        ],
      ),
    );
  }
}

class _StarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    const stars = [
      [0.1, 0.05], [0.3, 0.08], [0.5, 0.03], [0.7, 0.09], [0.9, 0.04],
      [0.2, 0.15], [0.6, 0.12], [0.8, 0.18], [0.15, 0.25], [0.45, 0.22],
      [0.75, 0.28], [0.05, 0.35], [0.35, 0.32], [0.65, 0.38], [0.95, 0.31],
    ];
    for (final star in stars) {
      canvas.drawCircle(
        Offset(size.width * star[0], size.height * star[1]),
        1.5,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _MoodBubble extends StatelessWidget {
  final String mood;
  final Color color;

  const _MoodBubble({required this.mood, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Text(
        mood,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final String emoji;

  const _StatusBar({
    required this.label,
    required this.value,
    required this.color,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 6),
        SizedBox(
          width: 50,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
