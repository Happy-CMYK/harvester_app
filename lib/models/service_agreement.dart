class ServiceAgreement {
  final String id;
  final String orderId;
  final String farmerId;
  final String operatorId;
  final String content;
  final DateTime signedAt;
  final String farmerSignature;
  final String operatorSignature;
  final bool isCompleted;

  ServiceAgreement({
    required this.id,
    required this.orderId,
    required this.farmerId,
    required this.operatorId,
    required this.content,
    required this.signedAt,
    required this.farmerSignature,
    required this.operatorSignature,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'farmerId': farmerId,
      'operatorId': operatorId,
      'content': content,
      'signedAt': signedAt.toIso8601String(),
      'farmerSignature': farmerSignature,
      'operatorSignature': operatorSignature,
      'isCompleted': isCompleted,
    };
  }

  factory ServiceAgreement.fromJson(Map<String, dynamic> json) {
    return ServiceAgreement(
      id: json['id'],
      orderId: json['orderId'],
      farmerId: json['farmerId'],
      operatorId: json['operatorId'],
      content: json['content'],
      signedAt: DateTime.parse(json['signedAt']),
      farmerSignature: json['farmerSignature'],
      operatorSignature: json['operatorSignature'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

class AgreementTemplate {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final bool isActive;

  AgreementTemplate({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory AgreementTemplate.fromJson(Map<String, dynamic> json) {
    return AgreementTemplate(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      isActive: json['isActive'] ?? true,
    );
  }
}

class AgreementService {
  static final List<ServiceAgreement> _agreements = [];
  static final List<AgreementTemplate> _templates = [
    AgreementTemplate(
      id: 'template_1',
      title: '标准收割服务协议',
      content: '''
本协议由以下双方签署：

农户（需求方）：[农户姓名]
农机手（服务方）：[农机手姓名]

1. 服务内容
农机手同意为农户提供农作物收割服务，作业面积约为[面积]亩，作物类型为[作物类型]。

2. 服务费用
总费用为人民币[金额]元，支付方式为[支付方式]。

3. 作业时间
预计作业时间为[日期]，具体时间由双方协商确定。

4. 质量标准
农机手应按照农业作业标准完成收割任务，确保作业质量。

5. 责任与义务
- 农户应提供准确的作业地点和相关信息
- 农机手应按时到达作业地点并完成作业
- 任何一方违约应承担相应责任

6. 争议解决
如发生争议，双方应友好协商解决；协商不成的，可提交当地仲裁机构仲裁。

签署栏：

农户签名：_________________    日期：_______
农机手签名：_________________    日期：_______
      ''',
      createdAt: DateTime.now(),
      isActive: true,
    )
  ];
  
  /// 创建服务协议
  static Future<ServiceAgreement> createAgreement({
    required String orderId,
    required String farmerId,
    required String operatorId,
  }) async {
    await Future.delayed(Duration(milliseconds: 300));
    
    final template = _templates.firstWhere(
      (t) => t.isActive, 
      orElse: () => _templates.first
    );
    
    final agreement = ServiceAgreement(
      id: 'agreement_${DateTime.now().millisecondsSinceEpoch}',
      orderId: orderId,
      farmerId: farmerId,
      operatorId: operatorId,
      content: template.content,
      signedAt: DateTime.now(),
      farmerSignature: '',
      operatorSignature: '',
    );
    
    _agreements.add(agreement);
    print('📋 创建服务协议: $orderId');
    return agreement;
  }
  
  /// 签署协议
  static Future<bool> signAgreement({
    required String agreementId,
    required String userId,
    required String signature,
    required bool isFarmer,
  }) async {
    await Future.delayed(Duration(milliseconds: 200));
    
    final index = _agreements.indexWhere((a) => a.id == agreementId);
    if (index == -1) return false;
    
    final agreement = _agreements[index];
    
    final updatedAgreement = ServiceAgreement(
      id: agreement.id,
      orderId: agreement.orderId,
      farmerId: agreement.farmerId,
      operatorId: agreement.operatorId,
      content: agreement.content,
      signedAt: agreement.signedAt,
      farmerSignature: isFarmer ? signature : agreement.farmerSignature,
      operatorSignature: isFarmer ? agreement.operatorSignature : signature,
      isCompleted: isFarmer 
        ? agreement.operatorSignature.isNotEmpty 
        : agreement.farmerSignature.isNotEmpty,
    );
    
    _agreements[index] = updatedAgreement;
    print('✍️ 协议签署: $agreementId by $userId');
    return true;
  }
  
  /// 获取订单协议
  static ServiceAgreement? getAgreementByOrder(String orderId) {
    try {
      return _agreements.firstWhere((a) => a.orderId == orderId);
    } catch (e) {
      return null;
    }
  }
  
  /// 获取用户相关协议
  static List<ServiceAgreement> getUserAgreements(String userId) {
    return _agreements.where(
      (a) => a.farmerId == userId || a.operatorId == userId
    ).toList();
  }
}