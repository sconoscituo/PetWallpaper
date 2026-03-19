import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/pet.dart';
import '../../core/theme/app_theme.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PetProvider>(
      builder: (context, petProvider, _) {
        return Scaffold(
          backgroundColor: AppTheme.bgLight,
          appBar: AppBar(
            title: const Text('동물 상점'),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withOpacity(0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Text(
                      '${petProvider.coins}',
                      style: const TextStyle(
                        color: Color(0xFFD4A000),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '동물 친구들',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '새로운 동물 친구를 데려오세요!',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 코인 획득 방법 배너
                      _CoinBanner(onEarn: () => petProvider.addCoins(100)),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final pet = petProvider.allPets[index];
                      final isSelected =
                          petProvider.currentPet.type == pet.type;
                      return _PetCard(
                        pet: pet,
                        isSelected: isSelected,
                        coins: petProvider.coins,
                        onSelect: pet.isUnlocked
                            ? () => petProvider.selectPet(pet.type)
                            : null,
                        onPurchase: !pet.isUnlocked
                            ? () => _handlePurchase(context, petProvider, pet)
                            : null,
                      );
                    },
                    childCount: petProvider.allPets.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        );
      },
    );
  }

  void _handlePurchase(
      BuildContext context, PetProvider provider, Pet pet) {
    if (provider.coins < pet.price) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('코인 부족'),
          content: Text(
            '${pet.typeName}를 데려오려면 ${pet.price}🪙이 필요합니다.\n'
            '현재 코인: ${provider.coins}🪙\n\n'
            '펫과 놀거나 매일 앱을 실행하면 코인을 모을 수 있어요!',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
            TextButton(
              onPressed: () {
                provider.addCoins(100);
                Navigator.pop(context);
              },
              child: const Text('코인 100개 획득 (테스트)'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${pet.emoji} ${pet.typeName} 데려오기'),
        content: Text(
          '${pet.price}🪙을 사용해서 ${pet.typeName}를 데려올까요?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              final success = provider.purchasePet(pet.type);
              Navigator.pop(context);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${pet.emoji} ${pet.typeName}를 데려왔습니다!'),
                    backgroundColor: AppTheme.primary,
                  ),
                );
                provider.selectPet(pet.type);
              }
            },
            child: const Text('데려오기'),
          ),
        ],
      ),
    );
  }
}

class _CoinBanner extends StatelessWidget {
  final VoidCallback onEarn;

  const _CoinBanner({required this.onEarn});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE066), Color(0xFFFFB300)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Text('🪙', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '코인 모으는 방법',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5A3E00),
                  ),
                ),
                Text(
                  '매일 출석 +50 • 펫과 놀기 +10 • 먹이주기 +5',
                  style: TextStyle(fontSize: 11, color: Color(0xFF7A5500)),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onEarn,
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.3),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
            child: const Text(
              '+100',
              style: TextStyle(
                color: Color(0xFF5A3E00),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  final Pet pet;
  final bool isSelected;
  final int coins;
  final VoidCallback? onSelect;
  final VoidCallback? onPurchase;

  const _PetCard({
    required this.pet,
    required this.isSelected,
    required this.coins,
    this.onSelect,
    this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    final canAfford = coins >= pet.price;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primary.withOpacity(0.08)
            : AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppTheme.primary : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 잠금 오버레이
            Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  pet.emoji,
                  style: TextStyle(
                    fontSize: 52,
                    color: pet.isUnlocked ? null : Colors.grey,
                  ),
                ),
                if (!pet.isUnlocked)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade700,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lock, color: Colors.white, size: 14),
                    ),
                  ),
                if (isSelected)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              pet.typeName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            if (pet.isUnlocked) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primary.withOpacity(0.15)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isSelected ? '선택됨' : '보유중',
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (!isSelected) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onSelect,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    child: const Text('선택하기'),
                  ),
                ),
              ],
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 14)),
                  Text(
                    ' ${pet.price}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: canAfford
                          ? const Color(0xFFD4A000)
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onPurchase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canAfford
                        ? AppTheme.primary
                        : Colors.grey.shade300,
                    foregroundColor: canAfford ? Colors.white : Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                  child: const Text('데려오기'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
