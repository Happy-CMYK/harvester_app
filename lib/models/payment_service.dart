class PaymentService {
  // 模拟支付状态
  static const String PENDING = 'pending';
  static const String COMPLETED = 'completed';
  static const String FAILED = 'failed';
  static const String REFUNDED = 'refunded';

  // 模拟支付方式
  static const String WECHAT_PAY = 'wechat';
  static const String ALIPAY = 'alipay';
  static const String CASH_ON_DELIVERY = 'cash';

  /// 模拟发起支付
  static Future<PaymentResult> initiatePayment({
    required String orderId,
    required double amount,
    required String paymentMethod,
  }) async {
    // 模拟网络延迟
    await Future.delayed(Duration(seconds: 2));

    // 模拟支付结果 (80% 成功率)
    bool isSuccess = DateTime.now().millisecondsSinceEpoch % 10 < 8;
    
    if (isSuccess) {
      return PaymentResult(
        success: true,
        paymentId: 'pay_${DateTime.now().millisecondsSinceEpoch}',
        status: COMPLETED,
        message: '支付成功',
      );
    } else {
      return PaymentResult(
        success: false,
        paymentId: '',
        status: FAILED,
        message: '支付失败，请重试',
      );
    }
  }

  /// 模拟退款
  static Future<PaymentResult> refundPayment({
    required String paymentId,
    required double amount,
  }) async {
    // 模拟网络延迟
    await Future.delayed(Duration(seconds: 1));

    return PaymentResult(
      success: true,
      paymentId: paymentId,
      status: REFUNDED,
      message: '退款成功',
    );
  }
}

class PaymentResult {
  final bool success;
  final String paymentId;
  final String status;
  final String message;

  PaymentResult({
    required this.success,
    required this.paymentId,
    required this.status,
    required this.message,
  });
}

class PaymentInfo {
  final String id;
  final String orderId;
  final double amount;
  final String method;
  final String status;
  final DateTime createdAt;
  final DateTime? completedAt;

  PaymentInfo({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.method,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'amount': amount,
      'method': method,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      id: json['id'],
      orderId: json['orderId'],
      amount: json['amount'],
      method: json['method'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null 
        ? DateTime.parse(json['completedAt']) 
        : null,
    );
  }
}