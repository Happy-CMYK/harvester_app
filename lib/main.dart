import 'package:flutter/material.dart';
import 'screens/SimpleRoleSelectionScreen.dart';
import 'screens/LoginScreen.dart';
import 'screens/RegisterScreen.dart';
import 'screens/FarmerHomeScreen.dart';
import 'screens/MachineOperatorHomeScreen.dart';
import 'screens/RoleSelectionScreen.dart';
import 'screens/PublishOrderScreen.dart';
import 'screens/MachineManagementScreen.dart';
import 'screens/SmartDispatchScreen.dart';
import 'screens/AdminHomeScreen.dart';
import 'screens/PaymentScreen.dart';
import 'screens/ReviewScreen.dart';
import 'screens/NotificationScreen.dart';
import 'screens/IoTDeviceScreen.dart';
import 'screens/AgreementScreen.dart';
import 'NetworkOverride.dart';
import 'dart:io';

void main() {
  // 解决SSL证书问题
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '收割机接单系统',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SimpleRoleSelectionScreen(), // 使用简单的角色选择屏幕作为入口
      debugShowCheckedModeBanner: false,
    );
  }
}