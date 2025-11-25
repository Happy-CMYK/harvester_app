import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import '../models/scheduling_service.dart';

class SmartDispatchScreen extends StatefulWidget {
  final Order order;
  final List<User> availableOperators;

  const SmartDispatchScreen({
    Key? key,
    required this.order,
    required this.availableOperators,
  }) : super(key: key);

  @override
  _SmartDispatchScreenState createState() => _SmartDispatchScreenState();
}

class _SmartDispatchScreenState extends State<SmartDispatchScreen> {
  late Order _order;
  late List<User> _availableOperators;
  List<User> _recommendedOperators = [];
  User? _selectedOperator;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _availableOperators = widget.availableOperators;
    _findRecommendedOperators();
  }

  void _findRecommendedOperators() {
    setState(() {
      _isProcessing = true;
    });

    // 模拟计算时间
    Future.delayed(Duration(seconds: 1), () {
      final recommendedOperators = SchedulingService.recommendOperators(
        _order,
        _availableOperators,
        limit: 10,
      );
      
      setState(() {
        _recommendedOperators = recommendedOperators;
        if (_recommendedOperators.isNotEmpty) {
          _selectedOperator = _recommendedOperators[0]; // 默认选择第一个
        }
        _isProcessing = false;
      });
    });
  }

  void _assignOrder() {
    if (_selectedOperator != null) {
      Navigator.pop(context, _selectedOperator);
    }
  }

  void _refreshRecommendations() {
    _findRecommendedOperators();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('智能推荐农机手'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshRecommendations,
            tooltip: '重新推荐',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 订单信息
            Card(
              elevation: 2,
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
                    Text('订单号: ${_order.id}'),
                    Text('农户: ${_order.farmerName}'),
                    Text('作物类型: ${_order.cropType}'),
                    Text('作业面积: ${_order.area}'),
                    if (_order.description != null && _order.description!.isNotEmpty)
                      Text('描述: ${_order.description}'),
                    Text(
                      '位置: ${_order.location.latitude.toStringAsFixed(4)}, '
                      '${_order.location.longitude.toStringAsFixed(4)}',
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            
            // 推荐农机手标题
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '推荐农机手',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!_isProcessing && _recommendedOperators.isNotEmpty)
                  Text(
                    '共${_recommendedOperators.length}位',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
            SizedBox(height: 10),
            
            // 处理状态或推荐结果
            _isProcessing
              ? Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text('正在智能推荐最佳农机手...'),
                    ],
                  ),
                )
              : _recommendedOperators.isEmpty
                ? Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.error,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 10),
                        Text('未找到合适的农机手'),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _refreshRecommendations,
                          child: Text('重新推荐'),
                        ),
                      ],
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: _recommendedOperators.length,
                      itemBuilder: (context, index) {
                        final operator = _recommendedOperators[index];
                        final bool isSelected = _selectedOperator?.id == operator.id;
                        
                        return Card(
                          elevation: isSelected ? 4 : 1,
                          color: isSelected ? Colors.green[50] : Colors.white,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isSelected ? Colors.green : Colors.orange,
                              child: Icon(
                                Icons.agriculture,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              operator.realName ?? operator.username,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (operator.machines != null && operator.machines!.isNotEmpty)
                                  Text('${operator.machines!.length} 台农机'),
                                // 使用虚拟号码保护隐私
                                if (operator.virtualPhone != null)
                                  Text(
                                    '联系电话: ${operator.virtualPhone}',
                                    style: TextStyle(color: Colors.green),
                                  )
                                else if (operator.phone != null)
                                  Text(
                                    '联系电话: ${operator.phone}',
                                    style: TextStyle(color: Colors.green),
                                  ),
                              ],
                            ),
                            trailing: isSelected
                              ? Icon(Icons.check, color: Colors.green)
                              : null,
                            onTap: () {
                              setState(() {
                                _selectedOperator = operator;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _selectedOperator != null && !_isProcessing ? _assignOrder : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              _selectedOperator != null 
                ? '确认派单给 ${_selectedOperator!.realName ?? _selectedOperator!.username}' 
                : '请选择农机手',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}