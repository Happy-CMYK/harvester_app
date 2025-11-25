import 'package:latlong2/latlong.dart';

class Order {
  final String id;
  final String farmerName;
  final LatLng location;
  final String cropType;
  final String area;
  final String status;
  final String? description;
  final String? assignedTo;
  final String? startTime;
  final String? endTime;
  final double? price;
  final String? paymentId; // 支付ID
  final bool? isReviewed; // 是否已评价

  Order({
    required this.id,
    required this.farmerName,
    required this.location,
    required this.cropType,
    required this.area,
    required this.status,
    this.description,
    this.assignedTo,
    this.startTime,
    this.endTime,
    this.price,
    this.paymentId,
    this.isReviewed,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerName': farmerName,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'cropType': cropType,
      'area': area,
      'status': status,
      'description': description,
      'assignedTo': assignedTo,
      'startTime': startTime,
      'endTime': endTime,
      'price': price,
      'paymentId': paymentId,
      'isReviewed': isReviewed,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      farmerName: json['farmerName'],
      location: LatLng(
        double.parse(json['latitude'].toString()), 
        double.parse(json['longitude'].toString()),
      ),
      cropType: json['cropType'],
      area: json['area'],
      status: json['status'],
      description: json['description'],
      assignedTo: json['assignedTo'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      price: json['price'] != null ? double.parse(json['price'].toString()) : null,
      paymentId: json['paymentId'],
      isReviewed: json['isReviewed'] == 'true' || json['isReviewed'] == true,
    );
  }
  
  // 添加一个帮助方法来安全地格式化价格
  String formatPrice() {
    if (price == null) {
      return '未定价';
    }
    return '¥${price!.toStringAsFixed(2)}';
  }
}