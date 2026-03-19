# PetWallpaper

> PC 움직이는 동물의 모바일 버전! 화면 위를 자유롭게 돌아다니는 귀여운 픽셀아트 동물 앱

옛날 PC 바탕화면에서 돌아다니던 움직이는 동물 기억하시나요?
ScreenMates, Desktop Pets... 그 추억을 스마트폰에서!

## 동물 종류

| 동물 | 이름 | 가격 |
|------|------|------|
| 🐱 고양이 | 냥이 | 무료 |
| 🐶 강아지 | 멍멍이 | 1,200코인 |
| 🐰 토끼 | 토순이 | 1,200코인 |
| 🐼 팬더 | 판다 | 2,400코인 |
| 🐹 햄스터 | 햄토리 | 1,200코인 |

모든 동물은 Flutter `CustomPaint`로 직접 그린 픽셀아트 스타일입니다.

## 인터랙션

- **터치** — 펫을 터치하면 깜짝 놀라서 점프!
- **먹이주기** — 🐟 버튼으로 먹이 던져주기 (펫이 달려와서 먹음)
- **함께 놀기** — 🎾 버튼으로 에너지 소모 + 행복도 상승
- **감정 표현** — 배고픔/행복/졸림/흥분/슬픔 5가지 상태
- **자동 이동** — 랜덤하게 방향을 바꾸며 화면을 돌아다님
- **벽 반사** — 화면 끝에 닿으면 튕겨서 반대 방향으로 이동

## 펫 상태 시스템

```
hunger (배고픔)   0.0 ──────────── 1.0
happiness (행복)  0.0 ──────────── 1.0
energy (에너지)   0.0 ──────────── 1.0

시간이 지나면 hunger, energy 감소
먹이주기 → hunger +0.3, happiness +0.1
함께놀기 → happiness +0.2, energy -0.2
```

## Android Live Wallpaper 설정 방법

1. 앱 실행 후 **설정** 탭 이동
2. **"Live Wallpaper로 설정"** 버튼 탭
3. 시스템 배경화면 선택 화면에서 **PetWallpaper** 선택
4. **"배경화면 설정"** 탭

또는 직접 설정:
> 설정 → 배경화면 → 배경화면 변경 → 라이브 배경화면 → PetWallpaper

## 수익 구조

```
무료
└── 고양이 1마리 기본 제공
└── 모든 인터랙션 사용 가능
└── 앱 내 코인 획득 가능

유료 (코인 구매 또는 인앱 결제)
└── 강아지, 토끼, 팬더, 햄스터
└── 배경 테마 변경 (숲, 우주, 바닷속)
└── 펫 이름 변경
└── 특별 아이템 (모자, 목도리 등)
```

## 기술 스택

- **Flutter** 3.19+ / **Dart** 3.0+
- `CustomPaint` + `Canvas` — 픽셀아트 동물 직접 렌더링
- `WallpaperService` (Kotlin) — Android Live Wallpaper
- `provider` — 펫 상태 관리
- `shared_preferences` — 펫 상태 저장
- `audioplayers` — 효과음 (냐옹, 멍멍 등)
- `lottie` — UI 애니메이션

## 빌드 방법

```bash
# 의존성 설치
flutter pub get

# 디버그 실행
flutter run

# 릴리즈 APK
flutter build apk --release

# Play Store AAB
flutter build appbundle --release
```

## 최소 요구 사양

- Android 5.0 (API 21) 이상
- Live Wallpaper: Android 2.1 (API 7) 이상

## 프로젝트 구조

```
lib/
├── main.dart                          # 앱 진입점
├── core/theme/app_theme.dart          # 파스텔 핑크 테마
├── models/pet.dart                    # Pet 모델 + PetProvider
├── services/animation_service.dart    # 이동/점프/먹기 애니메이션 로직
└── features/
    ├── pet/
    │   ├── pet_screen.dart            # 메인 펫 화면 (Canvas 애니메이션)
    │   └── pet_widget.dart            # 5종 픽셀아트 동물 CustomPainter
    ├── shop/shop_screen.dart          # 동물/아이템 구매 화면
    └── settings/settings_screen.dart  # 동물 선택, Live Wallpaper 설정

android/app/src/main/kotlin/com/petwallpaper/
├── MainActivity.kt                    # Live Wallpaper 설정 MethodChannel
└── PetWallpaperService.kt             # Android WallpaperService (Kotlin Canvas)
```

## Live Wallpaper 동작 방식

```
Flutter 앱 (UI/설정) ←→ MethodChannel ←→ MainActivity.kt
                                              ↓
                                    PetWallpaperService.kt
                                    (WallpaperService 상속)
                                    Canvas로 직접 렌더링
                                    50ms 주기 (20fps)
```

Android Live Wallpaper는 Flutter 렌더링 엔진이 아닌
네이티브 Kotlin `WallpaperService`에서 `Canvas`로 직접 그립니다.
