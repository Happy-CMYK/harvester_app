import 'dart:math';
import 'package:latlong2/latlong.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';

class SchedulingService {
  /// 使用Haversine公式计算两点间的距离（单位：公里）
  static double calculateDistance(LatLng point1, LatLng point2) {
    const R = 6371; // 地球半径（公里）
    
    final dLat = _degreesToRadians(point2.latitude - point1.latitude);
    final dLon = _degreesToRadians(point2.longitude - point1.longitude);
    
    final lat1 = _degreesToRadians(point1.latitude);
    final lat2 = _degreesToRadians(point2.latitude);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
              sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return R * c;
  }
  
  /// 角度转弧度
  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }
  
  /// 为订单寻找最佳农机手列表
  /// 考虑因素：距离(70%)、农机类型匹配度(30%)
  static List<User> findBestOperators(Order order, List<User> operators) {
    if (operators.isEmpty) return [];
    
    // 创建一个包含农机手和评分的列表
    List<Map<String, dynamic>> operatorScores = [];
    
    for (var operator in operators) {
      // 计算距离分数（距离越近得分越低，越好）
      final distance = calculateDistance(order.location, LatLng(39.91, 116.395));
      final distanceScore = distance;
      
      // 计算农机类型匹配分数（匹配得0分，不匹配得10分）
      double typeScore = 10.0;
      if (operator.machines != null && operator.machines!.isNotEmpty) {
        for (var machine in operator.machines!) {
          if (machine.type.contains(order.cropType) || 
              order.cropType.contains(machine.type)) {
            typeScore = 0.0;
            break;
          }
        }
      }
      
      // 计算综合得分（可以根据业务需求调整权重）
      // 距离权重70%，类型匹配权重30%
      final totalScore = distanceScore * 0.7 + typeScore * 0.3;
      
      operatorScores.add({
        'operator': operator,
        'score': totalScore,
      });
    }
    
    // 按评分排序，评分越低越好
    operatorScores.sort((a, b) => a['score'].compareTo(b['score']));
    
    // 返回排序后的农机手列表
    return operatorScores.map((item) => item['operator'] as User).toList();
  }
  
  /// 为订单推荐前N个最佳农机手
  static List<User> recommendOperators(Order order, List<User> operators, {int limit = 5}) {
    List<User> bestOperators = findBestOperators(order, operators);
    return bestOperators.take(limit).toList();
  }
}
