import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/pet.dart';
import '../../core/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const MethodChannel _channel =
      MethodChannel('com.petwallpaper/wallpaper');

  @override
  Widget build(BuildContext context) {
    return Consumer<PetProvider>(
      builder: (context, petProvider, _) {
        return Scaffold(
          backgroundColor: AppTheme.bgLight,
          appBar: AppBar(title: const Text('설정')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 내 펫 정보
              _SectionCard(
                title: '내 펫',
                child: Column(
                  children: [
                    _PetStatusRow(pet: petProvider.currentPet),
                    const Divider(height: 24),
                    // 펫 선택
                    const Text(
                      '펫 선택',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 80,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: petProvider.allPets.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, index) {
                          final pet = petProvider.allPets[index];
                          final isSelected =
                              petProvider.currentPet.type == pet.type;
                          return GestureDetector(
                            onTap: pet.isUnlocked
                                ? () => petProvider.selectPet(pet.type)
                                : null,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 72,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primary.withOpacity(0.1)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primary
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    pet.emoji,
                                    style: TextStyle(
                                      fontSize: 32,
                                      color: pet.isUnlocked ? null : Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    pet.isUnlocked ? pet.typeName : '잠금',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: pet.isUnlocked
                                          ? AppTheme.textSecondary
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 라이브 월페이퍼 설정
              _SectionCard(
                title: 'Live Wallpaper',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '홈 화면에 움직이는 펫을 설정할 수 있습니다.',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _setLiveWallpaper(context),
                        icon: const Icon(Icons.wallpaper),
                        label: const Text('Live Wallpaper로 설정'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '설정 > 배경화면 > 라이브 배경화면에서도 설정 가능합니다.',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 앱 정보
              _SectionCard(
                title: '앱 정보',
                child: Column(
                  children: [
                    _InfoRow(label: '버전', value: '1.0.0'),
                    const Divider(height: 20),
                    _InfoRow(label: '동물 종류', value: '5종 (고양이·강아지·토끼·팬더·햄스터)'),
                    const Divider(height: 20),
                    _InfoRow(label: '기본 제공', value: '고양이 (무료)'),
                    const Divider(height: 20),
                    _InfoRow(label: '추가 동물', value: '인앱 코인으로 구매'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 사용 방법
              _SectionCard(
                title: '사용 방법',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _HowToRow(
                      icon: '👆',
                      text: '펫을 터치하면 점프합니다',
                    ),
                    SizedBox(height: 10),
                    _HowToRow(
                      icon: '🐟',
                      text: '먹이 버튼으로 펫에게 먹이를 주세요',
                    ),
                    SizedBox(height: 10),
                    _HowToRow(
                      icon: '🎾',
                      text: '놀기 버튼으로 펫과 함께 놀아주세요',
                    ),
                    SizedBox(height: 10),
                    _HowToRow(
                      icon: '🪙',
                      text: '코인을 모아 새로운 동물을 데려오세요',
                    ),
                    SizedBox(height: 10),
                    _HowToRow(
                      icon: '🌙',
                      text: '오래 방치하면 펫이 잠들거나 배고파해요',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Future<void> _setLiveWallpaper(BuildContext context) async {
    try {
      await _channel.invokeMethod('setLiveWallpaper');
    } on PlatformException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('설정 실패: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _PetStatusRow extends StatelessWidget {
  final Pet pet;

  const _PetStatusRow({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(pet.emoji, style: const TextStyle(fontSize: 48)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pet.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                pet.typeName,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: pet.moodColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  pet.moodText,
                  style: TextStyle(
                    color: pet.moodColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _HowToRow extends StatelessWidget {
  final String icon;
  final String text;

  const _HowToRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
