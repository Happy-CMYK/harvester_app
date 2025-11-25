# Harvester Order App

A mobile application for farmers to place orders for harvesting services.

## 🚀 Features

- 用户登录/注册功能
- 交互式地图显示订单位置
- 订单创建与管理
- 实时调试功能
- 针对中国网络环境优化

## 🛠️ Setup & Configuration

### Prerequisites

1. Install [Flutter SDK](https://flutter.dev/docs/get-started/install)
2. Install [Android Studio](https://developer.android.com/studio) or Xcode for emulator
3. Install [JDK 11](https://adoptium.net/?variant=openjdk11&jvmVariant=hotspot)
4. Configure Flutter environment variables for China:
   ```bash
   PUB_HOSTED_URL=https://pub.flutter-io.cn
   FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
   ```

### Environment Setup

After installing the prerequisites, run the setup script:
```bash
setup_env.bat
```

Or manually set the environment variables:
1. JAVA_HOME = C:\Program Files\Eclipse Adoptium\jdk-11.0.25-hotspot
2. ANDROID_HOME = %USERPROFILE%\AppData\Local\Android\Sdk
3. Add to PATH:
   - %JAVA_HOME%\bin
   - %ANDROID_HOME%\tools
   - %ANDROID_HOME%\platform-tools
   - %ANDROID_HOME%\build-tools\36.0.0

### Installation

```bash
flutter pub get
```

### Running the App

#### For Android:
```bash
flutter run
```

## 🔐 登录/注册功能

应用启动后会进入登录页面，用户可以：
- 使用任意用户名和密码（长度至少6位）登录
- 点击"立即注册"链接进入注册页面

在注册页面可以：
- 输入用户名、邮箱和密码进行注册
- 点击"立即登录"链接返回登录页面

登录成功后将进入主界面，可以：
- 查看地图上的订单标记
- 点击标记查看订单详情
- 接受订单
- 通过右上角按钮注销

## 🗺 Map Configuration

This app uses OpenStreetMap through the flutter_map package. For production use in China, you may want to replace it with AMap (Gaode) or Baidu Maps.

## 📁 Project Structure

```
harvester_app/
├── lib/
│   ├── main.dart
│   ├── NetworkOverride.dart
│   ├── setup_env.bat
│   └── screens/
│       ├── LoginScreen.dart
│       ├── RegisterScreen.dart
│       └── FarmerHomeScreen.dart
├── android/
│   ├── build.gradle
│   ├── local.properties
│   └── gradle/
│       └── wrapper/
│           └── gradle-wrapper.properties
├── pubspec.yaml
└── README.md
```

## 🐞 Debugging Guide

Use print statements with emoji prefixes for easy filtering:

```dart
print('📍 用户名: $_username');
print('📦 用户点击注册链接');
print('✅ 接受订单 ${order.id}');
```

Check the terminal output when running the app to see these logs.

## 🚀 Troubleshooting

### Network Issues
If you encounter SSL certificate errors, the app includes a network override solution:
1. The app uses `HttpOverrides` to bypass SSL certificate validation
2. Gradle is configured to use Aliyun mirrors for faster downloads

### Gradle Build Issues
If Gradle fails to download dependencies:
1. Ensure you're using the Aliyun mirrors in `android/build.gradle`
2. Check `android/gradle/wrapper/gradle-wrapper.properties` for correct distribution URL
3. Verify `android/gradle.properties` contains proper mirror settings

### Common Errors
- "Gradle task assembleDebug failed": Check your network connection and try again
- "Unable to find valid certification path": This is a network/SSL issue, the app includes a bypass solution
- "Connection reset": Usually a network issue, try using a VPN or different network
- Kotlin compilation errors: Try upgrading Flutter or using a stable Flutter channel
- "java is not recognized": Install JDK 11 and set JAVA_HOME environment variable

### Additional Network Solutions
If problems persist:
1. Use a VPN to bypass network restrictions
2. Configure your Java environment to trust the certificates
3. Manually download and install Gradle