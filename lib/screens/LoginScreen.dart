import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'RegisterScreen.dart';
import 'RoleSelectionScreen.dart';
import 'FarmerHomeScreen.dart';
import 'MachineOperatorHomeScreen.dart';
import 'AdminHomeScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  late String _username, _password;
  bool _isLoading = false;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      
      // 模拟网络请求延迟
      await Future.delayed(Duration(milliseconds: 500));
      
      // 验证用户凭据
      User? user = await _validateCredentials(_username, _password);
      
      setState(() {
        _isLoading = false;
      });
      
      if (user != null) {
        // 保存登录状态
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('username', _username);
        
        String successMessage = '登录成功';
        if (!user.isVerified && user.username != 'admin') {
          successMessage += '，请尽快完成实名认证';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage)),
        );
        
        // 根据用户名和角色决定跳转到哪个主页面
        if (user.username == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AdminHomeScreen(currentUser: user),
            ),
          );
        } else if (user.role == 'farmer') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => FarmerHomeScreen(currentUser: user),
            ),
          );
        } else if (user.role == 'machine_operator') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MachineOperatorHomeScreen(currentUser: user),
            ),
          );
        } else {
          // 用户没有角色信息，需要选择角色
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RoleSelectionScreen(currentUser: user),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('用户名或密码错误')),
        );
      }
    }
  }

  Future<User?> _validateCredentials(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    String? storedPassword = prefs.getString('user_$username');
    String? userDataJson = prefs.getString('user_data_$username');
    
    // 检查是否为管理员账号
    if (username == 'admin' && password == 'admin123') {
      return User(
        id: 'admin_id',
        username: 'admin',
        email: 'admin@example.com',
        realName: '管理员',
        isVerified: true,
        role: 'admin', // 管理员角色
      );
    }
    
    // 如果找到存储的用户并且密码匹配，则验证成功
    if (storedPassword != null && storedPassword == password) {
      if (userDataJson != null) {
        // 解析用户详细信息
        Map<String, dynamic> userData = {};
        RegExp regExp = RegExp(r'"([^"]+)"\s*:\s*"([^"]*)"');
        Iterable<RegExpMatch> matches = regExp.allMatches(userDataJson);
        for (var match in matches) {
          userData[match.group(1)!] = match.group(2);
        }
        
        // 简化的用户对象创建
        return User(
          id: userData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          username: username,
          email: userData['email'] ?? '',
          realName: userData['realName'],
          idCard: userData['idCard'],
          isVerified: userData['isVerified'] == 'true',
          role: userData['role'],
        );
      } else {
        // 创建默认用户对象
        return User(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          username: username,
          email: '',
        );
      }
    }
    
    // 如果是默认的测试用户，也允许登录
    if (username == 'test' && password == '123456') {
      return User(
        id: '1',
        username: 'test',
        email: 'test@example.com',
        isVerified: false,
      );
    }
    
    return null;
  }

  // 管理员快速登录
  void _adminLogin() async {
    setState(() {
      _isLoading = true;
    });
    
    // 模拟网络请求延迟
    await Future.delayed(Duration(milliseconds: 500));
    
    // 创建管理员用户
    User adminUser = User(
      id: 'admin_id',
      username: 'admin',
      email: 'admin@example.com',
      realName: '管理员',
      isVerified: true,
      role: 'admin', // 管理员角色
    );
    
    setState(() {
      _isLoading = false;
    });
    
    // 保存登录状态
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('username', 'admin');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('管理员登录成功')),
    );
    
    // 跳转到管理员主页
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AdminHomeScreen(currentUser: adminUser),
      ),
    );
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
                
                // 登录表单
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
                          SizedBox(height: 30),
                          
                          // 登录按钮
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
                                    '登录',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                            ),
                          ),
                          SizedBox(height: 10),
                          
                          // 管理员快速登录按钮
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _isLoading ? null : _adminLogin,
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.all(15.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                side: BorderSide(color: Colors.green),
                              ),
                              child: _isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    '管理员快速登录',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.green,
                                    ),
                                  ),
                            ),
                          ),
                          SizedBox(height: 20),
                          
                          // 注册链接
                          RichText(
                            text: TextSpan(
                              style: TextStyle(color: Colors.black),
                              children: [
                                TextSpan(text: '还没有账户？'),
                                TextSpan(
                                  text: '立即注册',
                                  style: TextStyle(color: Colors.green),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      print('📦 用户点击注册链接');
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => RegisterScreen()),
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