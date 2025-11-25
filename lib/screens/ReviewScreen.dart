import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import '../models/review_model.dart';

class ReviewScreen extends StatefulWidget {
  final Order order;
  final User reviewer; // 评价者
  final User reviewee; // 被评价者

  const ReviewScreen({
    Key? key,
    required this.order,
    required this.reviewer,
    required this.reviewee,
  }) : super(key: key);

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  int _rating = 5;
  late String _comment;
  bool _isSubmitting = false;

  void _submitReview() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSubmitting = true;
      });

      try {
        // 创建评价对象
        final review = Review(
          id: 'review_${DateTime.now().millisecondsSinceEpoch}',
          orderId: widget.order.id,
          reviewerId: widget.reviewer.id,
          revieweeId: widget.reviewee.id,
          rating: _rating,
          comment: _comment,
          createdAt: DateTime.now(),
        );

        // 提交评价
        bool success = await ReviewService.submitReview(review);

        setState(() {
          _isSubmitting = false;
        });

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('评价提交成功！'),
              backgroundColor: Colors.green,
            ),
          );
          
          // 返回结果
          Future.delayed(Duration(seconds: 1), () {
            Navigator.pop(context, true);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('评价提交失败，请重试'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isSubmitting = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('提交评价时出现错误：$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('评价订单'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
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
                      SizedBox(height: 5),
                      Text('服务提供者: ${widget.reviewee.username}'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              
              // 评分选择
              Text(
                '评分',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < _rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 40,
                          ),
                          onPressed: () {
                            setState(() {
                              _rating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                    Text(
                      _getRatingText(_rating),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              
              // 评价内容
              Text(
                '评价内容',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: '请描述您的服务体验...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入评价内容';
                  }
                  if (value.length < 10) {
                    return '评价内容至少10个字';
                  }
                  return null;
                },
                onSaved: (value) {
                  _comment = value!;
                },
              ),
              SizedBox(height: 30),
              
              // 提交按钮
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReview,
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
                            '提交中...',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        '提交评价',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1: return '很差';
      case 2: return '较差';
      case 3: return '一般';
      case 4: return '良好';
      case 5: return '优秀';
      default: return '';
    }
  }
}