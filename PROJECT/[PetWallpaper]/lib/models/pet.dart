import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PetType { cat, dog, rabbit, panda, hamster }

enum PetMood { happy, hungry, sleeping, excited, sad }

class Pet {
  final PetType type;
  PetMood mood;
  double hunger; // 0.0 ~ 1.0 (0: 배고픔, 1: 배부름)
  double happiness; // 0.0 ~ 1.0
  double energy; // 0.0 ~ 1.0
  String name;
  Offset position;
  bool isUnlocked;

  Pet({
    required this.type,
    this.mood = PetMood.happy,
    this.hunger = 0.8,
    this.happiness = 1.0,
    this.energy = 1.0,
    required this.name,
    this.position = const Offset(200, 400),
    this.isUnlocked = false,
  });

  String get emoji {
    switch (type) {
      case PetType.cat:
        return '🐱';
      case PetType.dog:
        return '🐶';
      case PetType.rabbit:
        return '🐰';
      case PetType.panda:
        return '🐼';
      case PetType.hamster:
        return '🐹';
    }
  }

  String get typeName {
    switch (type) {
      case PetType.cat:
        return '고양이';
      case PetType.dog:
        return '강아지';
      case PetType.rabbit:
        return '토끼';
      case PetType.panda:
        return '팬더';
      case PetType.hamster:
        return '햄스터';
    }
  }

  String get moodText {
    switch (mood) {
      case PetMood.happy:
        return '행복해요 ♡';
      case PetMood.hungry:
        return '배고파요...';
      case PetMood.sleeping:
        return 'zzz...';
      case PetMood.excited:
        return '신났어요! ★';
      case PetMood.sad:
        return '외로워요 ;_;';
    }
  }

  Color get moodColor {
    switch (mood) {
      case PetMood.happy:
        return const Color(0xFF4CAF50);
      case PetMood.hungry:
        return const Color(0xFFFF9800);
      case PetMood.sleeping:
        return const Color(0xFF9C27B0);
      case PetMood.excited:
        return const Color(0xFFFFEB3B);
      case PetMood.sad:
        return const Color(0xFF2196F3);
    }
  }

  int get price {
    switch (type) {
      case PetType.cat:
        return 0; // 무료
      case PetType.dog:
        return 1200;
      case PetType.rabbit:
        return 1200;
      case PetType.panda:
        return 2400;
      case PetType.hamster:
        return 1200;
    }
  }

  void feed() {
    hunger = (hunger + 0.3).clamp(0.0, 1.0);
    happiness = (happiness + 0.1).clamp(0.0, 1.0);
    mood = PetMood.happy;
  }

  void play() {
    if (energy > 0.2) {
      happiness = (happiness + 0.2).clamp(0.0, 1.0);
      energy = (energy - 0.2).clamp(0.0, 1.0);
      mood = PetMood.excited;
    }
  }

  void updateMood() {
    if (energy < 0.2) {
      mood = PetMood.sleeping;
    } else if (hunger < 0.3) {
      mood = PetMood.hungry;
    } else if (happiness > 0.7) {
      mood = PetMood.happy;
    } else if (happiness < 0.3) {
      mood = PetMood.sad;
    }
  }

  // 시간 경과에 따른 상태 감소
  void tick() {
    hunger = (hunger - 0.001).clamp(0.0, 1.0);
    energy = (energy - 0.0005).clamp(0.0, 1.0);
    if (energy > 0.3) {
      energy = (energy + 0.001).clamp(0.0, 1.0);
    }
    updateMood();
  }
}

class PetProvider extends ChangeNotifier {
  Pet _currentPet = Pet(
    type: PetType.cat,
    name: '냥이',
    isUnlocked: true,
  );

  final List<Pet> _allPets = [
    Pet(type: PetType.cat, name: '냥이', isUnlocked: true),
    Pet(type: PetType.dog, name: '멍멍이', isUnlocked: false),
    Pet(type: PetType.rabbit, name: '토순이', isUnlocked: false),
    Pet(type: PetType.panda, name: '판다', isUnlocked: false),
    Pet(type: PetType.hamster, name: '햄토리', isUnlocked: false),
  ];

  int _coins = 0;

  Pet get currentPet => _currentPet;
  List<Pet> get allPets => _allPets;
  int get coins => _coins;

  PetProvider() {
    _loadState();
  }

  void feedPet() {
    _currentPet.feed();
    notifyListeners();
    _saveState();
  }

  void playWithPet() {
    _currentPet.play();
    notifyListeners();
    _saveState();
  }

  void selectPet(PetType type) {
    final pet = _allPets.firstWhere((p) => p.type == type);
    if (pet.isUnlocked) {
      _currentPet = pet;
      notifyListeners();
      _saveState();
    }
  }

  bool purchasePet(PetType type) {
    final pet = _allPets.firstWhere((p) => p.type == type);
    if (!pet.isUnlocked && _coins >= pet.price) {
      _coins -= pet.price;
      pet.isUnlocked = true;
      notifyListeners();
      _saveState();
      return true;
    }
    return false;
  }

  void addCoins(int amount) {
    _coins += amount;
    notifyListeners();
    _saveState();
  }

  void tick() {
    _currentPet.tick();
    notifyListeners();
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coins', _coins);
    await prefs.setInt('currentPet', _currentPet.type.index);
    final unlockedList = _allPets
        .where((p) => p.isUnlocked)
        .map((p) => p.type.index.toString())
        .join(',');
    await prefs.setString('unlockedPets', unlockedList);
    await prefs.setDouble('hunger', _currentPet.hunger);
    await prefs.setDouble('happiness', _currentPet.happiness);
    await prefs.setDouble('energy', _currentPet.energy);
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    _coins = prefs.getInt('coins') ?? 0;

    final unlockedStr = prefs.getString('unlockedPets') ?? '0';
    final unlockedIndices = unlockedStr.split(',').map((e) => int.tryParse(e) ?? 0).toSet();
    for (final pet in _allPets) {
      pet.isUnlocked = unlockedIndices.contains(pet.type.index);
    }

    final currentIndex = prefs.getInt('currentPet') ?? 0;
    _currentPet = _allPets.firstWhere(
      (p) => p.type.index == currentIndex,
      orElse: () => _allPets.first,
    );
    _currentPet.hunger = prefs.getDouble('hunger') ?? 0.8;
    _currentPet.happiness = prefs.getDouble('happiness') ?? 1.0;
    _currentPet.energy = prefs.getDouble('energy') ?? 1.0;
    notifyListeners();
  }
}
