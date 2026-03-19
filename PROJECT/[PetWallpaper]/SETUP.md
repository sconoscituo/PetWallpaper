# PetWallpaper - 프로젝트 설정 가이드

## 프로젝트 소개

PetWallpaper는 모든 앱 위에 동물 캐릭터가 자유롭게 돌아다니는 오버레이 방식의 Flutter 앱입니다. Lottie 애니메이션, 사운드 효과, 커스텀 동물 선택 기능을 제공하며 Android를 지원합니다.

- **기술 스택**: Flutter (Dart), flutter_overlay_window, lottie, audioplayers, provider
- **플랫폼**: Android
- **외부 API**: 없음 (로컬 애셋 기반)

---

## 필요한 API 키 / 환경변수

PetWallpaper는 외부 API를 사용하지 않습니다. 별도의 API 키나 환경변수 설정이 필요하지 않습니다.

단, Android 빌드 시 **서명 키(Keystore)**가 필요합니다.

---

## GitHub Secrets 설정 방법

Google Play 배포를 위한 서명 자동화가 필요한 경우, 저장소의 **Settings > Secrets and variables > Actions** 에서 아래 Secrets를 등록합니다.

```
KEYSTORE_BASE64          = <base64로 인코딩한 keystore 파일>
KEY_ALIAS                = <키 별칭>
KEY_PASSWORD             = <키 비밀번호>
STORE_PASSWORD           = <키스토어 비밀번호>
```

Keystore를 base64로 변환하는 방법:

```bash
base64 -w 0 your-keystore.jks
```

---

## 로컬 개발 환경 설정

### 사전 요구사항

- Flutter SDK 3.0.0 이상 ([https://flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install))
- Android Studio 또는 VS Code
- Android SDK (API 21 이상)

### 1. 저장소 클론

```bash
git clone https://github.com/sconoscituo/PetWallpaper.git
cd PetWallpaper
```

### 2. 의존성 설치

```bash
flutter pub get
```

### 3. 애셋 확인

다음 디렉토리에 필요한 애셋이 있는지 확인합니다.

```
assets/
  images/     # 동물 이미지
  sounds/     # 효과음 파일
  animations/ # Lottie 애니메이션 파일
```

### 4. Android 오버레이 권한 설정

`AndroidManifest.xml`에 오버레이 권한이 선언되어 있어야 합니다.

```xml
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
```

---

## 실행 방법

### 개발 빌드 실행

```bash
flutter run
```

### 릴리즈 APK 빌드

```bash
flutter build apk --release
```

빌드된 APK 위치: `build/app/outputs/flutter-apk/app-release.apk`

### 테스트 실행

```bash
flutter test
```
