import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/iot_device_model.dart';
import '../models/user_model.dart';

class IoTDeviceScreen extends StatefulWidget {
  final User currentUser;

  const IoTDeviceScreen({Key? key, required this.currentUser}) : super(key: key);

  @override
  _IoTDeviceScreenState createState() => _IoTDeviceScreenState();
}

class _IoTDeviceScreenState extends State<IoTDeviceScreen> {
  final MapController _mapController = MapController();
  late List<IoTDevice> _devices;
  late List<IoTDeviceData> _deviceData;
  IoTDeviceData? _latestData;
  bool _isLoading = false;
  String? _selectedDeviceId;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  void _loadDevices() {
    setState(() {
      _isLoading = true;
    });

    // 模拟网络延迟
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _devices = IoTDeviceService.getOperatorDevices(widget.currentUser.id);
        if (_devices.isNotEmpty) {
          _selectedDeviceId = _devices.first.id;
          _loadDeviceData(_selectedDeviceId!);
        }
        _isLoading = false;
      });
    });
  }

  void _loadDeviceData(String deviceId) {
    setState(() {
      _isLoading = true;
    });

    // 模拟网络延迟
    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        _deviceData = []; // 在实际应用中，这里会从服务获取数据
        _latestData = IoTDeviceService.getLatestData(deviceId);
        _isLoading = false;
      });
    });
  }

  void _onDeviceSelected(String deviceId) {
    setState(() {
      _selectedDeviceId = deviceId;
    });
    _loadDeviceData(deviceId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设备监控'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
        ? Center(child: CircularProgressIndicator())
        : Column(
            children: [
              // 设备选择
              if (_devices.isNotEmpty)
                Container(
                  height: 60,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _devices.length,
                    itemBuilder: (context, index) {
                      final device = _devices[index];
                      return Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: ChoiceChip(
                          label: Text(device.name),
                          selected: _selectedDeviceId == device.id,
                          onSelected: (selected) {
                            if (selected) {
                              _onDeviceSelected(device.id);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              
              // 设备状态面板
              if (_selectedDeviceId != null)
                _buildDeviceStatusPanel(),
              
              // 地图视图
              if (_latestData != null)
                Expanded(
                  child: _buildMap(),
                )
              else
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.devices_other,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 20),
                        Text(
                          _devices.isEmpty 
                            ? '暂无设备' 
                            : '请选择设备查看实时位置',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
    );
  }

  Widget _buildDeviceStatusPanel() {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusItem(
                  icon: Icons.speed,
                  label: '速度',
                  value: '${_latestData?.speed ?? 0} km/h',
                  color: Colors.blue,
                ),
                _buildStatusItem(
                  icon: Icons.local_gas_station,
                  label: '燃油',
                  value: '${_latestData?.fuelLevel ?? 0}%',
                  color: Colors.orange,
                ),
                _buildStatusItem(
                  icon: Icons.square_foot,
                  label: '作业面积',
                  value: '${_latestData?.workArea ?? 0} 亩',
                  color: Colors.green,
                ),
              ],
            ),
            SizedBox(height: 10),
            if (_latestData != null)
              Text(
                '最后更新: ${_formatTime(_latestData!.timestamp)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        center: LatLng(_latestData!.latitude, _latestData!.longitude),
        zoom: 15.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.harvester_app',
        ),
        MarkerLayer(
          markers: [
            Marker(
              width: 80.0,
              height: 80.0,
              point: LatLng(_latestData!.latitude, _latestData!.longitude),
              child: Icon(
                Icons.agriculture,
                color: Colors.green,
                size: 40.0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}