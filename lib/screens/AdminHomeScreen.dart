import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import '../models/order_service.dart';
import 'LoginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminHomeScreen extends StatefulWidget {
  final User currentUser;

  const AdminHomeScreen({Key? key, required this.currentUser}) : super(key: key);

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final MapController _mapController = MapController();
  late List<Order> _orders;
  late List<User> _users;
  int _currentIndex = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // 加载订单数据
      final orders = await OrderService.getAllOrders();
      setState(() {
        _orders = orders.isEmpty ? _getDefaultOrders() : orders;
        
        // 创建一些示例用户数据
        _users = _getDefaultUsers();
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _orders = _getDefaultOrders();
        _users = _getDefaultUsers();
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载数据失败: $e')),
      );
    }
  }

  List<Order> _getDefaultOrders() {
    return [
      Order(
        id: '1',
        farmerName: '张三',
        location: LatLng(39.91, 116.395),
        cropType: '小麦',
        area: '10亩',
        status: 'pending',
      ),
      Order(
        id: '2',
        farmerName: '李四',
        location: LatLng(39.92, 116.40),
        cropType: '玉米',
        area: '15亩',
        status: 'in_progress',
      ),
      Order(
        id: '3',
        farmerName: '王五',
        location: LatLng(39.90, 116.38),
        cropType: '大豆',
        area: '8亩',
        status: 'completed',
      ),
    ];
  }

  List<User> _getDefaultUsers() {
    return [
      User(
        id: 'u1',
        username: '农户张三',
        email: 'farmer1@example.com',
        realName: '张三',
        isVerified: true,
        role: 'farmer',
      ),
      User(
        id: 'u2',
        username: '农户李四',
        email: 'farmer2@example.com',
        realName: '李四',
        isVerified: true,
        role: 'farmer',
      ),
      User(
        id: 'u3',
        username: '农机手A',
        email: 'operator1@example.com',
        realName: '王五',
        isVerified: true,
        role: 'machine_operator',
        machines: [
          Machine(
            id: 'm1',
            name: '联合收割机A',
            type: '小麦收割机',
            description: '适用于小麦收割',
            hourlyRate: 150.0,
          ),
        ],
      ),
      User(
        id: 'u4',
        username: '农机手B',
        email: 'operator2@example.com',
        realName: '赵六',
        isVerified: true,
        role: 'machine_operator',
        machines: [
          Machine(
            id: 'm2',
            name: '联合收割机B',
            type: '玉米收割机',
            description: '适用于玉米收割',
            hourlyRate: 180.0,
          ),
        ],
      ),
    ];
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
        title: Text('管理员控制台'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: '刷新数据',
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: '注销',
          ),
        ],
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator())
        : _currentIndex == 0 
          ? _buildDashboardScreen()
          : _currentIndex == 1
            ? _buildMapScreen()
            : _buildUsersScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: '仪表盘',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: '地图',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: '用户',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardScreen() {
    // 统计数据
    int totalOrders = _orders.length;
    int pendingOrders = _orders.where((order) => order.status == 'pending').length;
    int inProgressOrders = _orders.where((order) => order.status == 'in_progress').length;
    int completedOrders = _orders.where((order) => order.status == 'completed').length;
    int totalUsers = _users.length;
    int farmers = _users.where((user) => user.role == 'farmer').length;
    int operators = _users.where((user) => user.role == 'machine_operator').length;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '系统概览',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            
            // 订单统计卡片
            Text(
              '订单统计',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildStatCard('总订单数', '$totalOrders', Colors.blue),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard('待接单', '$pendingOrders', Colors.orange),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _buildStatCard('进行中', '$inProgressOrders', Colors.purple),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard('已完成', '$completedOrders', Colors.green),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _buildStatCard('取消率', '${totalOrders > 0 ? ((_orders.where((order) => order.status == 'cancelled').length / totalOrders) * 100).toStringAsFixed(1) : '0'}%', Colors.red),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            
            // 用户统计卡片
            Text(
              '用户统计',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildStatCard('总用户数', '$totalUsers', Colors.blue),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard('农户', '$farmers', Colors.green),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _buildStatCard('农机手', '$operators', Colors.orange),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            
            // 最近订单列表
            Text(
              '最近订单',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: _orders.isEmpty
                  ? Center(
                      child: Text(
                        '暂无订单',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : Column(
                      children: _orders.take(5).map((order) {
                        return ListTile(
                          title: Text('${order.farmerName} - ${order.cropType}'),
                          subtitle: Text('面积: ${order.area} | 状态: ${_getStatusText(order.status)}'),
                          trailing: Icon(
                            _getStatusIcon(order.status),
                            color: _getStatusColor(order.status),
                          ),
                        );
                      }).toList(),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapScreen() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        center: LatLng(39.91, 116.395),
        zoom: 13.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.harvester_app',
        ),
        MarkerLayer(
          markers: _orders.map((order) {
            Color markerColor;
            IconData iconData;
            
            switch (order.status) {
              case 'pending':
                markerColor = Colors.red;
                iconData = Icons.location_on;
                break;
              case 'in_progress':
                markerColor = Colors.orange;
                iconData = Icons.directions_run;
                break;
              case 'completed':
                markerColor = Colors.green;
                iconData = Icons.check_circle;
                break;
              case 'cancelled':
                markerColor = Colors.grey;
                iconData = Icons.cancel;
                break;
              default:
                markerColor = Colors.red;
                iconData = Icons.location_on;
            }
            
            return Marker(
              width: 80.0,
              height: 80.0,
              point: order.location,
              child: IconButton(
                icon: Icon(
                  iconData,
                  color: markerColor,
                  size: 40.0,
                ),
                onPressed: () {
                  _showOrderDetails(order);
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildUsersScreen() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '用户管理',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          
          // 用户列表
          Expanded(
            child: ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: user.role == 'farmer' ? Colors.green : Colors.orange,
                      child: Icon(
                        user.role == 'farmer' ? Icons.person : Icons.agriculture,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(user.username),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.realName ?? '未实名'),
                        Text(user.email ?? ''),
                        Text(
                          user.role == 'farmer' ? '农户' : '农机手',
                          style: TextStyle(
                            color: user.role == 'farmer' ? Colors.green : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    trailing: user.isVerified 
                      ? Icon(Icons.verified, color: Colors.blue) 
                      : Icon(Icons.warning, color: Colors.orange),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(Order order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('订单详情'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('订单号: ${order.id}'),
                SizedBox(height: 8),
                Text('农户: ${order.farmerName}'),
                SizedBox(height: 8),
                Text('作物: ${order.cropType}'),
                SizedBox(height: 8),
                Text('面积: ${order.area}'),
                SizedBox(height: 8),
                Text('位置: ${order.location.latitude.toStringAsFixed(4)}, ${order.location.longitude.toStringAsFixed(4)}'),
                SizedBox(height: 8),
                Text('状态: ${_getStatusText(order.status)}'),
                if (order.description != null && order.description!.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Text('描述: ${order.description}'),
                ],
                if (order.assignedTo != null) ...[
                  SizedBox(height: 8),
                  Text('分配给: ${order.assignedTo}'),
                ],
                if (order.startTime != null) ...[
                  SizedBox(height: 8),
                  Text('开始时间: ${order.startTime}'),
                ],
                if (order.endTime != null) ...[
                  SizedBox(height: 8),
                  Text('结束时间: ${order.endTime}'),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('关闭'),
            ),
          ],
        );
      },
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending': return '待接单';
      case 'in_progress': return '进行中';
      case 'completed': return '已完成';
      case 'cancelled': return '已取消';
      default: return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending': return Icons.pending;
      case 'in_progress': return Icons.directions_run;
      case 'completed': return Icons.check_circle;
      case 'cancelled': return Icons.cancel;
      default: return Icons.help;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.red;
      case 'in_progress': return Colors.orange;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.grey;
      default: return Colors.black;
    }
  }
}