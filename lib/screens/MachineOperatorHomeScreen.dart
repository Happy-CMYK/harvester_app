import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import '../models/order_service.dart';
import '../models/scheduling_service.dart';
import 'LoginScreen.dart';
import 'MachineManagementScreen.dart';
import 'SmartDispatchScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class MachineOperatorHomeScreen extends StatefulWidget {
  final User? currentUser;

  const MachineOperatorHomeScreen({Key? key, this.currentUser}) : super(key: key);

  @override
  _MachineOperatorHomeScreenState createState() => _MachineOperatorHomeScreenState();
}

class _MachineOperatorHomeScreenState extends State<MachineOperatorHomeScreen> {
  final MapController _mapController = MapController();
  late List<Order> _orders;
  late User? _currentUser;
  bool _isAcceptingOrders = false;
  bool _isLoading = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.currentUser;
    _loadOrders();
  }

  void _loadOrders() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final orders = await OrderService.getOperatorOrders(_currentUser?.id ?? 'operator_1');
      setState(() {
        _orders = orders.isEmpty ? _getDefaultOrders() : orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _orders = _getDefaultOrders();
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载订单失败: $e')),
      );
    }
  }

  List<Order> _getDefaultOrders() {
    return [
      Order(
        id: '1',
        farmerName: '测试农户',
        location: LatLng(39.91, 116.395),
        cropType: '小麦',
        area: '10亩',
        status: 'pending',
        price: 1500.0,
      ),
      Order(
        id: '2',
        farmerName: '测试农户',
        location: LatLng(39.92, 116.40),
        cropType: '玉米',
        area: '15亩',
        status: 'in_progress',
        price: 2250.0,
      ),
      Order(
        id: '3',
        farmerName: '测试农户',
        location: LatLng(39.90, 116.38),
        cropType: '大豆',
        area: '8亩',
        status: 'completed',
        price: 1200.0,
      ),
    ];
  }

  void _toggleAcceptingOrders() {
    setState(() {
      _isAcceptingOrders = !_isAcceptingOrders;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isAcceptingOrders ? '已开启接单模式' : '已关闭接单模式'),
        backgroundColor: _isAcceptingOrders ? Colors.green : Colors.grey,
      ),
    );
  }

  void _acceptOrder(Order order) async {
    // 创建一个临时的User对象用于接受订单
    User operator = _currentUser ?? User(
      id: 'default_operator',
      username: '默认农机手',
      email: 'default@example.com',
    );
    
    try {
      final result = await OrderService.acceptOrder(order.id, operator);
      if (result) {
        // 手动更新订单状态
        setState(() {
          _orders = _orders.map((o) {
            if (o.id == order.id) {
              return Order(
                id: o.id,
                farmerName: o.farmerName,
                location: o.location,
                cropType: o.cropType,
                area: o.area,
                status: 'in_progress',
                description: o.description,
                assignedTo: operator.username,
                startTime: DateTime.now().toString(),
                price: o.price,
              );
            }
            return o;
          }).toList() as List<Order>;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('订单接受成功'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('订单接受失败');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('订单接受失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _completeOrder(Order order) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('确认完成'),
          content: Text('确定要将订单 ${order.id} 标记为已完成吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('取消'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('确认'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        final result = await OrderService.completeOrder(order.id);
        if (result) {
          // 手动更新订单状态
          setState(() {
            _orders = _orders.map((o) {
              if (o.id == order.id) {
                return Order(
                  id: o.id,
                  farmerName: o.farmerName,
                  location: o.location,
                  cropType: o.cropType,
                  area: o.area,
                  status: 'completed',
                  description: o.description,
                  assignedTo: o.assignedTo,
                  startTime: o.startTime,
                  endTime: DateTime.now().toString(),
                  price: o.price,
                );
              }
              return o;
            }).toList() as List<Order>;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('订单已完成'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception('订单完成失败');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('订单完成失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _cancelOrder(Order order) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('确认取消'),
          content: Text('确定要取消订单 ${order.id} 吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('取消'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('确认'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        final result = await OrderService.cancelOrder(order.id);
        if (result) {
          // 手动更新订单状态
          setState(() {
            _orders = _orders.map((o) {
              if (o.id == order.id) {
                return Order(
                  id: o.id,
                  farmerName: o.farmerName,
                  location: o.location,
                  cropType: o.cropType,
                  area: o.area,
                  status: 'cancelled',
                  description: o.description,
                  assignedTo: o.assignedTo,
                  startTime: o.startTime,
                  endTime: o.endTime,
                  price: o.price,
                );
              }
              return o;
            }).toList() as List<Order>;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('订单已取消'),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          throw Exception('订单取消失败');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('订单取消失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToMachineManagement() {
    if (_currentUser != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MachineManagementScreen(currentUser: _currentUser!),
        ),
      ).then((value) {
        if (value != null && value is User) {
          setState(() {
            _currentUser = value;
          });
        }
      });
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

  void _showOrderDialog(Order order) {
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
                if (order.price != null) ...[
                  SizedBox(height: 8),
                  Text('价格: ¥${order.price!.toStringAsFixed(2)}'),
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
            if (order.status == 'pending' && _isAcceptingOrders) ...[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _acceptOrder(order);
                },
                child: Text('接受订单'),
              ),
            ],
            if (order.status == 'in_progress') ...[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _completeOrder(order);
                },
                child: Text('标记完成'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _cancelOrder(order);
                },
                child: Text('取消订单'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
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

  // 计算统计数据
  Map<String, int> _calculateStats() {
    int pendingCount = _orders.where((order) => order.status == 'pending').length;
    int inProgressCount = _orders.where((order) => order.status == 'in_progress').length;
    int completedCount = _orders.where((order) => order.status == 'completed').length;
    
    return {
      'pending': pendingCount,
      'inProgress': inProgressCount,
      'completed': completedCount,
    };
  }

  @override
  Widget build(BuildContext context) {
    Map<String, int> stats = _calculateStats();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('农机手工作台'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          // 接单模式开关
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: _isAcceptingOrders ? Colors.green : Colors.grey,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    _isAcceptingOrders ? Icons.check_circle : Icons.cancel,
                    color: Colors.white,
                    size: 20,
                  ),
                  GestureDetector(
                    onTap: _toggleAcceptingOrders,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        _isAcceptingOrders ? '接单中' : '已关闭',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 农机管理
          IconButton(
            icon: Icon(Icons.agriculture),
            onPressed: _navigateToMachineManagement,
            tooltip: '农机信息管理',
          ),
          
          // 注销
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
          ? _buildMapScreen()
          : _buildOrderListScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: '地图',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '订单列表',
          ),
        ],
      ),
    );
  }

  Widget _buildMapScreen() {
    return Column(
      children: [
        // 顶部统计信息
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('待接单', '${_calculateStats()['pending']}', Colors.red),
              _buildStatItem('进行中', '${_calculateStats()['inProgress']}', Colors.orange),
              _buildStatItem('已完成', '${_calculateStats()['completed']}', Colors.green),
            ],
          ),
        ),
        // 地图区域
        Expanded(
          child: FlutterMap(
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
                  
                  // 移除了进行中的订单的导航按钮功能
                  Widget markerWidget = IconButton(
                    icon: Icon(
                      iconData,
                      color: markerColor,
                      size: 40.0,
                    ),
                    onPressed: () {
                      print('📍 订单标记被点击: ${order.toJson()}');
                      _showOrderDialog(order);
                    },
                  );
                  
                  return Marker(
                    width: 80.0,
                    height: 80.0,
                    point: order.location,
                    child: markerWidget,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderListScreen() {
    final pendingOrders = _orders.where((order) => order.status == 'pending').toList();
    final inProgressOrders = _orders.where((order) => order.status == 'in_progress').toList();
    final completedOrders = _orders.where((order) => order.status == 'completed').toList();
    final cancelledOrders = _orders.where((order) => order.status == 'cancelled').toList();
    
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          // 顶部统计信息
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('待接单', '${pendingOrders.length}', Colors.red),
                _buildStatItem('进行中', '${inProgressOrders.length}', Colors.orange),
                _buildStatItem('已完成', '${completedOrders.length}', Colors.green),
              ],
            ),
          ),
          TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: '待接单 (${pendingOrders.length})'),
              Tab(text: '进行中 (${inProgressOrders.length})'),
              Tab(text: '已完成 (${completedOrders.length})'),
              Tab(text: '已取消 (${cancelledOrders.length})'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildOrderListView(pendingOrders, 'pending'),
                _buildOrderListView(inProgressOrders, 'in_progress'),
                _buildOrderListView(completedOrders, 'completed'),
                _buildOrderListView(cancelledOrders, 'cancelled'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderListView(List<Order> orders, String status) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == 'pending' ? Icons.inbox_outlined : 
              status == 'in_progress' ? Icons.directions_run_outlined :
              status == 'completed' ? Icons.check_circle_outline : 
              Icons.cancel_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              status == 'pending' ? '暂无待接单' : 
              status == 'in_progress' ? '暂无进行中订单' :
              status == 'completed' ? '暂无已完成订单' : 
              '暂无已取消订单',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          elevation: 2,
          child: ListTile(
            title: Text('${order.farmerName} - ${order.cropType}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('面积: ${order.area}'),
                Text('位置: ${order.location.latitude.toStringAsFixed(4)}, ${order.location.longitude.toStringAsFixed(4)}'),
                if (order.description != null && order.description!.isNotEmpty)
                  Text('描述: ${order.description}'),
                if (order.price != null)
                  Text('价格: ¥${order.price!.toStringAsFixed(2)}'),
                Text('订单状态: ${_getStatusText(order.status)}'),
              ],
            ),
            trailing: _buildOrderActionButtons(order),
            onTap: () => _showOrderDialog(order),
          ),
        );
      },
    );
  }

  Widget _buildOrderActionButtons(Order order) {
    switch (order.status) {
      case 'pending':
        return ElevatedButton(
          onPressed: _isAcceptingOrders ? () => _acceptOrder(order) : null,
          child: Text('接受'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isAcceptingOrders ? Colors.green : Colors.grey,
          ),
        );
      case 'in_progress':
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 移除了导航按钮
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () => _completeOrder(order),
                  child: Text('完成'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: Size(60, 30),
                    padding: EdgeInsets.zero,
                  ),
                ),
                SizedBox(width: 5),
                ElevatedButton(
                  onPressed: () => _cancelOrder(order),
                  child: Text('取消'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: Size(60, 30),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        );
      default:
        return Container();
    }
  }
}