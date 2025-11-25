import 'package:flutter/material.dart';
import '../models/service_agreement.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';

class AgreementScreen extends StatefulWidget {
  final ServiceAgreement agreement;
  final Order order;
  final User currentUser;

  const AgreementScreen({
    Key? key,
    required this.agreement,
    required this.order,
    required this.currentUser,
  }) : super(key: key);

  @override
  _AgreementScreenState createState() => _AgreementScreenState();
}

class _AgreementScreenState extends State<AgreementScreen> {
  bool _farmerSigned = false;
  bool _operatorSigned = false;
  bool _isSubmitting = false;
  final TextEditingController _signatureController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _farmerSigned = widget.agreement.farmerSignature.isNotEmpty;
    _operatorSigned = widget.agreement.operatorSignature.isNotEmpty;
  }

  void _signAgreement() async {
    if (_signatureController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请输入签名')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    bool isFarmer = widget.currentUser.id == widget.agreement.farmerId;
    
    try {
      bool success = await AgreementService.signAgreement(
        agreementId: widget.agreement.id,
        userId: widget.currentUser.id,
        signature: _signatureController.text,
        isFarmer: isFarmer,
      );

      setState(() {
        _isSubmitting = false;
      });

      if (success) {
        setState(() {
          if (isFarmer) {
            _farmerSigned = true;
          } else {
            _operatorSigned = true;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('签署成功')),
        );

        // 如果双方都已签署，返回结果
        if ((_farmerSigned && widget.currentUser.id == widget.agreement.farmerId) ||
            (_operatorSigned && widget.currentUser.id == widget.agreement.operatorId)) {
          Future.delayed(Duration(seconds: 1), () {
            Navigator.pop(context, true);
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('签署失败，请重试')),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('签署过程中出现错误: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isFarmer = widget.currentUser.id == widget.agreement.farmerId;
    bool isOperator = widget.currentUser.id == widget.agreement.operatorId;
    bool canSign = (isFarmer && !_farmerSigned) || (isOperator && !_operatorSigned);

    return Scaffold(
      appBar: AppBar(
        title: Text('服务协议'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 协议标题
            Text(
              '收割服务协议',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '订单号: ${widget.order.id}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 20),
            
            // 协议内容
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  widget.agreement.content,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 20),
            
            // 签署状态
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '签署状态',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          _farmerSigned ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: _farmerSigned ? Colors.green : Colors.grey,
                        ),
                        SizedBox(width: 10),
                        Text('农户已签署'),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          _operatorSigned ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: _operatorSigned ? Colors.green : Colors.grey,
                        ),
                        SizedBox(width: 10),
                        Text('农机手已签署'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            
            // 签名区域
            if (canSign)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isFarmer ? '农户签名' : '农机手签名',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _signatureController,
                    decoration: InputDecoration(
                      hintText: '请输入您的姓名作为电子签名',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _signAgreement,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isSubmitting
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
                                '签署中...',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            '确认签署',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                    ),
                  ),
                ],
              ),
            
            // 已签署提示
            if (!canSign)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 60,
                    ),
                    SizedBox(height: 10),
                    Text(
                      isFarmer && _farmerSigned
                        ? '您已签署此协议'
                        : isOperator && _operatorSigned
                          ? '您已签署此协议'
                          : '对方已签署，等待另一方签署',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}