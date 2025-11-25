import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import '../models/order_service.dart';
import '../models/notification_service.dart';
import '../models/payment_service.dart';
import '../models/review_model.dart';
import 'LoginScreen.dart';
import 'PublishOrderScreen.dart';
import 'NotificationScreen.dart';
import 'PaymentScreen.dart';
import 'ReviewScreen.dart';
import '../models/service_agreement.dart';
import 'AgreementScreen.dart';
import 'SmartDispatchScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FarmerHomeScreen extends StatefulWidget {
  final User? currentUser;

  const FarmerHomeScreen({Key? key, this.currentUser}) : super(key: key);

  @override
  _FarmerHomeScreenState createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  final MapController _mapController = MapController();
  late List<Order> _orders;
  late User? _currentUser;
  int _currentIndex = 0;
  bool _isLoading = false;

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
      final orders = await OrderService.getFarmerOrders(_currentUser?.id ?? 'farmer_1');
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

  void _publishOrder() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PublishOrderScreen(),
      ),
    );

    if (result != null && result is Order) {
      // 发布订单成功后刷新订单列表
      _loadOrders();
      
      // 显示智能推荐农机手的选项
      _showSmartDispatchOption(result);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('订单发布成功')),
      );
    }
  }

  void _showSmartDispatchOption(Order order) async {
    // 创建一些示例农机手数据，包含虚拟号码
    List<User> mockOperators = [
      User(
        id: 'op1',
        username: '农机手A',
        email: 'operatorA@example.com',
        phone: '13800138001', // 真实手机号
        virtualPhone: '400-888-0001', // 虚拟号码
        realName: '张师傅',
        isVerified: true,
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
        id: 'op2',
        username: '农机手B',
        email: 'operatorB@example.com',
        phone: '13800138002', // 真实手机号
        virtualPhone: '400-888-0002', // 虚拟号码
        realName: '李师傅',
        isVerified: true,
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
      User(
        id: 'op3',
        username: '农机手C',
        email: 'operatorC@example.com',
        phone: '13800138003', // 真实手机号
        virtualPhone: '400-888-0003', // 虚拟号码
        realName: '王师傅',
        isVerified: true,
        machines: [
          Machine(
            id: 'm3',
            name: '多功能收割机',
            type: '通用收割机',
            description: '适用于多种作物收割',
            hourlyRate: 200.0,
          ),
        ],
      ),
    ];

    // 显示智能派单选项
    bool? shouldDispatch = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('智能推荐'),
          content: Text('是否立即为您的订单智能推荐附近的农机手？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('稍后'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('立即推荐'),
            ),
          ],
        );
      },
    );

    if (shouldDispatch == true) {
      // 进入智能派单界面
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SmartDispatchScreen(
            order: order,
            availableOperators: mockOperators,
          ),
        ),
      );

      if (result != null && result is User) {
        // 在实际应用中，这里会处理派单结果
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已成功派单给 ${result.username}'),
            backgroundColor: Colors.green,
          ),
        );
        _loadOrders(); // 重新加载订单
      }
    }
  }

  void _makePayment(Order order) async {
    if (order.price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('订单价格未设定')),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          order: order,
          amount: order.price!,
        ),
      ),
    );

    if (result != null && result is PaymentResult) {
      if (result.success) {
        // 更新订单状态为已支付
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('支付成功'),
            backgroundColor: Colors.green,
          ),
        );
        _loadOrders(); // 重新加载订单
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('支付失败: ${result.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _leaveReview(Order order) async {
    if (_currentUser == null) return;
    
    // 在实际应用中，这里会获取农机手信息
    User operator = User(
      id: 'operator_mock',
      username: '农机手示例',
      email: 'operator@example.com',
    );

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewScreen(
          order: order,
          reviewer: _currentUser!,
          reviewee: operator,
        ),
      ),
    );

    if (result != null && result is bool && result) {
      // 更新订单状态为已评价
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('评价成功'),
          backgroundColor: Colors.green,
        ),
      );
      _loadOrders(); // 重新加载订单
    }
  }

  void _requestRefund(Order order) async {
    if (order.paymentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('该订单未支付，无法退款')),
      );
      return;
    }

    bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('申请退款'),
          content: Text('确定要为订单 ${order.id} 申请退款吗？退款金额将原路返回。'),
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
        final result = await PaymentService.refundPayment(
          paymentId: order.paymentId!,
          amount: order.price ?? 0,
        );
        
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('退款申请已提交'),
              backgroundColor: Colors.green,
            ),
          );
          _loadOrders(); // 重新加载订单
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('退款申请失败: ${result.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('退款申请出现错误: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

  void _navigateToNotifications() {
    if (_currentUser != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NotificationScreen(currentUser: _currentUser!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('农户工作台'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          // 通知按钮
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: _navigateToNotifications,
            tooltip: '消息通知',
          ),
          
          // 发布订单
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _publishOrder,
            tooltip: '发布订单',
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
          ? _buildOrderListScreen()
          : _buildMapScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '我的订单',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: '订单地图',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
        ? FloatingActionButton(
            onPressed: _publishOrder,
            child: Icon(Icons.add),
            tooltip: '发布订单',
          )
        : null,
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
                  _showOrderDialog(order);
                },
              ),
            );
          }).toList(),
        ),
      ],
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
          child: ListTile(
            title: Text('${order.cropType} - ${order.area}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('订单号: ${order.id}'),
                Text('位置: ${order.location.latitude.toStringAsFixed(4)}, ${order.location.longitude.toStringAsFixed(4)}'),
                if (order.description != null && order.description!.isNotEmpty)
                  Text('描述: ${order.description}'),
                Text('价格: ${order.formatPrice()}'),
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
          onPressed: () => _showSmartDispatchOption(order),
          child: Text('智能推荐'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        );
      case 'in_progress':
        return Text('进行中', style: TextStyle(color: Colors.orange));
      case 'completed':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (order.paymentId == null)
              ElevatedButton(
                onPressed: () => _makePayment(order),
                child: Text('支付'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              )
            else if (order.isReviewed != true)
              ElevatedButton(
                onPressed: () => _leaveReview(order),
                child: Text('评价'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              )
            else
              Text('已完成'),
          ],
        );
      default:
        return Container();
    }
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
                SizedBox(height: 8),
                Text('价格: ${order.formatPrice()}'),
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
                if (order.paymentId != null) ...[
                  SizedBox(height: 8),
                  Text('支付状态: 已支付'),
                ],
                if (order.isReviewed == true) ...[
                  SizedBox(height: 8),
                  Text('评价状态: 已评价'),
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
            if (order.status == 'pending') ...[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showSmartDispatchOption(order);
                },
                child: Text('智能推荐'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
            if (order.status == 'completed') ...[
              if (order.paymentId == null)
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _makePayment(order);
                  },
                  child: Text('支付'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                )
              else if (order.isReviewed != true)
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _leaveReview(order);
                  },
                  child: Text('评价'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                )
              else if (order.paymentId != null)
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _requestRefund(order);
                  },
                  child: Text('申请退款'),
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
}