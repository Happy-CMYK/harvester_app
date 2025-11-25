import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'LoginScreen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  late String _username, _email, _password;
  String? _realName, _idCard;
  bool _isLoading = false;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      
      print('📍 注册用户名: $_username');
      print('📍 注册邮箱: $_email');
      print('📍 注册密码: $_password');
      if (_realName != null && _realName!.isNotEmpty) {
        print('📍 真实姓名: $_realName');
      }
      if (_idCard != null && _idCard!.isNotEmpty) {
        print('📍 身份证号: $_idCard');
      }
      
      // 模拟网络请求延迟
      await Future.delayed(Duration(milliseconds: 500));
      
      // 检查用户名是否已存在
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('user_$_username')) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('用户名已存在，请选择其他用户名')),
        );
        return;
      }
      
      // 保存用户数据
      await prefs.setString('user_$_username', _password);
      
      // 创建用户对象
      User newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        username: _username,
        email: _email,
        realName: _realName,
        idCard: _idCard,
        isVerified: (_realName != null && _realName!.isNotEmpty) && 
                   (_idCard != null && _idCard!.isNotEmpty),
      );
      
      // 保存用户详细信息
      await prefs.setString('user_data_$_username', newUser.toJson().toString());
      
      setState(() {
        _isLoading = false;
      });
      
      // 显示注册成功消息
      String message = '注册成功';
      if (newUser.isVerified) {
        message += '，已完成实名认证';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      
      // 延迟跳转到登录页面
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade300, Colors.green.shade900],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo区域
                Icon(
                  Icons.agriculture,
                  size: 100,
                  color: Colors.white,
                ),
                SizedBox(height: 20),
                Text(
                  '收割机接单系统',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '连接农户与农机手的桥梁',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 40),
                
                // 注册表单
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 10,
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // 用户名输入
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: '用户名',
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '请输入用户名';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _username = value!;
                            },
                          ),
                          SizedBox(height: 20),
                          
                          // 邮箱输入
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: '邮箱',
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '请输入邮箱';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                return '请输入有效的邮箱地址';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _email = value!;
                            },
                          ),
                          SizedBox(height: 20),
                          
                          // 密码输入
                          TextFormField(
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              labelText: '密码',
                              prefixIcon: Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText ? Icons.visibility : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '请输入密码';
                              }
                              if (value.length < 6) {
                                return '密码长度至少6位';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _password = value!;
                            },
                          ),
                          SizedBox(height: 20),
                          
                          // 真实姓名输入（可选，用于实名认证）
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: '真实姓名（可选）',
                              prefixIcon: Icon(Icons.badge),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            onSaved: (value) {
                              _realName = value;
                            },
                          ),
                          SizedBox(height: 20),
                          
                          // 身份证号输入（可选，用于实名认证）
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: '身份证号（可选）',
                              prefixIcon: Icon(Icons.credit_card),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            onSaved: (value) {
                              _idCard = value;
                            },
                          ),
                          SizedBox(height: 30),
                          
                          // 注册按钮
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submitForm,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.all(15.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                backgroundColor: Colors.green,
                              ),
                              child: _isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    '注册',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                            ),
                          ),
                          SizedBox(height: 20),
                          
                          // 登录链接
                          RichText(
                            text: TextSpan(
                              style: TextStyle(color: Colors.black),
                              children: [
                                TextSpan(text: '已有账户？'),
                                TextSpan(
                                  text: '立即登录',
                                  style: TextStyle(color: Colors.green),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      print('📦 用户点击登录链接');
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => LoginScreen()),
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}