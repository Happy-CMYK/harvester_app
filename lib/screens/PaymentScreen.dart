import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/payment_service.dart';

class PaymentScreen extends StatefulWidget {
  final Order order;
  final double amount;

  const PaymentScreen({
    Key? key,
    required this.order,
    required this.amount,
  }) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = PaymentService.WECHAT_PAY;
  bool _isProcessing = false;
  String _paymentMessage = '';

  void _processPayment() async {
    setState(() {
      _isProcessing = true;
      _paymentMessage = '正在处理支付...';
    });

    try {
      // 调用支付服务
      final result = await PaymentService.initiatePayment(
        orderId: widget.order.id,
        amount: widget.amount,
        paymentMethod: _selectedPaymentMethod,
      );

      setState(() {
        _isProcessing = false;
        _paymentMessage = result.message;
      });

      if (result.success) {
        // 显示成功消息并返回结果
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('支付成功！'),
            backgroundColor: Colors.green,
          ),
        );
        
        // 延迟返回结果
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context, result);
        });
      } else {
        // 显示失败消息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('支付失败：${result.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _paymentMessage = '支付出现错误';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('支付出现错误：$e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('支付订单'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 订单信息
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '订单信息',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('订单号: ${widget.order.id}'),
                    SizedBox(height: 5),
                    Text('农户: ${widget.order.farmerName}'),
                    SizedBox(height: 5),
                    Text('作物: ${widget.order.cropType}'),
                    SizedBox(height: 5),
                    Text('面积: ${widget.order.area}'),
                    SizedBox(height: 10),
                    Divider(),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '支付金额:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '¥${widget.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            
            // 支付方式选择
            Text(
              '选择支付方式',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            
            // 微信支付
            Card(
              elevation: 2,
              child: ListTile(
                leading: Icon(
                  Icons.wechat,
                  color: Colors.green,
                ),
                title: Text('微信支付'),
                trailing: Radio<String>(
                  value: PaymentService.WECHAT_PAY,
                  groupValue: _selectedPaymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentMethod = value!;
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    _selectedPaymentMethod = PaymentService.WECHAT_PAY;
                  });
                },
              ),
            ),
            
            // 支付宝支付
            Card(
              elevation: 2,
              child: ListTile(
                leading: Icon(
                  Icons.account_balance_wallet,
                  color: Colors.blue,
                ),
                title: Text('支付宝'),
                trailing: Radio<String>(
                  value: PaymentService.ALIPAY,
                  groupValue: _selectedPaymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentMethod = value!;
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    _selectedPaymentMethod = PaymentService.ALIPAY;
                  });
                },
              ),
            ),
            
            // 到付
            Card(
              elevation: 2,
              child: ListTile(
                leading: Icon(
                  Icons.money,
                  color: Colors.orange,
                ),
                title: Text('到付'),
                subtitle: Text('作业完成后现金支付'),
                trailing: Radio<String>(
                  value: PaymentService.CASH_ON_DELIVERY,
                  groupValue: _selectedPaymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentMethod = value!;
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    _selectedPaymentMethod = PaymentService.CASH_ON_DELIVERY;
                  });
                },
              ),
            ),
            
            SizedBox(height: 30),
            
            // 支付按钮
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isProcessing
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          '处理中...',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      '确认支付 ¥${widget.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // 支付状态消息
            if (_paymentMessage.isNotEmpty)
              Center(
                child: Text(
                  _paymentMessage,
                  style: TextStyle(
                    color: _paymentMessage.contains('成功') ? Colors.green : Colors.red,
                    fontSize: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}