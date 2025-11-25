import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'order_model.dart';
import 'user_model.dart';

class OrderService {
  static const String _ordersKey = 'orders';

  /// 发布新订单
  static Future<bool> publishOrder({
    required String farmerName,
    required LatLng location,
    required String cropType,
    required String area,
    required String description,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getStringList(_ordersKey) ?? [];
      
      // 生成新订单ID
      final orderId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // 创建新订单
      final newOrder = Order(
        id: orderId,
        farmerName: farmerName,
        location: location,
        cropType: cropType,
        area: area,
        status: 'pending', // 初始状态为待接单
      );
      
      // 将订单转换为JSON并添加到列表
      ordersJson.add(newOrder.toJson().toString());
      
      // 保存到本地存储
      await prefs.setStringList(_ordersKey, ordersJson);
      
      print('📦 订单已发布: ${newOrder.id}');
      return true;
    } catch (e) {
      print('❌ 发布订单失败: $e');
      return false;
    }
  }

  /// 获取所有订单
  static Future<List<Order>> getAllOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson = prefs.getStringList('orders') ?? [];
    
    List<Order> orders = [];
    for (var orderJson in ordersJson) {
      try {
        // 简化的JSON解析
        Map<String, dynamic> data = {};
        RegExp regExp = RegExp(r'"([^"]+)"\s*:\s*"([^"]*)"');
        Iterable<RegExpMatch> matches = regExp.allMatches(orderJson);
        for (var match in matches) {
          data[match.group(1)!] = match.group(2);
        }
        
        orders.add(Order.fromJson(data));
      } catch (e) {
        print('📦 解析订单失败: $e');
      }
    }
    
    return orders;
  }
  
  static Future<List<Order>> getFarmerOrders(String farmerId) async {
    // 在实际应用中，我们会根据农户ID过滤订单
    // 目前我们返回所有订单作为示例
    return await getAllOrders();
  }
  
  static Future<List<Order>> getOperatorOrders(String operatorId) async {
    // 在实际应用中，我们会根据农机手ID过滤订单
    // 目前我们返回所有订单作为示例
    return await getAllOrders();
  }
  
  static Future<bool> createOrder(Order order) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getStringList('orders') ?? [];
      
      // 添加新订单
      ordersJson.add(order.toJson().toString());
      
      // 保存到SharedPreferences
      await prefs.setStringList('orders', ordersJson);
      
      print('📦 订单创建成功: ${order.id}');
      return true;
    } catch (e) {
      print('📦 订单创建失败: $e');
      return false;
    }
  }
  
  static Future<bool> acceptOrder(String orderId, User operator) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getStringList('orders') ?? [];
      
      // 查找并更新订单
      for (int i = 0; i < ordersJson.length; i++) {
        // 简化的JSON解析
        Map<String, dynamic> data = {};
        RegExp regExp = RegExp(r'"([^"]+)"\s*:\s*"([^"]*)"');
        Iterable<RegExpMatch> matches = regExp.allMatches(ordersJson[i]);
        for (var match in matches) {
          data[match.group(1)!] = match.group(2);
        }
        
        if (data['id'] == orderId) {
          // 更新订单状态和分配信息
          data['status'] = 'in_progress';
          data['assignedTo'] = operator.username;
          data['startTime'] = DateTime.now().toString();
          
          // 更新订单
          ordersJson[i] = data.toString(); // 简化的转换
          break;
        }
      }
      
      // 保存更新后的订单列表
      await prefs.setStringList('orders', ordersJson);
      
      print('📦 订单接受成功: $orderId');
      return true;
    } catch (e) {
      print('📦 订单接受失败: $e');
      return false;
    }
  }
  
  static Future<bool> completeOrder(String orderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getStringList('orders') ?? [];
      
      // 查找并更新订单
      for (int i = 0; i < ordersJson.length; i++) {
        // 简化的JSON解析
        Map<String, dynamic> data = {};
        RegExp regExp = RegExp(r'"([^"]+)"\s*:\s*"([^"]*)"');
        Iterable<RegExpMatch> matches = regExp.allMatches(ordersJson[i]);
        for (var match in matches) {
          data[match.group(1)!] = match.group(2);
        }
        
        if (data['id'] == orderId) {
          // 更新订单状态
          data['status'] = 'completed';
          data['endTime'] = DateTime.now().toString();
          
          // 更新订单
          ordersJson[i] = data.toString(); // 简化的转换
          break;
        }
      }
      
      // 保存更新后的订单列表
      await prefs.setStringList('orders', ordersJson);
      
      print('📦 订单完成: $orderId');
      return true;
    } catch (e) {
      print('📦 订单完成失败: $e');
      return false;
    }
  }
  
  static Future<bool> cancelOrder(String orderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getStringList('orders') ?? [];
      
      // 查找并更新订单
      for (int i = 0; i < ordersJson.length; i++) {
        // 简化的JSON解析
        Map<String, dynamic> data = {};
        RegExp regExp = RegExp(r'"([^"]+)"\s*:\s*"([^"]*)"');
        Iterable<RegExpMatch> matches = regExp.allMatches(ordersJson[i]);
        for (var match in matches) {
          data[match.group(1)!] = match.group(2);
        }
        
        if (data['id'] == orderId) {
          // 更新订单状态
          data['status'] = 'cancelled';
          
          // 更新订单
          ordersJson[i] = data.toString(); // 简化的转换
          break;
        }
      }
      
      // 保存更新后的订单列表
      await prefs.setStringList('orders', ordersJson);
      
      print('📦 订单取消: $orderId');
      return true;
    } catch (e) {
      print('📦 订单取消失败: $e');
      return false;
    }
  }
  
  /// 分配订单给农机手（用于农机手端）
  static Future<bool> assignOrder(String orderId, User operator) async {
    return await acceptOrder(orderId, operator);
  }
}