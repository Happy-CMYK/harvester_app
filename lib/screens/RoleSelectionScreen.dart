import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'FarmerHomeScreen.dart';
import 'MachineOperatorHomeScreen.dart';
import 'LoginScreen.dart';
import '../models/user_model.dart';

class RoleSelectionScreen extends StatefulWidget {
  final User currentUser;

  const RoleSelectionScreen({Key? key, required this.currentUser}) : super(key: key);

  @override
  _RoleSelectionScreenState createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 如果用户已经有角色信息，预选该角色
    if (widget.currentUser.role != null && widget.currentUser.role!.isNotEmpty) {
      _selectedRole = widget.currentUser.role;
    }
  }

  void _selectRole(String role) {
    setState(() {
      _selectedRole = role;
    });
  }

  void _confirmRole() async {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请选择您的身份')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 保存用户选择的角色
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role_${widget.currentUser.username}', _selectedRole!);
      
      // 更新用户数据中的角色信息
      User updatedUser = User(
        id: widget.currentUser.id,
        username: widget.currentUser.username,
        email: widget.currentUser.email,
        realName: widget.currentUser.realName,
        idCard: widget.currentUser.idCard,
        isVerified: widget.currentUser.isVerified,
        machines: widget.currentUser.machines,
        role: _selectedRole,
      );
      
      // 保存更新后的用户数据
      await prefs.setString('user_data_${widget.currentUser.username}', updatedUser.toJson().toString());
      
      // 延迟跳转以显示加载状态
      Future.delayed(Duration(milliseconds: 500), () {
        setState(() {
          _isLoading = false;
        });
        
        // 根据选择的角色导航到相应的主屏幕
        if (_selectedRole == 'farmer') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => FarmerHomeScreen(currentUser: updatedUser),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MachineOperatorHomeScreen(currentUser: updatedUser),
            ),
          );
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存角色信息失败: $e')),
      );
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('选择身份'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: '注销',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '欢迎 ${widget.currentUser.username}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '请选择您的身份',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 40),
            
            // 农户角色卡片
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: _selectedRole == 'farmer' 
                  ? BorderSide(color: Colors.green, width: 3) 
                  : BorderSide.none,
              ),
              child: InkWell(
                onTap: () => _selectRole('farmer'),
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: _selectedRole == 'farmer' 
                      ? Colors.green.withOpacity(0.1) 
                      : Colors.white,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.person,
                        size: 80,
                        color: Colors.green,
                      ),
                      SizedBox(height: 20),
                      Text(
                        '我是农户',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '发布收割订单，寻找附近农机手',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 10),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.green,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            
            // 农机手角色卡片
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: _selectedRole == 'machine_operator' 
                  ? BorderSide(color: Colors.green, width: 3) 
                  : BorderSide.none,
              ),
              child: InkWell(
                onTap: () => _selectRole('machine_operator'),
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: _selectedRole == 'machine_operator' 
                      ? Colors.green.withOpacity(0.1) 
                      : Colors.white,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.agriculture,
                        size: 80,
                        color: Colors.green,
                      ),
                      SizedBox(height: 20),
                      Text(
                        '我是农机手',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '接收农户订单，提供收割服务',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 10),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.green,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 40),
            
            // 确认按钮
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmRole,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          '处理中...',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      '确认身份',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}