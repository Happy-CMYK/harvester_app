import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/order_service.dart';

class PublishOrderScreen extends StatefulWidget {
  const PublishOrderScreen({Key? key}) : super(key: key);

  @override
  _PublishOrderScreenState createState() => _PublishOrderScreenState();
}

class _PublishOrderScreenState extends State<PublishOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _farmerNameController = TextEditingController();
  final _cropTypeController = TextEditingController();
  final _areaController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  double _latitude = 39.91;
  double _longitude = 116.395;

  void _submitOrder() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      bool success = await OrderService.publishOrder(
        farmerName: _farmerNameController.text,
        location: LatLng(_latitude, _longitude),
        cropType: _cropTypeController.text,
        area: _areaController.text,
        description: _descriptionController.text,
      );
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('订单发布成功')),
        );
        
        // 清空表单
        _farmerNameController.clear();
        _cropTypeController.clear();
        _areaController.clear();
        _descriptionController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('订单发布失败')),
        );
      }
    }
  }

  @override
  void dispose() {
    _farmerNameController.dispose();
    _cropTypeController.dispose();
    _areaController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('发布订单'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                '订单信息',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              
              // 农户姓名
              TextFormField(
                controller: _farmerNameController,
                decoration: InputDecoration(
                  labelText: '农户姓名',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入农户姓名';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              
              // 作物类型
              TextFormField(
                controller: _cropTypeController,
                decoration: InputDecoration(
                  labelText: '作物类型',
                  prefixIcon: Icon(Icons.eco),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入作物类型';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              
              // 面积
              TextFormField(
                controller: _areaController,
                decoration: InputDecoration(
                  labelText: '面积',
                  prefixIcon: Icon(Icons.square_foot),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入面积';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              
              // 位置坐标
              Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '位置信息',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text('纬度: $_latitude'),
                      Slider(
                        value: _latitude,
                        min: 39.8,
                        max: 40.0,
                        divisions: 200,
                        label: _latitude.toStringAsFixed(4),
                        onChanged: (value) {
                          setState(() {
                            _latitude = value;
                          });
                        },
                      ),
                      Text('经度: $_longitude'),
                      Slider(
                        value: _longitude,
                        min: 116.2,
                        max: 116.6,
                        divisions: 200,
                        label: _longitude.toStringAsFixed(4),
                        onChanged: (value) {
                          setState(() {
                            _longitude = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              
              // 描述
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: '描述',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 30),
              
              // 发布按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitOrder,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(15.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    backgroundColor: Colors.green,
                  ),
                  child: Text(
                    '发布订单',
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
}