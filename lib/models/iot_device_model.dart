class IoTDevice {
  final String id;
  final String name;
  final String type; // 设备类型，例如 'gps_tracker', 'fuel_sensor'
  final String operatorId; // 关联的农机手ID
  final bool isActive;
  final DateTime registeredAt;

  IoTDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.operatorId,
    this.isActive = true,
    required this.registeredAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'operatorId': operatorId,
      'isActive': isActive,
      'registeredAt': registeredAt.toIso8601String(),
    };
  }

  factory IoTDevice.fromJson(Map<String, dynamic> json) {
    return IoTDevice(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      operatorId: json['operatorId'],
      isActive: json['isActive'] ?? true,
      registeredAt: DateTime.parse(json['registeredAt']),
    );
  }
}

class IoTDeviceData {
  final String deviceId;
  final String orderId;
  final double latitude;
  final double longitude;
  final double speed; // km/h
  final double fuelLevel; // %
  final double workArea; // 已作业面积 (亩)
  final DateTime timestamp;

  IoTDeviceData({
    required this.deviceId,
    required this.orderId,
    required this.latitude,
    required this.longitude,
    this.speed = 0.0,
    this.fuelLevel = 100.0,
    this.workArea = 0.0,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'orderId': orderId,
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed,
      'fuelLevel': fuelLevel,
      'workArea': workArea,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory IoTDeviceData.fromJson(Map<String, dynamic> json) {
    return IoTDeviceData(
      deviceId: json['deviceId'],
      orderId: json['orderId'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      speed: json['speed'] ?? 0.0,
      fuelLevel: json['fuelLevel'] ?? 100.0,
      workArea: json['workArea'] ?? 0.0,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class IoTDeviceService {
  static final List<IoTDevice> _devices = [];
  static final List<IoTDeviceData> _deviceData = [];
  
  /// 注册新设备
  static Future<bool> registerDevice(IoTDevice device) async {
    await Future.delayed(Duration(milliseconds: 200));
    _devices.add(device);
    print('📡 注册新设备: ${device.name} (${device.id})');
    return true;
  }
  
  /// 上报设备数据
  static Future<bool> reportDeviceData(IoTDeviceData data) async {
    await Future.delayed(Duration(milliseconds: 100));
    _deviceData.add(data);
    print('📊 设备数据上报: ${data.deviceId} at ${data.timestamp}');
    return true;
  }
  
  /// 获取设备最新数据
  static IoTDeviceData? getLatestData(String deviceId) {
    final deviceData = _deviceData
        .where((data) => data.deviceId == deviceId)
        .toList();
    
    if (deviceData.isEmpty) return null;
    
    deviceData.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return deviceData.first;
  }
  
  /// 获取订单的所有设备数据
  static List<IoTDeviceData> getOrderDeviceData(String orderId) {
    return _deviceData
        .where((data) => data.orderId == orderId)
        .toList();
  }
  
  /// 获取农机手的所有设备
  static List<IoTDevice> getOperatorDevices(String operatorId) {
    return _devices
        .where((device) => device.operatorId == operatorId)
        .toList();
  }
}