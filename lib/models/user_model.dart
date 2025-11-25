class User {
  final String id;
  final String username;
  final String email;
  final String? phone; // 真实手机号
  final String? virtualPhone; // 虚拟号码
  final String? password;
  final String? realName;
  final String? idCard;
  final bool isVerified;
  final String? role;
  final List<Machine>? machines;
  final List<AvailabilitySlot>? availability; // 添加可预约时间字段

  User({
    required this.id,
    required this.username,
    required this.email,
    this.phone, // 真实手机号
    this.virtualPhone, // 虚拟号码
    this.password,
    this.realName,
    this.idCard,
    this.isVerified = false,
    this.role,
    this.machines,
    this.availability, // 添加可预约时间字段
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone, // 真实手机号
      'virtualPhone': virtualPhone, // 虚拟号码
      'password': password,
      'realName': realName,
      'idCard': idCard,
      'isVerified': isVerified,
      'role': role,
      'machines': machines?.map((machine) => machine.toJson()).toList(),
      'availability': availability?.map((slot) => slot.toJson()).toList(), // 添加可预约时间字段
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    List<Machine>? machinesList;
    if (json['machines'] != null) {
      List<dynamic> machineJsonList = json['machines'] is List
          ? json['machines']
          : List<dynamic>.from(json['machines'].toString().split(','));
      machinesList = machineJsonList
          .map((machineJson) => Machine.fromJson(Map<String, dynamic>.from(machineJson)))
          .toList();
    }

    List<AvailabilitySlot>? availabilityList;
    if (json['availability'] != null) {
      List<dynamic> availabilityJsonList = json['availability'] is List
          ? json['availability']
          : List<dynamic>.from(json['availability'].toString().split(','));
      availabilityList = availabilityJsonList
          .map((slotJson) => AvailabilitySlot.fromJson(Map<String, dynamic>.from(slotJson)))
          .toList();
    }

    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      phone: json['phone'], // 真实手机号
      virtualPhone: json['virtualPhone'], // 虚拟号码
      password: json['password'],
      realName: json['realName'],
      idCard: json['idCard'],
      isVerified: json['isVerified'] == 'true' || json['isVerified'] == true,
      role: json['role'],
      machines: machinesList,
      availability: availabilityList, // 添加可预约时间字段
    );
  }
}

class Machine {
  final String id;
  final String name;
  final String type;
  final String description;
  final double hourlyRate;

  Machine({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.hourlyRate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'hourlyRate': hourlyRate,
    };
  }

  factory Machine.fromJson(Map<String, dynamic> json) {
    return Machine(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      description: json['description'],
      hourlyRate: double.parse(json['hourlyRate'].toString()),
    );
  }
}

// 添加可预约时间段模型
class AvailabilitySlot {
  final String id;
  final DateTime date;
  final String startTime; // 格式: "08:00"
  final String endTime;   // 格式: "18:00"
  final bool isAvailable;

  AvailabilitySlot({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'isAvailable': isAvailable,
    };
  }

  factory AvailabilitySlot.fromJson(Map<String, dynamic> json) {
    return AvailabilitySlot(
      id: json['id'],
      date: DateTime.parse(json['date']),
      startTime: json['startTime'],
      endTime: json['endTime'],
      isAvailable: json['isAvailable'] == 'true' || json['isAvailable'] == true,
    );
  }
}