import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class MachineManagementScreen extends StatefulWidget {
  final User currentUser;

  const MachineManagementScreen({Key? key, required this.currentUser}) : super(key: key);

  @override
  _MachineManagementScreenState createState() => _MachineManagementScreenState();
}

class _MachineManagementScreenState extends State<MachineManagementScreen> {
  late User _currentUser;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _typeController;
  late TextEditingController _descriptionController;
  late TextEditingController _hourlyRateController;
  bool _isEditing = false;
  int _editingIndex = -1;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.currentUser;
    
    // 确保machines字段不为null
    if (_currentUser.machines == null) {
      _currentUser = User(
        id: _currentUser.id,
        username: _currentUser.username,
        email: _currentUser.email,
        phone: _currentUser.phone,
        password: _currentUser.password,
        realName: _currentUser.realName,
        idCard: _currentUser.idCard,
        isVerified: _currentUser.isVerified,
        role: _currentUser.role,
        machines: [], // 初始化为空列表
      );
    }
    
    _nameController = TextEditingController();
    _typeController = TextEditingController();
    _descriptionController = TextEditingController();
    _hourlyRateController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _descriptionController.dispose();
    _hourlyRateController.dispose();
    super.dispose();
  }

  void _saveMachine() {
    if (_formKey.currentState!.validate()) {
      final machine = Machine(
        id: _isEditing 
            ? _currentUser.machines![_editingIndex].id 
            : DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        type: _typeController.text,
        description: _descriptionController.text,
        hourlyRate: double.parse(_hourlyRateController.text),
      );

      setState(() {
        if (_isEditing) {
          _currentUser.machines![_editingIndex] = machine;
        } else {
          _currentUser.machines!.add(machine);
        }
        _clearForm();
      });
      
      _saveUserData();
    }
  }

  void _editMachine(int index) {
    final machine = _currentUser.machines![index];
    _nameController.text = machine.name;
    _typeController.text = machine.type;
    _descriptionController.text = machine.description;
    _hourlyRateController.text = machine.hourlyRate.toString();
    
    setState(() {
      _isEditing = true;
      _editingIndex = index;
    });
  }

  void _deleteMachine(int index) {
    setState(() {
      _currentUser.machines!.removeAt(index);
    });
    _saveUserData();
  }

  void _clearForm() {
    _nameController.clear();
    _typeController.clear();
    _descriptionController.clear();
    _hourlyRateController.clear();
    
    setState(() {
      _isEditing = false;
      _editingIndex = -1;
    });
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data_${_currentUser.username}', _currentUser.toJson().toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('农机信息管理'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveUserData,
            tooltip: '保存',
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '添加/编辑农机',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: '农机名称',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入农机名称';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _typeController,
                    decoration: InputDecoration(
                      labelText: '农机类型',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入农机类型';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: '农机描述',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _hourlyRateController,
                    decoration: InputDecoration(
                      labelText: '每小时费用 (¥)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入每小时费用';
                      }
                      if (double.tryParse(value) == null) {
                        return '请输入有效的数字';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _saveMachine,
                        child: Text(_isEditing ? '更新农机' : '添加农机'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                      ),
                      SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: _clearForm,
                        child: Text('取消'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Text(
              '我的农机',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: _currentUser.machines == null || _currentUser.machines!.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.agriculture,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          '暂无农机信息',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '点击上方按钮添加您的农机',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _currentUser.machines!.length,
                    itemBuilder: (context, index) {
                      final machine = _currentUser.machines![index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange,
                            child: Icon(Icons.agriculture, color: Colors.white),
                          ),
                          title: Text(machine.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${machine.type}'),
                              Text('${machine.description}'),
                              Text(
                                '¥${machine.hourlyRate.toStringAsFixed(2)}/小时',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => _editMachine(index),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _deleteMachine(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}